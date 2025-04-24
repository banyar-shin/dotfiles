# Auto environment switcher for multiple projects

# Store the previous directory
set -g PREV_DIR ""
# Store the directory where we last activated an environment
set -g LAST_ENV_DIR ""
# Cache conda environments
set -g CONDA_ENVS

# Cache for environment lookups
set -g ENV_CACHE_DIRS
set -g ENV_CACHE_VALS

# Function to find conda environment from directory path
function find_conda_env_from_path
    set dir $argv[1]
    
    # Skip empty directory
    if test -z "$dir"
        return 1
    end
    
    # Check cache first
    set idx (contains -i $dir $ENV_CACHE_DIRS)
    if test $status -eq 0
        set cached_env $ENV_CACHE_VALS[$idx]
        if test -n "$cached_env"
            echo $cached_env
            return 0
        end
        return 1
    end
    
    set dir_parts (string split '/' $dir)
    
    # Start from the current directory and move up
    for i in (seq (count $dir_parts) -1 1)
        set test_dir (string join '/' $dir_parts[1..$i])
        set dir_name $dir_parts[$i]
        
        # Skip empty directory name
        if test -z "$dir_name"
            continue
        end
        
        # Check if there's a conda environment with this name
        if contains $dir_name $CONDA_ENVS
            # Cache the result
            set -a ENV_CACHE_DIRS $dir
            set -a ENV_CACHE_VALS $dir_name
            echo $dir_name
            return 0
        end
    end
    
    # Cache negative result
    set -a ENV_CACHE_DIRS $dir
    set -a ENV_CACHE_VALS ""
    return 1
end

# Function to check and activate virtualenv
function check_and_activate_venv
    set dir $argv[1]
    
    if test -d "$dir/.venv"
        if test -f "$dir/.venv/bin/activate.fish"
            echo "Found virtualenv in directory: Activating..."
            source "$dir/.venv/bin/activate.fish"
            return 0
        end
    end
    return 1
end

# Function to check directory and activate correct environment
function check_and_activate_env
    set dir $argv[1]
    
    # Skip empty directory
    if test -z "$dir"
        return
    end
    
    # Skip if we're going deeper into a directory where we already have an environment
    if test -n "$LAST_ENV_DIR" && string match -q "$LAST_ENV_DIR*" "$dir"
        return
    end
    
    set found_env 0
    
    # Try to find a conda environment based on directory names
    if set env_name (find_conda_env_from_path $dir); and test -n "$env_name"
        echo "Found conda environment '$env_name' for directory: Activating..."
        conda activate $env_name
        set found_env 1
    end
    
    # Check for virtualenv in the current directory
    # We check this even if we found a conda env, as some projects use both
    if check_and_activate_venv $dir
        set found_env 1
    end
    
    # If we found either type of environment, update LAST_ENV_DIR
    if test $found_env -eq 1
        set -g LAST_ENV_DIR "$dir"
    end
end

# Function to auto switch environment when entering/leaving directories
function auto_env_switch --on-variable PWD
    # Get the current directory
    set CURR_DIR (pwd)
    
    # Skip empty directory
    if test -z "$CURR_DIR"
        return
    end
    
    # Only check if we're actually changing directory trees
    if not string match -q "$PREV_DIR*" "$CURR_DIR" || not string match -q "$CURR_DIR*" "$PREV_DIR"
        # Check if we just left a directory with an active environment
        if not string match -q "$PREV_DIR*" "$CURR_DIR"
            set deactivated 0
            
            # Check if we need to deactivate a virtualenv
            if test -d "$PREV_DIR/.venv"
                echo "Leaving directory with virtualenv: Deactivating..."
                command -q deactivate && deactivate
                set deactivated 1
            end

            # Try to find the previous environment
            if set prev_env (find_conda_env_from_path $PREV_DIR); and test -n "$prev_env"
                echo "Leaving directory with conda environment '$prev_env': Deactivating..."
                conda deactivate
                set deactivated 1
            end
            
            if test $deactivated -eq 1
                set -g LAST_ENV_DIR ""
            end
        end
        
        # Check if we entered a new directory that might have an environment
        if not string match -q "$CURR_DIR*" "$PREV_DIR"
            check_and_activate_env $CURR_DIR
        end
    end
    
    # Update the previous directory
    set -g PREV_DIR "$CURR_DIR"
end

# Run initialization check on shell startup
if status --is-interactive
    # Initialize PREV_DIR to avoid false "just entered" triggers
    set -g PREV_DIR (pwd)
    
    # Cache conda environments at startup
    set -g CONDA_ENVS (conda env list | string match -r '^[^#\s]+\s' | string trim)
    
    # Check if we're already in a directory with an environment
    check_and_activate_env (pwd)
end
