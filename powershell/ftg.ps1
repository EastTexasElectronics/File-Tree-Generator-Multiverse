# This is a PowerShell implementation of the File Tree Generator tool.
# This is not been thoroughly tested, and may contain bugs.
# Please use the Zsh version for a more reliable and complete implementation.

# Initialize exclude patterns array and other variables
$exclude_patterns = @{}
$output_location = ""
$version = "1.0.0"
$author = "https://github.com/easttexaselectronics"

function Show-Usage {
    @"
Usage: ftg [-e pattern1,pattern2,...] [-o output_location] [-i] [-c] [-h] [-v]
Options:
  -e, --exclude      Exclude directories or files (comma-separated)(.git,node_modules,.vscode)
  -o, --output       Specify an output location; default output is in the current directory
  -i, --interactive  Interactive mode to select items to exclude
  -c, --clear        Clear the exclusion list
  -h, --help         Show this help message and exit
  -v, --version      Show version information and exit
"@
    exit 1
}

function Show-Version {
    Write-Output "File Tree Generator version: $version"
    Write-Output "Leave us a star at $author"
    Write-Output "Buy me a coffee: https://www.buymeacoffee.com/rmhavelaar"
    exit 0
}

function Error-Exit($message) {
    Write-Error "Error: $message"
    exit 1
}

# Parse command line arguments
$interactive = $false
$clear = $false

$args = Get-CommandLineArgs -args $args -parameters @{
    "-e" = "exclude"
    "--exclude" = "exclude"
    "-o" = "output"
    "--output" = "output"
    "-i" = "interactive"
    "--interactive" = "interactive"
    "-c" = "clear"
    "--clear" = "clear"
    "-h" = "help"
    "--help" = "help"
    "-v" = "version"
    "--version" = "version"
}

foreach ($key in $args.Keys) {
    switch ($key) {
        "exclude" {
            $patterns = $args[$key] -split ","
            foreach ($pattern in $patterns) {
                $exclude_patterns[$pattern] = $true
            }
        }
        "output" {
            $output_location = $args[$key]
        }
        "help" {
            Show-Usage
        }
        "version" {
            Show-Version
        }
        "clear" {
            $clear = $true
        }
        "interactive" {
            $interactive = $true
        }
    }
}

if ($clear) {
    $exclude_patterns.Clear()
}

# Common directories to exclude
$common_excludes = @("node_modules", ".next", ".vscode", ".idea", ".git", "target", "Cargo.lock", "zig-cache", "zig-out", "vendor", "go.sum", "DerivedData", ".svelte-kit")
foreach ($pattern in $common_excludes) {
    $exclude_patterns[$pattern] = $true
}

function Should-Exclude($name) {
    return $exclude_patterns.ContainsKey($name)
}

function Get-Entries($path) {
    $entries = Get-ChildItem -Force -LiteralPath $path
    if (!$?) {
        Error-Exit "Failed to get entries for directory $path"
    }
    return $entries
}

function Print-Entry($name, $type, $indent, $is_last) {
    if ($is_last) {
        Write-Output "${indent}└── [$type] $name"
    } else {
        Write-Output "${indent}├── [$type] $name"
    }
}

function Process-Entry($entry, $indent, $is_last) {
    $name = $entry.Name
    $fullpath = $entry.FullName
    $type = ""

    if (Should-Exclude $name) {
        return
    }

    if ($entry.PSIsContainer) {
        $type = "Directory"
    } else {
        $type = "File"
    }

    Print-Entry $name $type $indent $is_last

    if ($type -eq "Directory") {
        if ($is_last) {
            Generate-Tree $fullpath "${indent}    "
        } else {
            Generate-Tree $fullpath "${indent}│   "
        }
    }
}

function Generate-Tree($path, $indent) {
    $entries = Get-Entries $path
    if (!$?) {
        Error-Exit "Failed to read directory $path"
    }

    $count = $entries.Count

    for ($i = 0; $i -lt $count; $i++) {
        $entry = $entries[$i]
        $is_last = $i -eq ($count - 1)
        Process-Entry $entry $indent $is_last
    }
}

if ($interactive) {
    while ($true) {
        Write-Output "List of files and directories in $(Get-Location):"
        $entries = Get-Entries "."
        if (!$?) {
            Error-Exit "Failed to read current directory"
        }

        $count = $entries.Count
        for ($i = 0; $i -lt $count; $i++) {
            $entry = $entries[$i]
            Write-Output "[$i] $($entry.Name)"
        }

        Write-Output "Enter space-separated numbers of items to exclude, type 'clear' to clear the exclusion list, or '-<ID>' to remove an item from the exclusion list:"
        $ids = Read-Host

        if ($ids -eq "clear") {
            $exclude_patterns.Clear()
            Write-Output "Exclusion list cleared."
        } else {
            $ids = $ids -split " "
            foreach ($id in $ids) {
                if ($id -match "^-[0-9]+$") {
                    $id = $id.Substring(1)
                    if ($id -ge 0 -and $id -lt $count) {
                        $entry = $entries[$id]
                        $exclude_patterns.Remove($entry.Name)
                        Write-Output "Removed $($entry.Name) from exclusion list."
                    } else {
                        Write-Warning "Invalid ID: $id"
                    }
                } else {
                    if ($id -ge 0 -and $id -lt $count) {
                        $entry = $entries[$id]
                        $exclude_patterns[$entry.Name] = $true
                    } else {
                        Write-Warning "Invalid ID: $id"
                    }
                }
            }
        }

        Write-Output "Current exclusion list:"
        foreach ($pattern in $exclude_patterns.Keys) {
            Write-Output $pattern
        }

        Write-Output "Do you want to add more items (m), generate the file tree (y), or clear the exclusion list (c)?"
        $choice = Read-Host

        switch ($choice) {
            "y" { break }
            "c" {
                $exclude_patterns.Clear()
                Write-Output "Exclusion list cleared."
            }
            "m" { continue }
            default { Write-Warning "Invalid choice: $choice" }
        }
    }
}

$current_time = Get-Date -Format "HH-mm-ss"

if ([string]::IsNullOrEmpty($output_location)) {
    $output_location = "file_tree_${current_time}.md"
}

Write-Output "Generating your file tree, please wait..."

if (!(New-Item -ItemType File -Path $output_location -Force -ErrorAction SilentlyContinue)) {
    Error-Exit "Cannot write to output location $output_location"
}

"@"
# File Tree

Path to Directory: $(Get-Location)

```sh
"@ | Out-File -FilePath $output_location -Append
Generate-Tree "." | Out-File -FilePath $output_location -Append
"`"@`"sh" | Out-File -FilePath $output_location -Append

if (!$?) {
    Error-Exit "Failed to write to output location $output_location"
}

Write-Output "File tree has been written to $output_location"
