// This is a Go implementation of the File Tree Generator tool.
// This is not been thoroughly tested, and may contain bugs.
// Please use the Zsh version for a more reliable and complete implementation.

package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"
)

var (
	excludePatterns = map[string]bool{}
	outputLocation  string
	version         = "1.0.0"
	author          = "https://github.com/easttexaselectronics"
	outputFile      *os.File
)

func showUsage() {
	fmt.Println(`Usage: ftg [-e pattern1,pattern2,...] [-o output_location] [-i] [-c] [-h] [-v]
Options:
  -e, --exclude      Exclude directories or files (comma-separated)(.git,node_modules,.vscode)
  -o, --output       Specify an output location; default output is in the pwd
  -i, --interactive  Interactive mode to select items to exclude
  -c, --clear        Clear the exclusion list
  -h, --help         Show this help message and exit
  -v, --version      Show version information and exit`)
	os.Exit(1)
}

func showVersion() {
	fmt.Printf("File Tree Generator version: %s\nLeave us a star at %s\nBuy me a coffee: https://www.buymeacoffee.com/rmhavelaar\n", version, author)
	os.Exit(0)
}

func errorExit(message string) {
	fmt.Fprintf(os.Stderr, "Error: %s\n", message)
	os.Exit(1)
}

func shouldExclude(name string) bool {
	return excludePatterns[name]
}

func getEntries(path string) ([]fs.DirEntry, error) {
	entries, err := os.ReadDir(path)
	if err != nil {
		return nil, fmt.Errorf("failed to get entries for directory %s: %w", path, err)
	}
	return entries, nil
}

func printEntry(writer io.Writer, name, entryType, indent string, isLast bool) {
	var connector string
	if isLast {
		connector = "└──"
	} else {
		connector = "├──"
	}
	fmt.Fprintf(writer, "%s%s [%s] %s\n", indent, connector, entryType, name)
}

func processEntry(writer io.Writer, entry fs.DirEntry, path, indent string, isLast bool) {
	name := entry.Name()
	fullPath := filepath.Join(path, name)
	var entryType string

	if shouldExclude(name) {
		return
	}

	if entry.IsDir() {
		entryType = "Directory"
	} else {
		entryType = "File"
	}

	printEntry(writer, name, entryType, indent, isLast)

	if entryType == "Directory" {
		newIndent := indent
		if isLast {
			newIndent += "    "
		} else {
			newIndent += "│   "
		}
		generateTree(writer, fullPath, newIndent)
	}
}

func generateTree(writer io.Writer, path, indent string) {
	entries, err := getEntries(path)
	if err != nil {
		errorExit(fmt.Sprintf("Failed to read directory %s", path))
	}

	count := len(entries)

	for i, entry := range entries {
		isLast := i == count-1
		processEntry(writer, entry, path, indent, isLast)
	}
}

func interactiveMode() {
	reader := bufio.NewReader(os.Stdin)
	for {
		// List all entries with IDs
		fmt.Println("List of files and directories in the current directory:")
		entries, err := getEntries(".")
		if err != nil {
			errorExit("Failed to read current directory")
		}

		count := len(entries)
		for i, entry := range entries {
			fmt.Printf("[%d] %s\n", i+1, entry.Name())
		}

		// Prompt user to enter IDs to exclude or clear the exclusion list
		fmt.Println("Enter space-separated numbers of items to exclude, type 'clear' to clear the exclusion list, or '-<ID>' to remove an item from the exclusion list:")
		ids, _ := reader.ReadString('\n')
		ids = strings.TrimSpace(ids)

		if ids == "clear" {
			excludePatterns = map[string]bool{}
			fmt.Println("Exclusion list cleared.")
		} else {
			for _, idStr := range strings.Split(ids, " ") {
				if idStr == "" {
					continue
				}
				if strings.HasPrefix(idStr, "-") {
					id, err := strconv.Atoi(idStr[1:])
					if err == nil && id > 0 && id <= count {
						entry := entries[id-1]
						delete(excludePatterns, entry.Name())
						fmt.Printf("Removed %s from exclusion list.\n", entry.Name())
					} else {
						fmt.Printf("Invalid ID: %s\n", idStr)
					}
				} else {
					id, err := strconv.Atoi(idStr)
					if err == nil && id > 0 && id <= count {
						entry := entries[id-1]
						excludePatterns[entry.Name()] = true
						fmt.Printf("Added %s to exclusion list.\n", entry.Name())
					} else {
						fmt.Printf("Invalid ID: %s\n", idStr)
					}
				}
			}
		}

		// Show current exclusion list
		fmt.Println("Current exclusion list:")
		for pattern := range excludePatterns {
			fmt.Println(pattern)
		}

		// Ask if the user wants to add more or generate the file tree
		fmt.Println("Do you want to add more items (m), generate the file tree (y), or clear the exclusion list (c)?")
		choice, _ := reader.ReadString('\n')
		choice = strings.TrimSpace(choice)

		if choice == "y" {
			break
		} else if choice == "c" {
			excludePatterns = map[string]bool{}
			fmt.Println("Exclusion list cleared.")
		} else if choice != "m" {
			fmt.Println("Invalid choice.")
		}
	}
}

func main() {
	var exclude string
	var interactive, clear, help, versionFlag bool

	flag.StringVar(&exclude, "e", "", "Exclude directories or files (comma-separated)")
	flag.StringVar(&outputLocation, "o", "", "Specify an output location")
	flag.BoolVar(&interactive, "i", false, "Interactive mode to select items to exclude")
	flag.BoolVar(&clear, "c", false, "Clear the exclusion list")
	flag.BoolVar(&help, "h", false, "Show this help message and exit")
	flag.BoolVar(&versionFlag, "v", false, "Show version information and exit")

	flag.Parse()

	if help {
		showUsage()
	}

	if versionFlag {
		showVersion()
	}

	if clear {
		excludePatterns = map[string]bool{}
	}

	if exclude != "" {
		patterns := strings.Split(exclude, ",")
		for _, pattern := range patterns {
			excludePatterns[pattern] = true
		}
	}

	commonExcludes := []string{"node_modules", ".next", ".vscode", ".idea", ".git", "target", "Cargo.lock", "zig-cache", "zig-out", "vendor", "go.sum", "DerivedData", ".svelte-kit"}
	for _, pattern := range commonExcludes {
		excludePatterns[pattern] = true
	}

	if interactive {
		interactiveMode()
	}

	if outputLocation == "" {
		currentTime := time.Now().Format("15-04-05")
		outputLocation = fmt.Sprintf("file_tree_%s.md", currentTime)
	}

	fmt.Println("Generating your file tree, please wait...")

	var err error
	outputFile, err = os.Create(outputLocation)
	if err != nil {
		errorExit(fmt.Sprintf("Cannot write to output location %s", outputLocation))
	}
	defer outputFile.Close()

	fmt.Fprintf(outputFile, "# File Tree\n\nPath to Directory: %s\n\n```sh\n", filepath.Dir(outputLocation))
	generateTree(outputFile, ".", "")
	fmt.Fprintln(outputFile, "```")

	fmt.Printf("File tree has been written to %s\n", outputLocation)
}
