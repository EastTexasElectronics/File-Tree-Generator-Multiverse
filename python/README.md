
# File Tree Generator (FTG)

A command-line tool to generate a file tree of your directory structure, with options to exclude specific files or directories.

## Version
1.0.0

## Author
[East Texas Electronics](https://github.com/easttexaselectronics)

## Buy Me a Coffee
[Buy me a coffee](https://www.buymeacoffee.com/easttexaselectronics)

## Features
- Exclude specified files or directories from the tree
- Interactive mode for selecting items to exclude
- Clear the exclusion list
- Specify an output location for the file tree
- Default output in the current working directory

## Installation

### 1. Save the Script
Save the `ftg.py` script to a directory, for example, `~/scripts/ftg.py`.

### 2. Make the Script Executable
Make sure the script is executable by running:
```sh
chmod +x ~/scripts/ftg.py
```

### 3. Add the Script Directory to PATH (Method 1)
Edit your shell configuration file (e.g., `~/.zshrc` for Zsh or `~/.bashrc` for Bash):
```sh
nano ~/.zshrc
```
Add the following line to the end of the file, replacing `~/scripts` with the path to your script directory:
```sh
export PATH="$PATH:~/scripts"
```
Reload the configuration file:
```sh
source ~/.zshrc
```

### 4. Create a Symbolic Link (Method 2)
Alternatively, create a symbolic link to the script in `/usr/local/bin`:
```sh
sudo ln -s ~/scripts/ftg.py /usr/local/bin/ftg
```
Make sure to replace `~/scripts/ftg.py` with the actual path to your script.

## Usage

You can run the script from any directory using:

```sh
ftg [options]
```
or

```sh
ftg.py [options]
```
if you added the script directory to your PATH.

### Options
```
-e, --exclude      Exclude directories or files (comma-separated), e.g., .git,node_modules,.vscode
-o, --output       Specify an output location; default output is in the current working directory
-i, --interactive  Interactive mode to select items to exclude
-c, --clear        Clear the exclusion list
-h, --help         Show the help message and exit
-v, --version      Show version information and exit
```

### Examples

#### Exclude Specific Directories or Files
```sh
ftg -e .git,node_modules
```

#### Specify an Output Location
```sh
ftg -o output.md
```

#### Interactive Mode
```sh
ftg -i
```

#### Clear the Exclusion List
```sh
ftg -c
```

#### Show Help
```sh
ftg -h
```

#### Show Version Information
```sh
ftg -v
```

## Interactive Mode
In interactive mode, you will be prompted to exclude items or clear the exclusion list. The script will list all files and directories, and you can enter space-separated numbers to exclude them or use `-<ID>` to remove an item from the exclusion list.

### Example
```sh
ftg -i
```
You will see:
```
List of files and directories in /path/to/directory:
[1] .git
[2] node_modules
[3] src
[4] README.md
Enter space-separated numbers of items to exclude, type 'clear' to clear the exclusion list, or '-<ID>' to remove an item from the exclusion list:
```

## Contributions
Feel free to submit pull requests or report issues on the [GitHub repository](https://github.com/easttexaselectronics).

## License
This project is licensed under the MIT License.
