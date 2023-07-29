current_dir=$(pwd)
cd "/home/$(whoami)/sysZ"

if [ -d ".git" ] || git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if git diff --quiet; then
        echo "No changes detected."
    else
        python /home/$(whoami)/sysZ/main.py update_confirmation
    fi
fi
