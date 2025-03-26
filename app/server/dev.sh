#!/bin/bash

# Directory to watch
WATCH_DIR="Sources"
COMMAND="swift run"

# Start process
echo "Starting process..."
$COMMAND &
PID=$!

# Watch for file changes
fswatch -o -r "$WATCH_DIR" | while read; do
    echo "Change detected! Restarting process..."
    
    # Kill the previous process
    kill $PID
    wait $PID 2>/dev/null
    
    # Restart process
    $COMMAND &
    PID=$!
done
