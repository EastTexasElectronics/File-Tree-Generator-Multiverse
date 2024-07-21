#!/usr/bin/env lua

-- This is a Lua implementation of the File Tree Generator tool.
-- This is not been thoroughly tested, and may contain bugs.
-- Please use the Zsh version for a more reliable and complete implementation.

-- Initialize exclude patterns array and other variables
local exclude_patterns = {}
local output_location = ""
local version = "1.0.0"
local author = "https://github.com/easttexaselectronics"

-- Function to show usage
local function show_usage()
    print([[
Usage: ftg [-e pattern1,pattern2,...] [-o output_location] [-i] [-c] [-h] [-v]
Options:
  -e, --exclude      Exclude directories or files (comma-separated)(.git,node_modules,.vscode)
  -o, --output       Specify an output location; default output is in the pwd
  -i, --interactive  Interactive mode to select items to exclude
  -c, --clear        Clear the exclusion list
  -h, --help         Show this help message and exit
  -v, --version      Show version information and exit
]])
    os.exit(1)
end

-- Function to show version
local function show_version()
    print("File Tree Generator version: " .. version)
    print("Leave us a star at " .. author)
    print("Buy me a coffee: https://www.buymeacoffee.com/rmhavelaar")
    os.exit(0)
end

-- Function to handle errors
local function error_exit(message)
    io.stderr:write("Error: " .. message .. "\n")
    os.exit(1)
end

-- Parse command line arguments
local args = {...}
local exclude, output, interactive, clear, help, version

for i = 1, #args do
    if args[i] == "-e" or args[i] == "--exclude" then
        exclude = args[i + 1]
    elseif args[i] == "-o" or args[i] == "--output" then
        output = args[i + 1]
    elseif args[i] == "-i" or args[i] == "--interactive" then
        interactive = true
    elseif args[i] == "-c" or args[i] == "--clear" then
        clear = true
    elseif args[i] == "-h" or args[i] == "--help" then
        help = true
    elseif args[i] == "-v" or args[i] == "--version" then
        version = true
    end
end

-- Validate and process each option
if exclude then
    for pattern in string.gmatch(exclude, "([^,]+)") do
        exclude_patterns[pattern] = true
    end
end

if output then
    output_location = output
end

if help then
    show_usage()
end

if version then
    show_version()
end

if clear then
    exclude_patterns = {}
end

-- Common directories to exclude
local common_excludes = {"node_modules", ".next", ".vscode", ".idea", ".git", "target", "Cargo.lock", "zig-cache",
                         "zig-out", "vendor", "go.sum", "DerivedData", ".svelte-kit"}

for _, pattern in ipairs(common_excludes) do
    exclude_patterns[pattern] = true
end

-- Function to check if a file or directory should be excluded
local function should_exclude(name)
    return exclude_patterns[name] ~= nil
end

-- Function to get entries in a directory, including hidden files
local function get_entries(path)
    local p = io.popen('ls -A "' .. path .. '"')
    if not p then
        error_exit("Failed to get entries for directory " .. path)
    end

    local entries = {}
    for entry in p:lines() do
        table.insert(entries, path .. "/" .. entry)
    end

    p:close()
    return entries
end

-- Function to print entry
local function print_entry(name, type, indent, is_last)
    if is_last then
        print(indent .. "└── [" .. type .. "] " .. name)
    else
        print(indent .. "├── [" .. type .. "] " .. name)
    end
end

-- Function to process each entry
local function process_entry(entry, indent, is_last)
    local name = entry:match("([^/]+)$")
    local fullpath = entry
    local type = ""

    if should_exclude(name) then
        return
    end

    local f = io.open(fullpath, "r")
    if f then
        type = "File"
        f:close()
    else
        type = "Directory"
    end

    print_entry(name, type, indent, is_last)

    if type == "Directory" then
        local sub_entries = get_entries(fullpath)
        if is_last then
            generate_tree(fullpath, indent .. "    ")
        else
            generate_tree(fullpath, indent .. "│   ")
        end
    end
end

-- Function to format the file tree
function generate_tree(path, indent)
    local entries = get_entries(path)
    local count = #entries

    for i, entry in ipairs(entries) do
        process_entry(entry, indent, i == count)
    end
end

-- Interactive mode
if interactive then
    while true do
        print("List of files and directories in " .. io.popen("pwd"):read("*l") .. ":")
        local entries = get_entries(".")

        for i, entry in ipairs(entries) do
            print("[" .. i .. "] " .. entry:match("([^/]+)$"))
        end

        print(
            "Enter space-separated numbers of items to exclude, type 'clear' to clear the exclusion list, or '-<ID>' to remove an item from the exclusion list:")
        local ids = io.read()

        if ids == "clear" then
            exclude_patterns = {}
            print("Exclusion list cleared.")
        else
            for id in string.gmatch(ids, "%S+") do
                if id:sub(1, 1) == "-" then
                    id = tonumber(id:sub(2))
                    if id and id > 0 and id <= #entries then
                        local entry = entries[id]
                        exclude_patterns[entry:match("([^/]+)$")] = nil
                        print("Removed " .. entry:match("([^/]+)$") .. " from exclusion list.")
                    else
                        print("Invalid ID: " .. id)
                    end
                else
                    id = tonumber(id)
                    if id and id > 0 and id <= #entries then
                        local entry = entries[id]
                        exclude_patterns[entry:match("([^/]+)$")] = true
                    else
                        print("Invalid ID: " .. id)
                    end
                end
            end
        end

        print("Current exclusion list:")
        for pattern, _ in pairs(exclude_patterns) do
            print(pattern)
        end

        print("Do you want to add more items (m), generate the file tree (y), or clear the exclusion list (c)?")
        local choice = io.read()

        if choice == "y" then
            break
        elseif choice == "c" then
            exclude_patterns = {}
            print("Exclusion list cleared.")
        elseif choice ~= "m" then
            print("Invalid choice: " .. choice)
        end
    end
end

-- Get the current time
local current_time = os.date("%H-%M-%S")

-- Determine output file location
if output_location == "" then
    output_location = "file_tree_" .. current_time .. ".md"
end

-- Start message
print("Generating your file tree, please wait...")

-- Ensure output file is writable
local output_file = io.open(output_location, "w")
if not output_file then
    error_exit("Cannot write to output location " .. output_location)
end

-- Write to file_tree
output_file:write("# File Tree\n\n")
output_file:write("Path to Directory: " .. io.popen("pwd"):read("*l") .. "\n\n")
output_file:write("```sh\n")
local entries = get_entries(".")
for _, entry in ipairs(entries) do
    process_entry(entry, "", false)
end
output_file:write("```\n")
output_file:close()

-- Completion message
print("File tree has been written to " .. output_location)
