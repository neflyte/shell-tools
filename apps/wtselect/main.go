package main

import (
	"fmt"
	"os"
	"path"
	"sort"
	"strings"

	"github.com/charmbracelet/huh"
	"github.com/spf13/afero"
)

func sortDirEntriesByModTime(entries []os.FileInfo) {
	sort.Slice(entries, func(i, j int) bool {
		return entries[i].ModTime().After(entries[j].ModTime())
	})
}

func getWorktrees(fs afero.Fs, dir string) []huh.Option[string] {
	worktreeDir := path.Join(dir, ".git", "worktrees")
	dirEntries, err := afero.ReadDir(fs, worktreeDir)
	if err != nil {
		return nil
	}
	if len(dirEntries) == 0 {
		return make([]huh.Option[string], 0)
	}
	sortDirEntriesByModTime(dirEntries)

	tokens := strings.Split(dir, string(os.PathSeparator))
	dirName := tokens[len(tokens)-1]

	options := []huh.Option[string]{
		huh.NewOption(dirName, dir),
	}

	for idx := range dirEntries {
		if !dirEntries[idx].IsDir() {
			continue
		}
		gitdirFile := path.Join(worktreeDir, dirEntries[idx].Name(), "gitdir")
		gitdirContent, err := afero.ReadFile(fs, gitdirFile)
		if err != nil {
			continue
		}
		options = append(options, huh.NewOption(dirEntries[idx].Name(), path.Dir(string(gitdirContent))))
	}
	return options
}

func main() {
	if len(os.Args) != 2 {
		_, _ = fmt.Fprintf(os.Stderr, "Usage: %s <worktree-main-dir>\n", path.Base(os.Args[0]))
		os.Exit(1)
	}

	fs := afero.NewOsFs()
	options := getWorktrees(fs, os.Args[1])
	if options == nil || len(options) == 0 {
		_, _ = fmt.Fprintln(os.Stderr, "No worktrees found")
		os.Exit(2)
	}

	result := ""
	group := huh.NewGroup(
		huh.NewSelect[string]().
			Title("Select a worktree").
			Options(
				options...,
			).
			Value(&result),
	).WithHeight(10)
	err := huh.NewForm(group).
		WithOutput(os.Stdout).
		Run()
	if err != nil {
		_, _ = fmt.Fprintf(os.Stderr, "%s\n", err)
		os.Exit(3)
	}

	_, _ = fmt.Fprint(os.Stderr, result)
}
