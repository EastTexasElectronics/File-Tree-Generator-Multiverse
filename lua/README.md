
# File Tree Generator (ftg.lua)

File Tree Generator is a command-line tool written in Lua to generate a file tree of a directory. It allows you to exclude specific files or directories, choose an output location, and interactively select items to exclude.

## Features

- Exclude specified files or directories.
- Specify an output location for the file tree.
- Interactive mode to select items to exclude.
- Clear the exclusion list.
- Show help message and version information.

## Requirements

- Lua 5.3 or higher

## Installation

1. **Download the Script**

   Download the `ftg.lua` script to your desired location.

   ```sh
   curl -o ftg.lua https://path-to-your-script/ftg.lua
   ```

2. **Make the Script Executable**

   ```sh
   chmod +x ftg.lua
   ```

## Usage

### Command Line Options

```sh
Usage: ftg.lua [-e pattern1,pattern2,...] [-o output_location] [-i] [-c] [-h] [-v]
Options:
  -e, --exclude      Exclude directories or files (comma-separated)(.git,node_modules,.vscode)
  -o, --output       Specify an output location; default output is in the pwd
  -i, --interactive  Interactive mode to select items to exclude
  -c, --clear        Clear the exclusion list
  -h, --help         Show this help message and exit
  -v, --version      Show version information and exit
```

### Examples

1. **Generate a file tree and exclude specific patterns:**

   ```sh
   ./ftg.lua -e .git,node_modules
   ```

2. **Specify an output location:**

   ```sh
   ./ftg.lua -o output.md
   ```

3. **Use interactive mode to select items to exclude:**

   ```sh
   ./ftg.lua -i
   ```

4. **Clear the exclusion list:**

   ```sh
   ./ftg.lua -c
   ```

5. **Show help message:**

   ```sh
   ./ftg.lua -h
   ```

6. **Show version information:**

   ```sh
   ./ftg.lua -v
   ```

## Interactive Mode

In interactive mode, the script will list all files and directories in the current directory. You can enter space-separated numbers of items to exclude, type `clear` to clear the exclusion list, or `-<ID>` to remove an item from the exclusion list.

Example of interactive mode prompt:

```
List of files and directories in /path/to/directory:
[1] .git
[2] node_modules
[3] file1.txt
[4] dir1

Enter space-separated numbers of items to exclude, type 'clear' to clear the exclusion list, or '-<ID>' to remove an item from the exclusion list:
```

## Contributing

Feel free to submit issues or pull requests if you find any bugs or have feature requests.

## Author

- [https://github.com/easttexaselectronics](https://github.com/easttexaselectronics)

## License

This project is licensed under the MIT License.

## Support

If you like this project, please leave a star on the repository. If you find it useful and would like to support further development, consider buying me a coffee:

- [Buy me a coffee](https://www.buymeacoffee.com/easttexaselectronics)
