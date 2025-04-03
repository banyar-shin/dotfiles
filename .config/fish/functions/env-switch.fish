# Auto environment switcher for multiple projects

# Define project configurations as key-value arrays
# Format: [project_name, directory_path, conda_env, use_venv]
set -g projects
set -a projects "accomplice-brain" "$HOME/git-repos/ego/accomplice-brain" "accomplice-brain" true
set -a projects "doodlemind" "$HOME/git-repos/side-projects/DoodleMind" "doodlemind" false
# Add more projects easily by adding new entries:
# set -a projects "project_name" "directory_path" "conda_env_name" true/false

# Store the previous directory
set -g PREV_DIR ""

# Function to check directory and activate correct environment
function check_and_activate_env
    set dir $argv[1]
    
    for i in (seq 1 4 (count $projects))
        set project_name $projects[$i]
        set project_dir $projects[(math $i + 1)]
        set conda_env $projects[(math $i + 2)]
        set use_venv $projects[(math $i + 3)]
        
        # Check if we're in this project directory
        if string match -q "$project_dir*" "$dir"
            echo "Already in $project_name directory: Activating environment..."
            conda activate $conda_env
            
            # Activate virtualenv if needed
            if test "$use_venv" = "true"
                if test -f ".venv/bin/activate.fish"
                    source .venv/bin/activate.fish
                end
            end
            
            break
        end
    end
end

# Function to auto switch environment when entering/leaving directories
function auto_env_switch --on-variable PWD
    # Get the current directory
    set CURR_DIR (pwd)
    
    # Check for project entry/exit
    for i in (seq 1 4 (count $projects))
        set project_name $projects[$i]
        set project_dir $projects[(math $i + 1)]
        set conda_env $projects[(math $i + 2)]
        set use_venv $projects[(math $i + 3)]
        
        # Check if we just entered this project directory
        if string match -q "$project_dir*" "$CURR_DIR"; and not string match -q "$project_dir*" "$PREV_DIR"
            echo "Entering $project_name environment..."
            conda activate $conda_env
            
            # Activate virtualenv if needed
            if test "$use_venv" = "true"
                if test -f ".venv/bin/activate.fish"
                    source .venv/bin/activate.fish
                end
            end
        end
        
        # Check if we just left this project directory
        if not string match -q "$project_dir*" "$CURR_DIR"; and string match -q "$project_dir*" "$PREV_DIR"
            echo "Leaving $project_name environment..."
            
            # Deactivate virtualenv if it was used
            if test "$use_venv" = "true"
                command -q deactivate && deactivate
            end
            
            # Deactivate conda environment
            conda deactivate
        end
    end
    
    # Update the previous directory
    set -g PREV_DIR "$CURR_DIR"
end

# Run initialization check on shell startup
if status --is-interactive
    # Initialize PREV_DIR to avoid false "just entered" triggers
    set -g PREV_DIR (pwd)
    
    # Check if we're already in a project directory when opening a new terminal
    check_and_activate_env (pwd)
end
