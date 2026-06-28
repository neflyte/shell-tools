#!/usr/bin/env python3
import subprocess
import datetime
import sys
import logging
import lz4.frame
import bz2
from pathlib import Path
from tarfile import TarFile, TarInfo
from typing import Final

# Configuration
BACKUP_DIR: Final[Path] = Path("/var/sysbackup")
BACKUP_OWNER: Final[str] = "sysbackup"
BACKUP_GROUP: Final[str] = "sysbackup"

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger: logging.Logger = logging.getLogger(__name__)


def backup_database() -> bool:
    short_timestamp: str = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    backup_filename: str = f"pg_dumpall_{short_timestamp}.sql"
    backup_archivefilename: str = f"pg_dumpall_{short_timestamp}.sql.bz2"
    backup_file: Path = BACKUP_DIR / backup_filename
    backup_archivefile: Path = BACKUP_DIR / backup_archivefilename

    try:
        logger.info(f"Back up database to {str(backup_file)}...")
        subprocess.run(["pg_dumpall", "-U", "postgres", "-f", str(backup_file), "--quote-all-identifiers"], check=True)
        logger.info(f"Compress database backup to {str(backup_archivefile)}...")
        with bz2.open(backup_archivefile, "wb") as backup_archive:
            backup_archive.write(backup_file.read_bytes())
        backup_file.unlink()
        return True
    except subprocess.CalledProcessError as e:
        logger.error(f"Database backup failed: {e}")
        return False


def backup_config_files() -> bool:
    short_timestamp: str = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    backup_filename: str = f"etc_usr-local-etc_{short_timestamp}.tar.lz4"
    backup_file: Path = BACKUP_DIR / backup_filename

    try:
        logger.info(f"Back up /etc and /usr/local/etc to {str(backup_file)}...")
        with lz4.frame.open(backup_file, "wb") as lz4_file:
            with TarFile.open(fileobj=lz4_file, mode="w") as tar:
                tar.add("/etc", arcname="etc")
                tar.add("/usr/local/etc", arcname="usr-local-etc")
        return True
    except Exception as e:
        logger.error(f"Backup of /etc and /usr/local/etc failed: {e}")
        return False


def filter_backup_var_db(x: TarInfo) -> TarInfo | None:
    if x.name == "var-db/freebsd-update":
        return None
    return x


def backup_var_db() -> bool:
    short_timestamp: str = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    backup_filename: str = f"var-db_{short_timestamp}.tar.lz4"
    backup_file: Path = BACKUP_DIR / backup_filename

    try:
        logger.info(f"Back up /var/db to {str(backup_file)}...")
        with lz4.frame.open(backup_file, "wb") as lz4_file:
            with TarFile.open(fileobj=lz4_file, mode="w") as tar:
                tar.add("/var/db", arcname="var-db", filter=filter_backup_var_db)
        return True
    except Exception as e:
        logger.error(f"Backup of /var/db failed: {e}")
        return False


def main() -> None:
    # Ensure the backup directory exists
    if not BACKUP_DIR.exists():
        logger.error(f"Backup directory {BACKUP_DIR} does not exist.")
        sys.exit(1)

    if not backup_database() or not backup_config_files() or not backup_var_db():
        sys.exit(1)


if __name__ == "__main__":
    main()
