#!/usr/bin/env python3
import argparse
import os
import subprocess
import tarfile
import datetime
import shutil
import sys
import logging
import lz4.frame
from pathlib import Path
from typing import Final

# Configuration
BACKUP_DIR: Final[Path] = Path("/var/mail/backup")
BACKUP_OWNER: Final[str] = "mailbackup"
BACKUP_GROUP: Final[str] = "mailbackup"
MAILDIR_PATH: Final[str] = "maildir:~/Maildir"

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger: logging.Logger = logging.getLogger(__name__)


def backup_user(username: str, backup_only: bool = False, archive_only: bool = False) -> None:
  """
  Equivalent to the original bash script logic for a single user.
  """
  try:
    short_timestamp: str = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    backup_filename: str = f"{username}_Maildir_{short_timestamp}.tar.lz4"
    backup_file: Path = BACKUP_DIR / backup_filename

    # Conflict check: if the backup file exists, rename it (append PID)
    if not backup_only and backup_file.exists():
      new_path: Path = backup_file.with_name(f"{backup_file.name}_{os.getpid()}")
      logger.warning(f"Backup file {backup_file} already exists. Renaming to {new_path}")
      backup_file.rename(new_path)

    user_home: Path = Path(f"/home/{username}")
    if not backup_only and not user_home.exists():
      logger.error(f"Home directory {user_home} does not exist for user {username}")
      raise FileNotFoundError(f"Home directory {user_home} not found")

    if not archive_only:
      logger.info(f"Backup mail for {username} to {MAILDIR_PATH}...")
      subprocess.run(["doveadm", "backup", "-u", username, MAILDIR_PATH], check=True)

    if not backup_only:
      logger.info(f"Create lz4 tarball for {username}...")
      with lz4.frame.open(backup_file, "wb") as lz4_file:
        with tarfile.open(fileobj=lz4_file, mode="w") as tar:
          tar.add(user_home / "Maildir", arcname="Maildir")

      # Chown backup file
      logger.info(f"Change ownership of {backup_file} to {BACKUP_OWNER}:{BACKUP_GROUP}...")
      shutil.chown(backup_file, BACKUP_OWNER, BACKUP_GROUP)

  except subprocess.CalledProcessError as e:
    logger.error(f"Command failed during backup for {username}: {e}")
    raise
  except Exception as e:
    logger.error(f"An unexpected error occurred during backup for {username}: {e}")
    raise


def main() -> None:
  parser: argparse.ArgumentParser = argparse.ArgumentParser(description="Back up mail directories for specified users.")
  parser.add_argument("users", nargs="+", metavar="USER", help="One or more usernames to back up.")
  parser.add_argument("--backup-only", action="store_true",
                      help="Only perform doveadm backup; do not create a tarball.")
  parser.add_argument("--archive-only", action="store_true",
                      help="Only create a tarball; do not perform doveadm backup.")
  args: argparse.Namespace = parser.parse_args()

  # Ensure the backup directory exists
  if not BACKUP_DIR.exists():
    logger.error(f"Backup directory {BACKUP_DIR} does not exist.")
    sys.exit(1)

  try:
    for user in args.users:
      backup_user(user, backup_only=args.backup_only, archive_only=args.archive_only)
    logger.info("Mail backup completed successfully.")
  except Exception:
    # Since we're mimicking 'set -e', we exit on the first error.
    sys.exit(1)


if __name__ == "__main__":
  main()
