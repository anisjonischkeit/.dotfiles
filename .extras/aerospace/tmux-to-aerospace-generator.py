#!/usr/bin/env python3

import subprocess
import os
import re
import argparse
from pathlib import Path

# --- Configuration ---
AEROSPACE_MODE_NAME = "tmux_passthrough_mode"
START_MARKER = f"# >>> START TMUX AUTO-GENERATED BINDINGS FOR MODE: {AEROSPACE_MODE_NAME}"
END_MARKER = f"# <<< END TMUX AUTO-GENERATED BINDINGS FOR MODE: {AEROSPACE_MODE_NAME}"

# This map helps convert tmux key representations to Aerospace key strings.
# It needs to be comprehensive for the keys output by `tmux list-keys`.
_TMUX_TO_AEROSPACE_KEY_MAP = {
    # Special names from tmux output
    "Space": "space",
    "PPage": "pageUp",    # Page Up
    "NPage": "pageDown",  # Page Down (if it appears)
    "Enter": "return",
    "Escape": "esc",
    "Tab": "tab",
    "BSpace": "backspace", # Tmux often uses BSpace
    "Delete": "delete",   # Tmux often uses Delete
    "Up": "up",
    "Down": "down",
    "Left": "left",
    "Right": "right",

    # F-keys (example, add more if your tmux uses them in prefix table)
    "F1": "f1", "F2": "f2", "F3": "f3", "F4": "f4",
    "F5": "f5", "F6": "f6", "F7": "f7", "F8": "f8",
    "F9": "f9", "F10": "f10", "F11": "f11", "F12": "f12",

    # Direct characters that are also valid Aerospace keys (or need simple name)
    '\\"': 'quote',             # Aerospace key for " is "
    "\\'": "shift-quote",             # Aerospace key for ' is '
    ',': 'comma',
    '-': 'minus',
    '.': 'period',
    '/': 'slash',
    ';': 'semicolon',
    '=': 'equal',
    '[': 'leftSquareBracket',
    ']': 'rightSquareBracket',
    '\\': 'backslash',    # Tmux `list-keys` shows `\` for backslash key
    '`': 'backtick',      # Tmux `list-keys` shows `` ` `` for backtick key

    # Characters that imply shift for Aerospace based on common US keyboard layout
    # Tmux key from list-keys : Aerospace key
    '!': 'shift-1',
    '@': 'shift-2',
    '\\#': 'shift-3',
    '\\$': 'shift-4',
    '\\%': 'shift-5',
    '^': 'shift-6',
    '&': 'shift-7',
    '*': 'shift-8',       # (if it appears)
    '(': 'shift-9',
    ')': 'shift-0',
    '_': 'shift-minus',
    '+': 'shift-equal',
    '\\;': 'semicolon',
    ':': 'shift-semicolon',
    '<': 'shift-comma',
    '>': 'shift-period',
    '?': 'shift-slash',
    # Braces, pipe, tilde often direct in tmux, but shifted in Aerospace
    '\\{': 'shift-leftSquareBracket',
    '\\}': 'shift-rightSquareBracket',
    '|': 'shift-backslash',
    '\\~': 'shift-backtick'
}

def tmux_key_to_aerospace(tmux_key_str):
    """Converts a tmux key string to an Aerospace key string."""
    if tmux_key_str in _TMUX_TO_AEROSPACE_KEY_MAP:
        return _TMUX_TO_AEROSPACE_KEY_MAP[tmux_key_str]

    if tmux_key_str.startswith("M-"): # Alt modifier
        suffix = tmux_key_str[2:]
        # If M- is followed by an uppercase letter, Aerospace might expect alt-shift-KEY
        if len(suffix) == 1 and 'A' <= suffix <= 'Z':
            return f"alt-shift-{suffix.lower()}"
        # Otherwise, alt-key (e.g. M-1 -> alt-1, M-n -> alt-n)
        return f"alt-{suffix.lower()}"

    if tmux_key_str.startswith("C-"): # Control modifier
        suffix = tmux_key_str[2:]
        # If C- is followed by an uppercase letter, Aerospace might expect ctrl-shift-KEY
        if len(suffix) == 1 and 'A' <= suffix <= 'Z':
             return f"ctrl-shift-{suffix.lower()}"
        return f"ctrl-{suffix.lower()}" # e.g. C-b -> ctrl-b

    if tmux_key_str.startswith("S-"): # Control modifier
        suffix = tmux_key_str[2:]
        # If C- is followed by an uppercase letter, Aerospace might expect ctrl-shift-KEY
        return f"shift-{suffix.lower()}"

    # Single uppercase letters (not part of M- or C-) imply shift
    if len(tmux_key_str) == 1 and 'A' <= tmux_key_str <= 'Z':
        return f"shift-{tmux_key_str.lower()}"

    # Single lowercase letters or digits
    if len(tmux_key_str) == 1 and \
       (('a' <= tmux_key_str <= 'z') or ('0' <= tmux_key_str <= '9')):
        return tmux_key_str # Already lowercase or a digit

    print(f"Warning: Unhandled tmux key '{tmux_key_str}'. Skipping.")
    return None


def get_tmux_prefix_bindings():
    """Fetches and parses tmux prefix keybindings."""
    bindings = []
    try:
        # The grep pattern looks for "bind-key" followed by spaces, then "-T", spaces, "prefix", spaces...
        # It's important that the number of spaces between "bind-key" and "-T prefix" is flexible.
        # The key part in `tmux list-keys` output for prefix table is usually well-defined.
        # Example line: bind-key    -T prefix       c                new-window
        # Example line: bind-key    -T prefix       %                split-window -h
        cmd = 'tmux list-keys | grep "^bind-key.*-T prefix"'
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=True)
        
        # Regex to parse the relevant part of the line:
        # Skips "bind-key -T prefix" and captures the key and the command
        # `\s+` matches one or more spaces.
        # `([^\s]+)` captures the key (sequence of non-space characters).
        # `(.*)` captures the rest of the line as the command.
        line_regex = re.compile(r"^\s*bind-key\s+(-r|)\s+-T\s+prefix\s+([^\s]+)\s+(.*)$")

        for line in result.stdout.strip().split('\n'):
            if not line.strip():
                continue
            match = line_regex.match(line.strip())
            if match:
                tmux_flag = match.group(1)
                tmux_key = match.group(2)
                tmux_command = match.group(3).strip()
                bindings.append((tmux_key, tmux_command, tmux_flag))
            else:
                print(f"Warning: Could not parse tmux binding line: '{line}'")
        
    except subprocess.CalledProcessError as e:
        print(f"Error getting tmux keybindings: {e}")
        print("Is tmux running and `list-keys` working?")
        return None
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        return None
    return bindings

def generate_aerospace_config_lines(tmux_bindings):
    """Generates the Aerospace configuration lines for the bindings."""
    aerospace_lines = []
    if not tmux_bindings:
        return aerospace_lines

    for tmux_key, tmux_cmd, tmux_flag in tmux_bindings:
        aerospace_key = tmux_key_to_aerospace(tmux_key)
        if aerospace_key is None:
            continue

        mainModeReset = "mode main"
        if (tmux_flag == "-r"):
            mainModeReset = "exec-and-forget sleep 0.5 && aerospace " + mainModeReset
        
        additionalTmuxFlags = ""
        if ("new-window" in tmux_cmd or 
            "split-window" in tmux_cmd):
            additionalTmuxFlags = "-c '#{pane_current_path}'"
        # Escape backslashes and double quotes for the TOML string
        escaped_tmux_cmd = tmux_cmd.replace('\\', '\\\\').replace('"', '\\"')
        
        # Format: aerospace_key = ["exec-and-forget tmux full_command_string"]
        # Note: `exec-and-forget` is preferred over `exec` if you don't want Aerospace
        # to wait for the command to finish. For tmux commands, this is usually desired.
        aerospace_lines.append(f'{aerospace_key} = ["exec-and-forget tmux {escaped_tmux_cmd} {additionalTmuxFlags}", "{mainModeReset}", "exec-and-forget open /Applications/kitty.app"]')
    
    return sorted(list(set(aerospace_lines))) # Sort and remove duplicates

def update_aerospace_config(config_path_str, new_binding_lines):
    """Updates the Aerospace configuration file with the new bindings."""
    config_path = Path(config_path_str)
    
    if not config_path.exists():
        print(f"Aerospace config file not found: {config_path}")
        # Optionally, create it with the new section
        # For now, let's require it to exist or be creatable by user.
        # Or, create it:
        # print(f"Creating {config_path}...")
        # config_path.touch()
        # content = ""
        # If we create it, we'll just append the new block.
        content = ""
        if not new_binding_lines:
            print("No bindings to generate. Config file not modified.")
            return
    else:
        try:
            content = config_path.read_text()
        except Exception as e:
            print(f"Error reading Aerospace config file {config_path}: {e}")
            return

    # Prepare the full block of new bindings
    new_block_content = f"{START_MARKER}\n"
    new_block_content += f"[mode.{AEROSPACE_MODE_NAME}.binding]\n" # Mode header
    new_block_content += 'esc = ["mode main"]\n'
    new_block_content += 'ctrl-g = ["mode main"]\n'
    if new_binding_lines:
        new_block_content += "\n".join(new_binding_lines) + "\n"
    new_block_content += f"{END_MARKER}\n"

    # Regex to find the existing block (including markers)
    # re.DOTALL makes . match newlines as well
    pattern = re.compile(f"^{re.escape(START_MARKER)}.*?^{re.escape(END_MARKER)}$", re.MULTILINE | re.DOTALL)
    
    match = pattern.search(content)
    
    if match:
        print(f"Found existing generated bindings section in {config_path}. Replacing it.")
        updated_content = pattern.sub(new_block_content, content)
    else:
        print(f"No existing generated bindings section found in {config_path}. Appending new section.")
        if content and not content.endswith("\n"):
            content += "\n" # Ensure a newline before appending
        if content and not content.endswith("\n\n") and new_binding_lines: # Add extra newline if content exists
             content += "\n"
        updated_content = content + new_block_content

    try:
        config_path.write_text(updated_content)
        print(f"Successfully updated {config_path}")
        if not new_binding_lines:
             print("Note: No tmux prefix bindings were found or parsed, so the generated section is empty.")
    except Exception as e:
        print(f"Error writing to Aerospace config file {config_path}: {e}")


def main():
    parser = argparse.ArgumentParser(
        description="Generate Aerospace keybindings from tmux prefix keys and update aerospace.toml."
    )
    parser.add_argument(
        "--config",
        default=os.path.expanduser("~/.dotfiles/aerospace/.aerospace.toml"),
        help="Path to the Aerospace configuration file (default: ~/.dotfiles/aerospace/.aerospace.toml)"
    )
    args = parser.parse_args()

    print("Fetching tmux prefix keybindings...")
    tmux_bindings = get_tmux_prefix_bindings()

    if tmux_bindings is None:
        print("Could not retrieve tmux bindings. Exiting.")
        return
    
    if not tmux_bindings:
        print("No tmux prefix bindings found or parsed.")
        # Still proceed to update_aerospace_config to ensure the section is present/cleared
        # if it was expected.

    print("Generating Aerospace configuration lines...")
    aerospace_lines = generate_aerospace_config_lines(tmux_bindings)

    print(f"Updating Aerospace configuration file: {args.config}")
    update_aerospace_config(args.config, aerospace_lines)

    if aerospace_lines:
        print("\n--- Successfully Generated Aerospace Keybindings ---")
    else:
        print("(No bindings were generated)")


if __name__ == "__main__":
    main()
