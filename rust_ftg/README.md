
# File Tree Generator

File Tree Generator is a command-line utility written in Rust that generates a visual representation of the directory tree structure. This utility allows users to exclude specific files or directories from the output, run in interactive mode, and specify output locations.

## Features

- Exclude specific directories or files.
- Interactive mode to select items to exclude.
- Specify an output location for the generated file tree.
- Clear the exclusion list.
- Display help and version information.

## Installation

### Prerequisites

- Rust and Cargo installed. If you don't have Rust installed, you can install it using [rustup](https://rustup.rs/).

### Steps

1. **Clone the Repository** (If you have a repository):
    ```sh
    git clone https://github.com/yourusername/file_tree_generator.git
    cd file_tree_generator
    ```

2. **Build the Project**:
    ```sh
    cargo build --release
    ```

3. **Move the Executable to a Directory in Your PATH**:
    ```sh
    sudo mv target/release/file_tree_generator /usr/local/bin/
    ```

## Usage

You can run the program from any directory after installation.

### Command-Line Options

```
Usage: ftg [-e pattern1,pattern2,...] [-o output_location] [-i] [-c] [-h] [-v]
Options:
  -e, --exclude      Exclude directories or files (comma-separated) (e.g., .git,node_modules,.vscode)
  -o, --output       Specify an output location; default output is in the current working directory
  -i, --interactive  Interactive mode to select items to exclude
  -c, --clear        Clear the exclusion list
  -h, --help         Show this help message and exit
  -v, --version      Show version information and exit
```

### Examples

1. **Generate a File Tree with Exclusions**:
    ```sh
    file_tree_generator -e .git,node_modules -o output.txt
    ```

2. **Run in Interactive Mode**:
    ```sh
    file_tree_generator -i
    ```

3. **Clear the Exclusion List**:
    ```sh
    file_tree_generator -c
    ```

4. **Display Help Information**:
    ```sh
    file_tree_generator -h
    ```

5. **Display Version Information**:
    ```sh
    file_tree_generator -v
    ```

### Interactive Mode

When running in interactive mode, the program will list all files and directories in the current directory and prompt you to enter the numbers of items to exclude or to clear the exclusion list. You can also remove items from the exclusion list by prefixing the number with a `-`.

### Output File

By default, if no output location is specified, the output file will be named with a timestamp (e.g., `file_tree_2023-07-20_14-55-02.md`) and saved in the current working directory.

## Development

### Prerequisites

- Rust and Cargo installed. If you don't have Rust installed, you can install it using [rustup](https://rustup.rs/).

### Build the Project

To build the project, run:
```sh
cargo build --release
```

### Run the Project

To run the project, use:
```sh
cargo run -- [options]
```

### Testing

To run the tests, use:

```sh
cargo test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request or open an issue.

## License

This project is licensed under the MIT License.

## Acknowledgements

- [structopt](https://crates.io/crates/structopt)
- [chrono](https://crates.io/crates/chrono)

## Author

- [https://github.com/easttexaselectronics](https://github.com/easttexaselectronics)
- Buy me a coffee: [https://www.buymeacoffee.com/easttexaselectronics](https://www.buymeacoffee.com/easttexaselectronics)
