// cdm resolves a requested directory for a shell wrapper. If the directory
// does not exist, it asks for confirmation before creating the full path.
// The wrapper uses the program's output to change the calling shell's
// working directory, which a standalone executable cannot do directly.

#include <iostream>
#include <filesystem>
#include <string>
#include <unordered_set>

int main(int argc, char* argv[]) {

    if (argc != 2) {
        std::cerr << "Usage: cdm <directory>\n";
        return 2;
    }

    // Construct path object from user provided input path
    std::filesystem::path target = argv[1];


    // Ask user to create new path if does not exist
    if (!std::filesystem::exists(target)) {

        static const std::unordered_set<std::string> valid_yes_answers = {
            "yes","y","Y","Yes","YES"
        };

        static const std::unordered_set<std::string> valid_no_answers = {
            "no","n","N","No","NO"
        };

        std::cerr << "Directory does not exist. Create? [y/n]: ";
        bool create = false;
        while (true) {
            std::string user_choice;
            std::cin >> user_choice;

            if (valid_yes_answers.contains(user_choice)) {
                create = true;
            }
            else if (valid_no_answers.contains(user_choice)) {
                create = false;
            }
            else {
                std::cerr << "Invalid input. Please enter 'y' or 'n': ";
                continue;
            }
            break;
        }
        if (!create) {
            std::cerr << "Directory creation aborted by user." << "\n";
            return 1;
        }

        bool created_path = std::filesystem::create_directories(target);

        if (!created_path) {
            std::cerr << "Failed to create directory." << "\n";
            return 1;
        }

        std::cerr << "Directory created successfully." << "\n";
    }

    // Hand over to 'cd' via shell.
    std::cout << target.string();

    return 0;
}