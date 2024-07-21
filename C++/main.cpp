// main.cpp

// This is a C++ implementation of the File Tree Generator tool.
// This is not been thoroughly tested, and may contain bugs.
// Please use the Zsh version for a more reliable and complete implementation.

#include <iostream>
#include <fstream>
#include <vector>
#include <unordered_set>
#include <unordered_map>
#include <filesystem>
#include <sstream>
#include <iomanip>
#include <ctime>

namespace fs = std::filesystem;

// Set to store patterns to be excluded
std::unordered_set<std::string> exclude_patterns;

// Variable to store output file location
std::string output_location;

// Constants for version and author information
const std::string version = "1.0.0";
const std::string author = "https://github.com/easttexaselectronics";

// Function declarations
void show_usage();
void show_version();
void error_exit(const std::string &message);
bool should_exclude(const std::string &name);
void print_entry(const std::string &name, const std::string &type, const std::string &indent, bool is_last, std::ofstream &output_file);
void process_entry(const fs::path &entry, const std::string &indent, bool is_last, std::ofstream &output_file);
void generate_tree(const fs::path &path, const std::string &indent, std::ofstream &output_file);
void interactive_mode();
std::string get_current_time();

// Function to display usage information
void show_usage()
{
    std::cout << "Usage: ftg [-e pattern1,pattern2,...] [-o output_location] [-i] [-c] [-h] [-v]\n"
              << "Options:\n"
              << "  -e, --exclude      Exclude directories or files (comma-separated)(.git,node_modules,.vscode)\n"
              << "  -o, --output       Specify an output location; default output is in the pwd\n"
              << "  -i, --interactive  Interactive mode to select items to exclude\n"
              << "  -c, --clear        Clear the exclusion list\n"
              << "  -h, --help         Show this help message and exit\n"
              << "  -v, --version      Show version information and exit\n";
    exit(1);
}

// Function to display version information
void show_version()
{
    std::cout << "File Tree Generator version: " << version << "\n"
              << "Leave us a star at " << author << "\n"
              << "Buy me a coffee: https://www.buymeacoffee.com/rmhavelaar\n";
    exit(0);
}

// Function to handle errors and exit the program
void error_exit(const std::string &message)
{
    std::cerr << "Error: " << message << std::endl;
    exit(1);
}

// Function to check if a file or directory should be excluded
bool should_exclude(const std::string &name)
{
    return exclude_patterns.find(name) != exclude_patterns.end();
}

// Function to print a file or directory entry
void print_entry(const std::string &name, const std::string &type, const std::string &indent, bool is_last, std::ofstream &output_file)
{
    if (is_last)
    {
        output_file << indent << "└── [" << type << "] " << name << "\n";
    }
    else
    {
        output_file << indent << "├── [" << type << "] " << name << "\n";
    }
}

// Function to process each file or directory entry
void process_entry(const fs::path &entry, const std::string &indent, bool is_last, std::ofstream &output_file)
{
    std::string name = entry.filename().string();
    std::string type;

    // Skip excluded entries
    if (should_exclude(name))
    {
        return;
    }

    // Determine if the entry is a file or directory
    if (fs::is_directory(entry))
    {
        type = "Directory";
    }
    else
    {
        type = "File";
    }

    // Print the entry
    print_entry(name, type, indent, is_last, output_file);

    // If the entry is a directory, recursively generate its tree
    if (type == "Directory")
    {
        if (is_last)
        {
            generate_tree(entry, indent + "    ", output_file);
        }
        else
        {
            generate_tree(entry, indent + "│   ", output_file);
        }
    }
}

// Function to generate the file tree for a given directory
void generate_tree(const fs::path &path, const std::string &indent, std::ofstream &output_file)
{
    std::vector<fs::path> entries;

    // Collect all entries in the directory
    for (const auto &entry : fs::directory_iterator(path))
    {
        entries.push_back(entry.path());
    }

    // Process each entry
    for (size_t i = 0; i < entries.size(); ++i)
    {
        process_entry(entries[i], indent, i == entries.size() - 1, output_file);
    }
}

// Function for interactive mode (to be implemented)
void interactive_mode()
{
    // Implement interactive mode if needed
}

// Function to get the current time as a string
std::string get_current_time()
{
    std::time_t now = std::time(nullptr);
    std::tm *local_time = std::localtime(&now);
    std::ostringstream oss;
    oss << std::put_time(local_time, "%H-%M-%S");
    return oss.str();
}

int main(int argc, char *argv[])
{
    std::unordered_map<std::string, std::string> args;

    // Parse command line arguments
    for (int i = 1; i < argc; ++i)
    {
        std::string arg = argv[i];
        if (arg == "-e" || arg == "--exclude")
        {
            if (i + 1 < argc)
            {
                std::istringstream iss(argv[++i]);
                std::string pattern;
                // Split the patterns and add to exclude list
                while (std::getline(iss, pattern, ','))
                {
                    exclude_patterns.insert(pattern);
                }
            }
        }
        else if (arg == "-o" || arg == "--output")
        {
            if (i + 1 < argc)
            {
                output_location = argv[++i];
            }
        }
        else if (arg == "-i" || arg == "--interactive")
        {
            interactive_mode();
        }
        else if (arg == "-c" || arg == "--clear")
        {
            exclude_patterns.clear();
        }
        else if (arg == "-h" || arg == "--help")
        {
            show_usage();
        }
        else if (arg == "-v" || arg == "--version")
        {
            show_version();
        }
    }

    // Add common directories to exclude list
    exclude_patterns.insert({"node_modules", ".next", ".vscode", ".idea", ".git", "target", "Cargo.lock", "zig-cache", "zig-out", "vendor", "go.sum", "DerivedData", ".svelte-kit"});

    // Get the current time for the output filename
    std::string current_time = get_current_time();
    if (output_location.empty())
    {
        output_location = "file_tree_" + current_time + ".md";
    }

    // Open the output file
    std::ofstream output_file(output_location);
    if (!output_file.is_open())
    {
        error_exit("Cannot write to output location " + output_location);
    }

    std::cout << "Generating your file tree, please wait...\n";

    // Write header information to the output file
    output_file << "# File Tree\n\n"
                << "Path to Directory: " << fs::current_path() << "\n\n"
                << "```\n";

    // Generate the file tree starting from the current directory
    generate_tree(".", "", output_file);

    // End the markdown code block
    output_file << "```\n";

    // Check if writing to the output file was successful
    if (output_file.fail())
    {
        error_exit("Failed to write to output location " + output_location);
    }

    std::cout << "File tree has been written to " << output_location << "\n";

    return 0;
}