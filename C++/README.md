
# File Tree Generator

## Description

File Tree Generator is a command-line utility to generate a file tree structure of a directory and output it in a markdown file. This tool allows you to exclude specific files and directories and offers both automatic and interactive modes for exclusion.

## Features

- Generate file tree structure in markdown format
- Exclude specific files and directories
- Interactive mode to select items to exclude
- Clear the exclusion list

## Installation

### Prerequisites

- g++ compiler
- Make sure you have a C++17 compatible compiler

### Steps

1. Clone the repository (if applicable) or download the `main.cpp` file to your local machine.
2. Open your terminal and navigate to the directory where `main.cpp` is located.
3. Compile the C++ code using the following command:

    ```sh
    g++ -std=c++17 main.cpp -o ftg
    ```

4. This will generate an executable file named `ftg`.

## Usage

You can run the compiled executable with various options:

```sh
./ftg [options]
```

### Options

- `-e, --exclude` : Exclude directories or files (comma-separated) (e.g., `.git,node_modules,.vscode`)
- `-o, --output` : Specify an output location; default output is in the current directory
- `-i, --interactive` : Interactive mode to select items to exclude
- `-c, --clear` : Clear the exclusion list
- `-h, --help` : Show help message and exit
- `-v, --version` : Show version information and exit

### Examples

1. Generate a file tree in the current directory:

    ```sh
    ./ftg
    ```

2. Exclude specific directories and files:

    ```sh
    ./ftg -e .git,node_modules,.vscode
    ```

3. Specify an output location:

    ```sh
    ./ftg -o output_file.md
    ```

4. Interactive mode to exclude items:

    ```sh
    ./ftg -i
    ```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request on GitHub.

## Author

- GitHub: [easttexaselectronics](https://github.com/easttexaselectronics)
- Buy me a coffee: [BuyMeACoffee](https://www.buymeacoffee.com/easttexaselectronics)

## License

This project is licensed under the MIT License.
