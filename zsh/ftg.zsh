#!/bin/zsh

# Initialize exclude patterns array and other variables
typeset -A exclude_patterns
output_location=""
version="1.0.0"
author="https://github.com/easttexaselectronics"

# Function to show usage
show_usage() {
    cat <<EOF
Usage: ftg [-e pattern1,pattern2,...] [-o output_location] [-i] [-c] [-h] [-v]
Options:
  -e, --exclude      Exclude directories or files (comma-separated)(.git,node_modules,.vscode)
  -o, --output       Specify an output location; default output is in the pwd
  -i, --interactive  Interactive mode to select items to exclude
  -c, --clear        Clear the exclusion list
  -h, --help         Show this help message and exit
  -v, --version      Show version information and exit
EOF
    exit 1
}

# Function to show version
show_version() {
    echo "File Tree Generator version: $version"
    echo "Leave us a star at $author"
    echo "Buy me a coffee: https://www.buymeacoffee.com/rmhavelaar"
    exit 0
}

# Function to handle errors
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Parse command line arguments
zparseopts -D -E e:=exclude o:=output i=interactive c=clear h=help v=version

# Validate and process each option
for opt in ${(k)exclude}; do
    IFS=',' read -rA patterns <<<"${exclude[$opt]}"
    for pattern in "${patterns[@]}"; do
        exclude_patterns["$pattern"]=1
    done
done

if [[ -n $output ]]; then
    output_location="${output[-1]}"
fi

if [[ -n $help ]]; then
    show_usage
fi

if [[ -n $version ]]; then
    show_version
fi

if [[ -n $clear ]]; then
    exclude_patterns=()
fi

# Common directories to exclude
for pattern in node_modules .next .vscode .idea .git target Cargo.lock zig-cache zig-out vendor go.sum DerivedData .svelte-kit; do
    exclude_patterns["$pattern"]=1
done

# Function to check if a file or directory should be excluded
should_exclude() {
    [[ -n ${exclude_patterns["$1"]} ]]
}

# Function to get entries in a directory, including hidden files
get_entries() {
    entries=("$1"/.*(N) "$1"/*(N))
    if [ $? -ne 0 ]; then
        error_exit "Failed to get entries for directory $1"
    fi
    echo "${entries[@]}"
}

# Function to print entry
print_entry() {
    local name="$1"
    local type="$2"
    local indent="$3"
    local is_last="$4"

    if [ "$is_last" -eq 1 ]; then
        echo "${indent}└── [$type] $name"
    else
        echo "${indent}├── [$type] $name"
    fi
}

# Function to process each entry
process_entry() {
    local entry="$1"
    local indent="$2"
    local is_last="$3"

    local name="${entry##*/}"
    local fullpath="$entry"
    local type=""

    if should_exclude "$name"; then
        return
    fi

    if [ -d "$fullpath" ]; then
        type="Directory"
    else
        type="File"
    fi

    print_entry "$name" "$type" "$indent" "$is_last"

    if [ "$type" = "Directory" ]; then
        if [ $is_last -eq 1 ]; then
            generate_tree "$fullpath" "${indent}    "
        else
            generate_tree "$fullpath" "${indent}│   "
        fi
    fi
}

# Function to format the file tree
generate_tree() {
    local path="$1"
    local indent="$2"
    local entries=($(get_entries "$path"))
    if [ $? -ne 0 ]; then
        error_exit "Failed to read directory $path"
    fi

    local count=${#entries[@]}

    for i in {1..$count}; do
        local entry="${entries[$i-1]}"
        local is_last=0
        if [ $i -eq $count ]; then
            is_last=1
        fi
        process_entry "$entry" "$indent" "$is_last"
    done
}

# Interactive mode
if [[ -n $interactive ]]; then
    while true; do
        # List all entries with IDs
        echo "List of files and directories in $(pwd):"
        entries=($(get_entries "."))
        if [ $? -ne 0 ]; then
            error_exit "Failed to read current directory"
        fi

        local count=${#entries[@]}
        for i in {1..$count}; do
            local entry="${entries[$i-1]}"
            echo "[$i] ${entry##*/}"
        done

        # Prompt user to enter IDs to exclude or clear the exclusion list
        echo "Enter space-separated numbers of items to exclude, type 'clear' to clear the exclusion list, or '-<ID>' to remove an item from the exclusion list:"
        read -r ids

        if [[ "$ids" = "clear" ]]; then
            exclude_patterns=()
            echo "Exclusion list cleared."
        else
            for id in ${(s: :)ids}; do
                if [[ "$id" =~ ^-[0-9]+$ ]]; then
                    id=${id#-}
                    if [[ $id -gt 0 && $id -le $count ]]; then
                        local entry="${entries[$id-1]}"
                        unset 'exclude_patterns[${entry##*/}]'
                        echo "Removed ${entry##*/} from exclusion list."
                    else
                        echo "Invalid ID: $id" >&2
                    fi
                else
                    if [[ $id -gt 0 && $id -le $count ]]; then
                        local entry="${entries[$id-1]}"
                        exclude_patterns["${entry##*/}"]=1
                    else
                        echo "Invalid ID: $id" >&2
                    fi
                fi
            done
        fi

        # Show current exclusion list
        echo "Current exclusion list:"
        for pattern in ${(k)exclude_patterns}; do
            echo "$pattern"
        done

        # Ask if the user wants to add more or generate the file tree
        echo "Do you want to add more items (m), generate the file tree (y), or clear the exclusion list (c)?"
        read -r choice

        if [[ "$choice" = "y" ]]; then
            break
        elif [[ "$choice" = "c" ]]; then
            exclude_patterns=()
            echo "Exclusion list cleared."
        elif [[ "$choice" != "m" ]]; then
            echo "Invalid choice: $choice" >&2
        fi
    done
fi

# Get the current time
current_time=$(date +"%H-%M-%S")

# Determine output file location
if [ -z "$output_location" ]; then
    output_location="file_tree_${current_time}.md"
fi

# Start message
echo "Generating your file tree, please wait..."

# Ensure output file is writable
if ! touch "$output_location" 2>/dev/null; then
    error_exit "Cannot write to output location $output_location"
fi

# Write to file_tree
{
    echo "# File Tree"
    echo
    echo "Path to Directory: $(pwd)"
    echo
    echo "\`\`\`sh"
    generate_tree "."
    echo "\`\`\`"
} >"$output_location"

# Check if write operation was successful
if [ $? -ne 0 ]; then
    error_exit "Failed to write to output location $output_location"
fi

# Completion message
echo "File tree has been written to $output_location"