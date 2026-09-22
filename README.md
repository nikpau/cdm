# cdm

`cdm` is a small command-line helper for changing into a directory from an
interactive shell. If the requested directory does not exist, it asks whether
it should create the directory tree first.

## Requirements

- Linux or another platform with a C++20-compatible standard library
- `g++` (or an equivalent compiler if you build manually)
- Bash, Zsh, or Fish for the optional shell integration

The program uses `std::filesystem`, so the compiler and standard library must
support C++20.

## Install

The installer builds the program with warnings enabled, installs the executable
to `/usr/local/bin/cdm`, and adds a shell function to the configuration for the
shell named by `$SHELL`.

```sh
chmod +x install.sh
./install.sh
```

The installer may ask for administrator permission when `/usr/local/bin` is not
writable. Restart the shell, or reload its configuration manually:

```sh
# Bash
source ~/.bashrc

# Zsh
source ~/.zshrc

# Fish
source ~/.config/fish/config.fish
```

The shell function is required because an executable cannot change the parent
shell's working directory by itself. The function runs the installed program,
then passes its output to the shell's built-in `cd` command.

## Usage

```sh
cdm <directory>
```

Existing directory:

```sh
cdm ~/Projects/example
```

Missing directory:

```text
$ cdm ~/Projects/new-app
Directory does not exist. Create? [y/n]: y
Directory created successfully.
```

The path may be absolute or relative to the current directory. If creation is
declined, `cdm` leaves the current directory unchanged and returns a non-zero
status. Running the program without exactly one directory argument prints its
usage and returns status `2`.

## Build manually

```sh
g++ -std=c++20 -Wall -Wextra -pedantic -o cdm cdm.cpp
```

To try the executable without installing it, print its path and use your
shell's `cd` command:

```sh
cd "$(./cdm /tmp/example)"
```

## Uninstall

Remove the installed executable and delete the `cdm shell integration` block
from your shell configuration file:

```sh
sudo rm /usr/local/bin/cdm
```

The local build can be removed separately with `rm ./cdm`.

## Troubleshooting

### `cdm: command not found`

Confirm that `/usr/local/bin` is in `PATH`, then open a new shell. If the
command exists but the shell function is missing, reload the shell
configuration listed above.

### The installer selects the wrong shell

The installer uses `$SHELL`, which is normally the user's login shell. If that
variable is stale, run the installer from a shell whose configuration you want
to update, or add the function manually using the examples in the installer.

### Directory creation fails

Check that the parent directory is writable and that the path is not blocked by
an existing file, mount, or filesystem permission.

## Project files

- `cdm.cpp`: C++20 implementation
- `install.sh`: build, installation, and shell integration script
- `cdm`: local compiled binary created by the installer or manual build