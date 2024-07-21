// This is a Rust implementation of the File Tree Generator tool.
// This is not been thoroughly tested, and may contain bugs.
// Please use the Zsh version for a more reliable and complete implementation.

use chrono::Local;
use std::collections::HashSet;
use std::fs;
use std::fs::{DirEntry, File};
use std::io::{self, BufRead, Write};
use structopt::StructOpt;

#[derive(StructOpt)]
struct Cli {
    #[structopt(short = "e", long = "exclude")]
    exclude: Option<String>,
    #[structopt(short = "o", long = "output")]
    output: Option<String>,
    #[structopt(short = "i", long = "interactive")]
    interactive: bool,
    #[structopt(short = "c", long = "clear")]
    clear: bool,
    #[structopt(short = "h", long = "help")]
    help: bool,
    #[structopt(short = "v", long = "version")]
    version: bool,
}

fn main() {
    let args = Cli::from_args();

    if args.help {
        show_usage();
        return;
    }

    if args.version {
        show_version();
        return;
    }

    let mut exclude_patterns: HashSet<String> = HashSet::new();

    if args.clear {
        exclude_patterns.clear();
    }

    if let Some(exclude) = args.exclude {
        for pattern in exclude.split(',') {
            exclude_patterns.insert(pattern.to_string());
        }
    }

    let common_excludes: Vec<&str> = vec![
        "node_modules",
        ".next",
        ".vscode",
        ".idea",
        ".git",
        "target",
        "Cargo.lock",
        "zig-cache",
        "zig-out",
        "vendor",
        "go.sum",
        "DerivedData",
        ".svelte-kit",
    ];

    for pattern in common_excludes {
        exclude_patterns.insert(pattern.to_string());
    }

    if args.interactive {
        interactive_mode(&mut exclude_patterns);
    }

    let output_location = args.output.unwrap_or_else(|| {
        let current_time = Local::now().format("%Y-%m-%d_%H-%M-%S").to_string();
        format!("file_tree_{}.md", current_time)
    });

    println!("Generating your file tree, please wait...");

    let mut output_file = File::create(&output_location).expect("Cannot write to output location");
    generate_tree(&mut output_file, ".", "", &exclude_patterns);

    println!("File tree has been written to {}", output_location);
}

fn show_usage() {
    println!("Usage: ftg [-e pattern1,pattern2,...] [-o output_location] [-i] [-c] [-h] [-v]");
    println!("Options:");
    println!("  -e, --exclude      Exclude directories or files (comma-separated)(.git,node_modules,.vscode)");
    println!("  -o, --output       Specify an output location; default output is in the pwd");
    println!("  -i, --interactive  Interactive mode to select items to exclude");
    println!("  -c, --clear        Clear the exclusion list");
    println!("  -h, --help         Show this help message and exit");
    println!("  -v, --version      Show version information and exit");
    std::process::exit(1);
}

fn show_version() {
    let version = "1.0.0";
    let author = "https://github.com/easttexaselectronics";
    println!("File Tree Generator version: {}\nLeave us a star at {}\nBuy me a coffee: https://www.buymeacoffee.com/rmhavelaar", version, author);
    std::process::exit(0);
}

fn should_exclude(name: &str, exclude_patterns: &HashSet<String>) -> bool {
    exclude_patterns.contains(name)
}

fn get_entries(path: &str) -> io::Result<Vec<DirEntry>> {
    let entries = fs::read_dir(path)?.filter_map(Result::ok).collect();
    Ok(entries)
}

fn print_entry(writer: &mut File, name: &str, entry_type: &str, indent: &str, is_last: bool) {
    let connector = if is_last { "└──" } else { "├──" };
    writeln!(writer, "{}{} [{}] {}", indent, connector, entry_type, name)
        .expect("Unable to write entry");
}

fn process_entry(
    writer: &mut File,
    entry: &DirEntry,
    path: &str,
    indent: &str,
    is_last: bool,
    exclude_patterns: &HashSet<String>,
) {
    let name = entry.file_name().into_string().expect("Invalid file name");
    let full_path = format!("{}/{}", path, name);
    let entry_type = if entry.file_type().unwrap().is_dir() {
        "Directory"
    } else {
        "File"
    };

    if should_exclude(&name, exclude_patterns) {
        return;
    }

    print_entry(writer, &name, entry_type, indent, is_last);

    if entry_type == "Directory" {
        let new_indent = if is_last {
            format!("{}    ", indent)
        } else {
            format!("{}│   ", indent)
        };
        generate_tree(writer, &full_path, &new_indent, exclude_patterns);
    }
}

fn generate_tree(writer: &mut File, path: &str, indent: &str, exclude_patterns: &HashSet<String>) {
    let entries = get_entries(path).expect("Failed to read directory");

    let count = entries.len();
    for (i, entry) in entries.into_iter().enumerate() {
        let is_last = i == count - 1;
        process_entry(writer, &entry, path, indent, is_last, exclude_patterns);
    }
}

fn interactive_mode(exclude_patterns: &mut HashSet<String>) {
    let stdin = io::stdin();
    let mut reader = stdin.lock();

    loop {
        println!("List of files and directories in the current directory:");
        let entries = get_entries(".").expect("Failed to read current directory");

        for (i, entry) in entries.iter().enumerate() {
            println!(
                "[{}] {}",
                i + 1,
                entry.file_name().into_string().expect("Invalid file name")
            );
        }

        println!("Enter space-separated numbers of items to exclude, type 'clear' to clear the exclusion list, or '-<ID>' to remove an item from the exclusion list:");
        let mut ids = String::new();
        reader.read_line(&mut ids).expect("Failed to read line");
        let ids = ids.trim();

        if ids == "clear" {
            exclude_patterns.clear();
            println!("Exclusion list cleared.");
        } else {
            for id_str in ids.split_whitespace() {
                if id_str.starts_with('-') {
                    let id: usize = id_str[1..].parse().expect("Invalid ID");
                    if id > 0 && id <= entries.len() {
                        let entry: &DirEntry = &entries[id - 1];
                        exclude_patterns
                            .remove(&entry.file_name().into_string().expect("Invalid file name"));
                        println!(
                            "Removed {} from exclusion list.",
                            entry.file_name().into_string().expect("Invalid file name")
                        );
                    } else {
                        println!("Invalid ID: {}", id_str);
                    }
                } else {
                    let id: usize = id_str.parse().expect("Invalid ID");
                    if id > 0 && id <= entries.len() {
                        let entry = &entries[id - 1];
                        exclude_patterns
                            .insert(entry.file_name().into_string().expect("Invalid file name"));
                        println!(
                            "Added {} to exclusion list.",
                            entry.file_name().into_string().expect("Invalid file name")
                        );
                    } else {
                        println!("Invalid ID: {}", id_str);
                    }
                }
            }
        }

        println!("Current exclusion list:");
        for pattern in exclude_patterns.iter() {
            println!("{}", pattern);
        }

        println!("Do you want to add more items (m), generate the file tree (y), or clear the exclusion list (c)?");
        let mut choice = String::new();
        reader.read_line(&mut choice).expect("Failed to read line");
        let choice = choice.trim();

        if choice == "y" {
            break;
        } else if choice == "c" {
            exclude_patterns.clear();
            println!("Exclusion list cleared.");
        } else if choice != "m" {
            println!("Invalid choice.");
        }
    }
}
