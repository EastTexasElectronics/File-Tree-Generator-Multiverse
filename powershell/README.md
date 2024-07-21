
# File Tree Generator

## Overview

The File Tree Generator is a PowerShell script designed to generate a visual representation of the file structure in a specified directory. It allows you to exclude certain files or directories, specify an output location, and even interactively select items to exclude.

## Features

- Exclude specific files or directories from the file tree
- Specify an output location for the file tree
- Interactive mode for selecting items to exclude
- Clear the exclusion list
- View help and version information

## Installation

### Prerequisites

- Windows operating system
- PowerShell (version 5.1 or later)

### Steps

1. Download the script file (`file_tree_generator.ps1`) to your local machine.

2. Open PowerShell with administrative privileges.

3. Navigate to the directory where you downloaded the script.

```sh
cd path\to\your\script
```

4. Unblock the script if it is blocked.

```sh
Unblock-File -Path .\file_tree_generator.ps1
```

## Usage

### Basic Command

```sh
.ile_tree_generator.ps1 [options]
```

### Options

- `-e, --exclude`: Exclude directories or files (comma-separated) (e.g., `.git,node_modules,.vscode`)
- `-o, --output`: Specify an output location; default output is in the current directory
- `-i, --interactive`: Interactive mode to select items to exclude
- `-c, --clear`: Clear the exclusion list
- `-h, --help`: Show help message and exit
- `-v, --version`: Show version information and exit

### Examples

1. **Generate a file tree with default settings**

```sh
.ile_tree_generator.ps1
```

2. **Exclude specific directories**

```sh
.ile_tree_generator.ps1 -e .git,node_modules
```

3. **Specify an output location**

```sh
.ile_tree_generator.ps1 -o C:\output\file_tree.md
```

4. **Interactive mode to select items to exclude**

```sh
.ile_tree_generator.ps1 -i
```

5. **Clear the exclusion list**

```sh
.ile_tree_generator.ps1 -c
```

6. **Show help message**

```sh
.ile_tree_generator.ps1 -h
```

7. **Show version information**

```sh
.ile_tree_generator.ps1 -v
```

## Additional Information

- **Author**: [East Texas Electronics](https://github.com/easttexaselectronics)
- **Buy me a coffee**: [Buy me a coffee](https://www.buymeacoffee.com/easttexaselectronics)

Feel free to contribute to the project by submitting issues or pull requests on GitHub.
