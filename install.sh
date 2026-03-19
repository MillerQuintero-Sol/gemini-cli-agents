#!/bin/bash

# Configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# Replace this with your actual repository raw URL, or set REPO_URL environment variable
REPO_BASE_URL="${REPO_URL:-https://raw.githubusercontent.com/MillerQuintero-Sol/gemini-cli-agents/main}"
AGENTS_DIR=".gemini/agents"
TEMP_LIST="/tmp/gemini_agents_list_$(date +%s).txt"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Gemini CLI Agent Installer ===${NC}"

# Check for curl
if ! command -v curl &> /dev/null; then
    echo -e "${RED}Error: curl is required but not installed.${NC}"
    exit 1
fi

# Function to download a file
download_file() {
    local url="$1"
    local output="$2"
    curl -sL "$url" -o "$output"
    if [ $? -ne 0 ]; then
        return 1
    fi
    return 0
}

# Fetch agents list
echo -e "Fetching available agents..."
# Check if running locally for testing (optional flag or check file existence)
if [ -f "$SCRIPT_DIR/agents.list" ]; then
    cp "$SCRIPT_DIR/agents.list" "$TEMP_LIST"
else
    download_file "$REPO_BASE_URL/agents.list" "$TEMP_LIST"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to fetch agents list from $REPO_BASE_URL${NC}"
        echo "Please ensure the repository URL is correct."
        exit 1
    fi
fi

# Read agents into array
declare -a agents_keys
declare -a agents_descs

while IFS='|' read -r key desc || [ -n "$key" ]; do
    if [[ ! -z "$key" ]]; then
        agents_keys+=("$key")
        agents_descs+=("$desc")
    fi
done < "$TEMP_LIST"

# Process Arguments
selected_indices=()
install_mode="interactive"

if [ "$#" -gt 0 ]; then
    install_mode="args"
    for arg in "$@"; do
        if [[ "$arg" == "--all" ]]; then
            echo "Flag --all detected. Selecting all agents."
            selected_indices=()
            for i in "${!agents_keys[@]}"; do
                selected_indices+=($i)
            done
            break 
        elif [[ "$arg" == --* ]]; then
            # Remove leading --
            agent_arg="${arg:2}"
            found=false
            for i in "${!agents_keys[@]}"; do
                if [[ "${agents_keys[$i]}" == "$agent_arg" ]]; then
                    selected_indices+=($i)
                    found=true
                    break
                fi
            done
            if [ "$found" = false ]; then
                echo -e "${RED}Warning: Agent '$agent_arg' not found.${NC}"
            fi
        fi
    done
fi

# Interactive Menu (only if no args provided)
if [ "$install_mode" == "interactive" ]; then
    echo -e "\n${GREEN}Available Agents:${NC}"
    echo "0) Install ALL Agents"
    for i in "${!agents_keys[@]}"; do
        echo "$((i+1))) ${agents_keys[$i]} - ${agents_descs[$i]}"
    done

    echo -e "\n${BLUE}Enter numbers separated by spaces (e.g., '1 3') or '0' for all:${NC}"
    
    # Improved input handling for piped execution
    if [ -t 0 ]; then
        read -r selection
    elif [ -c /dev/tty ]; then
        read -r selection < /dev/tty
    else
        echo -e "${RED}Error: Cannot read user input. Please use arguments (e.g., --all or --backend-django) or run with 'bash <(curl ...)'${NC}"
        rm "$TEMP_LIST"
        exit 1
    fi

    # Process selection
    if [[ "$selection" == "0" ]] || [[ "$selection" == *" 0 "* ]] || [[ "$selection" == "0 "* ]] || [[ "$selection" == *" 0" ]]; then
        echo "Selected: ALL agents"
        for i in "${!agents_keys[@]}"; do
            selected_indices+=($i)
        done
    else
        for num in $selection; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#agents_keys[@]}" ]; then
                selected_indices+=($((num-1)))
            fi
        done
    fi
fi

if [ ${#selected_indices[@]} -eq 0 ]; then
    echo "No valid agents selected. Exiting."
    rm "$TEMP_LIST"
    exit 0
fi

# Create directory
mkdir -p "$AGENTS_DIR"

# Install Agents
echo -e "\n${BLUE}Installing selected agents...${NC}"

for i in "${selected_indices[@]}"; do
    agent_key="${agents_keys[$i]}"
    target_file="$AGENTS_DIR/$agent_key.md"
    
    # Check if exists
    if [ -f "$target_file" ]; then
        overwrite="n"
        if [ "$install_mode" == "args" ]; then
             echo "Agent '$agent_key' already exists. Skipping (use interactive mode to overwrite)."
             continue
        else
            echo -n "Agent '$agent_key' already exists. Overwrite? [y/N] "
            if [ -t 0 ]; then
                read -n 1 -r overwrite
            elif [ -c /dev/tty ]; then
                read -n 1 -r overwrite < /dev/tty
            fi
            echo
        fi
        
        if [[ ! $overwrite =~ ^[Yy]$ ]]; then
            echo "Skipping $agent_key"
            continue
        fi
    fi
    
    echo -n "Installing $agent_key... "
    
    # Attempt local copy first if available (dev mode), else download
    if [ -f "$SCRIPT_DIR/.gemini/agents/$agent_key.md" ]; then
        cp "$SCRIPT_DIR/.gemini/agents/$agent_key.md" "$target_file"
        echo -e "${GREEN}Done (Local)${NC}"
    else
        download_file "$REPO_BASE_URL/.gemini/agents/$agent_key.md" "$target_file"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Done${NC}"
        else
            echo -e "${RED}Failed to download${NC}"
        fi
    fi
done


rm "$TEMP_LIST"
echo -e "\n${GREEN}Installation complete! Agents are located in $AGENTS_DIR${NC}"
