
# File Tree Script

This script generates a file tree of the current directory and outputs it to a markdown file. The script is designed for `zsh` but works on `bash` as well.

## Installation

### Clone the Repository

1. Open your terminal.
2. Clone the repository using the following command:

   ```sh
   git clone https://github.com/easttexaselectronics/file-tree-script.git
   cd file-tree-script
   ```

### Make the Script Executable

Make the script executable by running:

```sh
chmod +x ftg.sh
```

### Add an Alias

To make the script easier to use, add an alias to your shell configuration file.

#### For `zsh`

Add the following line to your `~/.zshrc` file:

```sh
alias ftg="~/path/to/file-tree-script/ft.sh"
```

Or, to automatically use FTG in interactive mode, add the following line to your `~/.zshrc` file:

```sh
alias ftg="~/path/to/file-tree-script/ft.sh -i"
```

#### For `bash`

Add the following line to your `~/.bashrc` or `~/.bash_profile` file:

```sh
alias ftg="~/path/to/file-tree-script/ft.sh"
```

Or, to automatically use FTG in interactive mode, add the following line to your `~/.bashrc` or `~/.bash_profile` file:

```sh
alias ftg="~/path/to/file-tree-script/ft.sh -i"
```

After adding the alias, reload or restart your shell configuration:

```sh
source ~/.zshrc    # For zsh
source ~/.bashrc   # For bash
```

## Usage

Run the script using the alias:

```sh
ftg [options]
```

### Command Line Options

<!-- Make sure aliase title and description line up vertically -->
| Option             | Alias | Description                                                                       |
|--------------------|-------|-----------------------------------------------------------------------------------|
| `-e`, `--exclude`  |       | Exclude directories or files (comma-separated). Example: `-e .git,node_modules`    |
| `-o`, `--output`   |       | Specify a different output location for the generated file tree.                   |
| `-i`, `--interactive` |   | Interactive mode for excluding directories or files.                               |
| `-h`, `--help`     |       | Show help message and exit.                                                       |
| `-v`, `--version`  |       | Show version information and exit.                                                |

### Example Commands

- Exclude specific directories (please note that the `.git` and `node_modules` directories are already excluded by default):

  ```sh
  ftg -e .git,node_modules
  ```

- Specify a different output location:

  ```sh
  ftg -o /path/to/output/file_tree.md
  ```

- Interactive mode for excluding directories or files:

  ```sh
  ftg -i
  ```

- Show help message:

  ```sh
  ftg -h
  ```

- Show version information:

  ```sh
  ftg -v
  ```

## Customization

### Adding or Removing Exclude Patterns

To add or remove exclude patterns, modify the `exclude_patterns` array in the script:

```sh
exclude_patterns+=(node_modules .next .vscode .idea .git target Cargo.lock zig-cache zig-out vendor go.sum DerivedData .svelte-kit)
```

Add or remove entries as needed. For example, to exclude a directory named `logs`, add `logs` to the array:

```sh
exclude_patterns+=(logs)
```

### Changing the Output File Location

By default, the script generates the output file in the current directory with a timestamped name. To change the default output location, use the `-o` option when running the script:

```sh
ftg -o /desired/path/to/output/file_tree.md
```

Alternatively, you can modify the script directly by setting the `output_location` variable to your desired path:

```sh
output_location="/desired/path/to/output/file_tree.md"
```

## Author

This script was created by [easttexaselectronics](https://github.com/easttexaselectronics). Contributions and feedback are welcome!

## License

This project is unlicensed. and free to use for any purpose.
