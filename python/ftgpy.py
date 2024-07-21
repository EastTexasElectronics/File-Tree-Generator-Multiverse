# This is a Python implementation of the File Tree Generator tool.
# This is not been thoroughly tested, and may contain bugs.
# Please use the Zsh version for a more reliable and complete implementation.

import argparse
import os
import sys
from datetime import datetime

# Script version and author information
version = "1.0.0"
author = "https://github.com/easttexaselectronics"
exclude_patterns = set()


def show_version():
    # Print the version information and exit.
    print(f"File Tree Generator version: {version}")
    print(f"Leave me a star at {author}")
    print("Buy me a coffee: https://www.buymeacoffee.com/rmhavelaar")
    sys.exit(0)


def error_exit(message):
    # Print an error message and exit the program.
    print(f"Error: {message}", file=sys.stderr)
    sys.exit(1)


def should_exclude(name):
    # Check if a file or directory should be excluded based on the exclusion list.
    return name in exclude_patterns


def get_entries(path):
    # Get all entries (including hidden ones) in the specified directory.
    try:
        entries = [os.path.join(path, entry) for entry in os.listdir(path)]
        entries += [os.path.join(path, entry)
                    for entry in os.listdir(path) if entry.startswith('.')]
        return entries
    except Exception as e:
        error_exit(f"Failed to get entries for directory {path}: {str(e)}")


def print_entry(name, type, indent, is_last):
    # Print a single entry in the tree format.
    if is_last:
        print(f"{indent}└── [{type}] {name}")
    else:
        print(f"{indent}├── [{type}] {name}")


def process_entry(entry, indent, is_last):
    # Process and print an entry and, if it is a directory, recursively process its contents.
    name = os.path.basename(entry)
    fullpath = entry

    if should_exclude(name):
        return

    if os.path.isdir(fullpath):
        type = "Directory"
    else:
        type = "File"

    print_entry(name, type, indent, is_last)

    if type == "Directory":
        if is_last:
            generate_tree(fullpath, indent + "    ")
        else:
            generate_tree(fullpath, indent + "│   ")


def generate_tree(path, indent=""):
    # Generate and print the file tree starting from the given path.
    entries = get_entries(path)
    count = len(entries)

    for i, entry in enumerate(entries):
        is_last = (i == count - 1)
        process_entry(entry, indent, is_last)


def interactive_mode():
    # Run the script in interactive mode, allowing the user to select items to exclude.
    while True:
        print(f"List of files and directories in {os.getcwd()}:")
        entries = get_entries(".")
        for i, entry in enumerate(entries, 1):
            print(f"[{i}] {os.path.basename(entry)}")

        ids = input("Enter space-separated numbers of items to exclude, type 'clear' to clear the exclusion list, or '-<ID>' to remove an item from the exclusion list: ")

        if ids == "clear":
            exclude_patterns.clear()
            print("Exclusion list cleared.")
        else:
            for id in ids.split():
                if id.startswith('-'):
                    id = int(id[1:])
                    if 0 < id <= len(entries):
                        entry = entries[id - 1]
                        exclude_patterns.discard(os.path.basename(entry))
                        print(f"Removed {os.path.basename(
                            entry)} from exclusion list.")
                    else:
                        print(f"Invalid ID: {id}", file=sys.stderr)
                else:
                    id = int(id)
                    if 0 < id <= len(entries):
                        entry = entries[id - 1]
                        exclude_patterns.add(os.path.basename(entry))
                    else:
                        print(f"Invalid ID: {id}", file=sys.stderr)

        print("Current exclusion list:")
        for pattern in exclude_patterns:
            print(pattern)

        choice = input(
            "Do you want to add more items (m), generate the file tree (y), or clear the exclusion list (c)? ")

        if choice == "y":
            break
        elif choice == "c":
            exclude_patterns.clear()
            print("Exclusion list cleared.")
        elif choice != "m":
            print(f"Invalid choice: {choice}", file=sys.stderr)


def main():
    # Main function to parse arguments and generate the file tree.
    parser = argparse.ArgumentParser(description="File Tree Generator")
    parser.add_argument(
        "-e", "--exclude", help="Exclude directories or files (comma-separated)", type=str)
    parser.add_argument(
        "-o", "--output", help="Specify an output location; default output is in the pwd", type=str)
    parser.add_argument("-i", "--interactive",
                        help="Interactive mode to select items to exclude", action="store_true")
    parser.add_argument(
        "-c", "--clear", help="Clear the exclusion list", action="store_true")
    parser.add_argument(
        "-v", "--version", help="Show version information and exit", action="store_true")

    args = parser.parse_args()

    if args.version:
        show_version()

    if args.clear:
        exclude_patterns.clear()

    if args.exclude:
        for pattern in args.exclude.split(','):
            exclude_patterns.add(pattern)

    common_patterns = ["node_modules", ".next", ".vscode", ".idea", ".git", "target",
                       "Cargo.lock", "zig-cache", "zig-out", "vendor", "go.sum", "DerivedData", ".svelte-kit"]
    for pattern in common_patterns:
        exclude_patterns.add(pattern)

    if args.interactive:
        interactive_mode()

    current_time = datetime.now().strftime("%H-%M-%S")
    output_location = args.output if args.output else f"file_tree_{
        current_time}.md"

    print("Generating your file tree, please wait...")

    try:
        with open(output_location, 'w') as f:
            f.write("# File Tree\n\n")
            f.write(f"Path to Directory: {os.getcwd()}\n\n")
            f.write("```sh\n")
            sys.stdout = f
            generate_tree(".")
            sys.stdout = sys.__stdout__
            f.write("```\n")
    except Exception as e:
        error_exit(f"Failed to write to output location {
                   output_location}: {str(e)}")

    print(f"File tree has been written to {output_location}")


if __name__ == "__main__":
    main()
