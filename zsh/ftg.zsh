#!/bin/zsh

typeset -A exclude_patterns
output_location="" # Default output is in the pwd, but you can specify a different default here.
version="1.0.1"
author="https://github.com/easttexaselectronics"
repository="https://github.com/easttexaselectronics/FileTreeGenerator"
donation="https://www.buymeacoffee.com/rmhavelaar"

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

show_version() {
    echo "File Tree Generator version: $version"
    echo
    echo "Please leave this project a star at $repository"
    echo
    echo "Buy me a coffee: $donation"
    exit 0
}

# Exit on error
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Parse arguments
zparseopts -D -E e:=exclude o:=output i=interactive c=clear h=help v=version

# Handle options
handle_options() {
    # Process the excluded patterns
    for opt in ${(k)exclude}; do
        IFS=',' read -rA patterns <<<"${exclude[$opt]}"
        for pattern in "${patterns[@]}"; do
            exclude_patterns["$pattern"]=1
        done
    done

    
    [[ -n $output ]] && output_location="${output[-1]}"
    [[ -n $help ]] && show_usage
    [[ -n $version ]] && show_version
    [[ -n $clear ]] && exclude_patterns=()
}

# Default directories to exclude (add or remove as needed)
set_common_exclusions() {
    for pattern in node_modules .next .vscode .idea .git .DS_Store; do
        exclude_patterns["$pattern"]=1
    done
}

should_exclude() {
    [[ -n ${exclude_patterns["$1"]} ]]
}

get_entries() {
    local path="$1"
    local entries=("$path"/.*(N) "$path"/*(N))
    [[ $? -ne 0 ]] && error_exit "Failed to get entries for directory $path"
    echo "${entries[@]}"
}

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

process_entry() {
    local entry="$1"
    local indent="$2"
    local is_last="$3"
    local name="${entry##*/}"
    local fullpath="$entry"
    local type=""

    should_exclude "$name" && return

    if [ -d "$fullpath" ]; then
        type="Directory"
    else
        type="File"
    fi

    print_entry "$name" "$type" "$indent" "$is_last"

    # Recursively process directories
    if [ "$type" = "Directory" ]; then
        [[ $is_last -eq 1 ]] && generate_tree "$fullpath" "${indent}    " || generate_tree "$fullpath" "${indent}│   "
    fi
}

generate_tree() {
    local path="$1"
    local indent="$2"
    local entries=($(get_entries "$path"))
    [[ $? -ne 0 ]] && error_exit "Failed to read directory $path"

    local count=${#entries[@]}
    for i in {1..$count}; do
        local entry="${entries[$i-1]}"
        local is_last=0
        [[ $i -eq $count ]] && is_last=1
        process_entry "$entry" "$indent" "$is_last"
    done
}

list_entries() {
    local entries=("$@")
    local count=${#entries[@]}
    for i in {1..$count}; do
        local entry="${entries[$i-1]}"
        echo "[$i] ${entry##*/}"
    done
}

update_exclusion_list() {
    local ids="$1"
    local entries=("$2")
    local count=${#entries[@]}

    if [[ "$ids" = "clear" ]]; then
        exclude_patterns=()
        echo "Exclusion list cleared."
    else
        for id in ${(s: :)ids}; do
            if [[ "$id" =~ ^-[0-9]+$ ]]; then
                id=${id#-}
                [[ $id -gt 0 && $id -le $count ]] && unset 'exclude_patterns[${entries[$id-1]##*/}]' && echo "Removed ${entries[$id-1]##*/} from exclusion list." || echo "Invalid ID: $id" >&2
            else
                [[ $id -gt 0 && $id -le $count ]] && exclude_patterns["${entries[$id-1]##*/}"]=1 || echo "Invalid ID: $id" >&2
            fi
        done
    fi
}

display_exclusion_list() {
    echo "Current exclusion list:"
    for pattern in ${(k)exclude_patterns}; do
        echo "$pattern"
    done
}

interactive_mode() {
    while true; do
        echo "List of files and directories in $(pwd):"
        local entries=($(get_entries "."))
        [[ $? -ne 0 ]] && error_exit "Failed to read current directory"

        list_entries "${entries[@]}"

        echo "Enter space-separated numbers of items to exclude, type 'clear' to clear the exclusion list, or '-<ID>' to remove an item from the exclusion list:"
        read -r ids
        update_exclusion_list "$ids" "${entries[@]}"
        display_exclusion_list

        echo "Do you want to add more items (m), generate the file tree (y), or clear the exclusion list (c)?"
        read -r choice

        case "$choice" in
            y) break ;;
            c) exclude_patterns=(); echo "Exclusion list cleared." ;;
            m) ;;
            *) echo "Invalid choice: $choice" >&2 ;;
        esac
    done
}

main() {
    handle_options
    set_common_exclusions
    [[ -n $interactive ]] && interactive_mode

    local current_time=$(date +"%H-%M-%S")
    [[ -z "$output_location" ]] && output_location="file_tree_${current_time}.md"

    echo "Generating your file tree, while you wait..."
    echo
    echo "Please leave this project a star at $repository"
    echo
    touch "$output_location" 2>/dev/null || error_exit "Cannot write to output location $output_location"

    {
        echo "# File Tree for $(pwd)"
        echo
        echo "\`\`\`sh"
        generate_tree "."
        echo "\`\`\`"
    } >"$output_location"

    [[ $? -ne 0 ]] && error_exit "Failed to write to output location $output_location"

    echo "File tree has been written to $output_location"
}

main "$@"
