current_dir=$(pwd)
cd "/home/$(whoami)/sysZ"

if [ -d ".git" ] || git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git remote update >/dev/null 2>&1
    if [ "$(git rev-parse HEAD)" != "$(git rev-parse @{u})" ]; then
        python /home/$(whoami)/sysZ/main.py update_confirmation
    else
        echo "No updates available."
    fi
fi
