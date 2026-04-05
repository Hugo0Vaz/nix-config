{ pkgs }:

pkgs.writeShellScriptBin "spawnTmux" ''
    # Session name
    SESSION_NAME="start"

    # Check if the tmux server is running
    if ! tmux info &> /dev/null; then
        echo "tmux server is not running. Starting tmux server with custom configuration..."
        tmux -f ~/.tmux.conf start-server
    fi

    # Try to attach to the session named $SESSION_NAME
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo "Attaching to existing session: $SESSION_NAME"
        tmux -f ~/.tmux.conf attach-session -t "$SESSION_NAME"
    else
        echo "Creating new session: $SESSION_NAME"
        tmux -f ~/.tmux.conf new-session -s "$SESSION_NAME"
    fi
''
