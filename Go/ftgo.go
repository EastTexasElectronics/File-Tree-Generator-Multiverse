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
	version         = "1.0.1"
	author          = "https://github.com/easttexaselectronics"
	repository      = "https://github.com/easttexaselectronics/file-tree-generator"
	donation        = "https://www.buymeacoffee.com/rmhavelaar"
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
	fmt.Printf("File Tree Generator version: %s\nLeave us a star at %s\n", version, repository)
	fmt.Printf("Buy me a coffee: %s\n", donation)
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
	connector := getConnector(isLast)
	fmt.Fprintf(writer, "%s%s [%s] %s\n", indent, connector, entryType, name)
}

func getConnector(isLast bool) string {
	if isLast {
		return "└──"
	}
	return "├──"
}

func processEntry(writer io.Writer, entry fs.DirEntry, path, indent string, isLast bool) {
	name := entry.Name()
	fullPath := filepath.Join(path, name)
	entryType := getEntryType(entry)

	if shouldExclude(name) {
		return
	}

	printEntry(writer, name, entryType, indent, isLast)

	if entryType == "Directory" {
		newIndent := updateIndent(indent, isLast)
		generateTree(writer, fullPath, newIndent)
	}
}

func getEntryType(entry fs.DirEntry) string {
	if entry.IsDir() {
		return "Directory"
	}
	return "File"
}

func updateIndent(indent string, isLast bool) string {
	if isLast {
		return indent + "    "
	}
	return indent + "│   "
}

func generateTree(writer io.Writer, path, indent string) {
	entries, err := getEntries(path)
	if err != nil {
		errorExit(fmt.Sprintf("Failed to read directory %s", path))
	}

	for i, entry := range entries {
		isLast := i == len(entries)-1
		processEntry(writer, entry, path, indent, isLast)
	}
}

func interactiveMode() {
	reader := bufio.NewReader(os.Stdin)
	for {
		listEntries()

		ids, _ := reader.ReadString('\n')
		ids = strings.TrimSpace(ids)

		if ids == "clear" {
			excludePatterns = map[string]bool{}
			fmt.Println("Exclusion list cleared.")
		} else {
			processIDs(ids)
		}

		showExclusionList()

		fmt.Println("Do you want to add more items (m), generate the file tree (y), or clear the exclusion list (c)?")
		choice, _ := reader.ReadString('\n')
		choice = strings.TrimSpace(choice)

		if handleUserChoice(choice) {
			break
		}
	}
}

func listEntries() {
	fmt.Println("List of files and directories in the current directory:")
	entries, err := getEntries(".")
	if err != nil {
		errorExit("Failed to read current directory")
	}

	for i, entry := range entries {
		fmt.Printf("[%d] %s\n", i+1, entry.Name())
	}
}

func processIDs(ids string) {
	entries, _ := getEntries(".")
	count := len(entries)

	for _, idStr := range strings.Split(ids, " ") {
		if idStr == "" {
			continue
		}
		if strings.HasPrefix(idStr, "-") {
			removeExclusion(entries, count, idStr)
		} else {
			addExclusion(entries, count, idStr)
		}
	}
}

func removeExclusion(entries []fs.DirEntry, count int, idStr string) {
	id, err := strconv.Atoi(idStr[1:])
	if err == nil && id > 0 && id <= count {
		entry := entries[id-1]
		delete(excludePatterns, entry.Name())
		fmt.Printf("Removed %s from exclusion list.\n", entry.Name())
	} else {
		fmt.Printf("Invalid ID: %s\n", idStr)
	}
}

func addExclusion(entries []fs.DirEntry, count int, idStr string) {
	id, err := strconv.Atoi(idStr)
	if err == nil && id > 0 && id <= count {
		entry := entries[id-1]
		excludePatterns[entry.Name()] = true
		fmt.Printf("Added %s to exclusion list.\n", entry.Name())
	} else {
		fmt.Printf("Invalid ID: %s\n", idStr)
	}
}

func showExclusionList() {
	fmt.Println("Current exclusion list:")
	for pattern := range excludePatterns {
		fmt.Println(pattern)
	}
}

func handleUserChoice(choice string) bool {
	switch choice {
	case "y":
		return true
	case "c":
		excludePatterns = map[string]bool{}
		fmt.Println("Exclusion list cleared.")
		return false
	case "m":
		return false
	default:
		fmt.Println("Invalid choice.")
		return false
	}
}

func main() {
	var exclude string
	var interactive, clear, help, versionFlag bool

	flag.StringVar(&exclude, "e", "", "Exclude directories or files (comma-separated)")
	flag.StringVar(&outputLocation, "o", "", "Specify an output location")
	flag.BoolVar(&interactive, "i", false, "Interactive visual mode to select items to exclude")
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

	commonExcludes := []string{"node_modules", ".next", ".vscode", ".idea", ".git", "target", "Cargo.lock"}
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

	currentDir, err := os.Getwd()
	if err != nil {
		errorExit("Failed to get current directory")
	}

	fmt.Printf("Generating your file tree, while you wait... \nGive the project a star at %s\n", repository)

	outputFile, err = os.Create(outputLocation)
	if err != nil {
		errorExit(fmt.Sprintf("Cannot write to output location %s", outputLocation))
	}
	defer outputFile.Close()

	fmt.Fprintf(outputFile, "# File Tree for %s\n\n## Give the project a star at %s\n```sh\n", currentDir, repository)
	generateTree(outputFile, ".", "")
	fmt.Fprintln(outputFile, "```")

	fmt.Printf("File tree has been written to %s\n", outputLocation)
}
