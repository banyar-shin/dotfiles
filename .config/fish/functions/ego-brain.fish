# Define the target directory
set -g EGO_BRAIN_DIR /Users/banyar/git-repos/ego/accomplice-brain

# Store the previous directory
set -g PREV_DIR ""

# Function to auto switch environment when entering/leaving the directory
function auto_env_switch --on-variable PWD
    # Get the current directory
    set CURR_DIR (pwd)

    # Check if we just entered the target directory or its subdirectories
    if string match -q "$EGO_BRAIN_DIR*" "$CURR_DIR"; and not string match -q "$EGO_BRAIN_DIR*" "$PREV_DIR"
        echo "Entering $EGO_BRAIN_DIR or a subdirectory: Activating environment..."
        conda activate qa-agent
        source .venv/bin/activate.fish
    end

    # Check if we completely left the target directory and its subdirectories
    if not string match -q "$EGO_BRAIN_DIR*" "$CURR_DIR"; and string match -q "$EGO_BRAIN_DIR*" "$PREV_DIR"
        echo "Leaving $EGO_BRAIN_DIR: Deactivating environment..."
        deactivate
        conda deactivate
    end

    # Update the previous directory
    set -g PREV_DIR "$CURR_DIR"
end
