repo_pull(){
# Check if it's a git repository before performing git pull
    if [ -d ".git" ] || git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git pull origin main
        echo "Repository updated."
    else
        echo "Initializing a new git repository..."
        git init
        git remote add origin https://github.com/AnAncientForce/sysZ.git
        git fetch origin main
        git checkout -b main --track origin/main
        echo "Git repository set up. Repository is ready."
fi
}

# Run specific function is specified
if [ "$1" == "--function" ]; then
    shift  # Shift the arguments to skip the "--function" flag
    function_name="$1"
    shift  # Shift again to skip the function name

    # Call the specified function
    "$function_name"
fi