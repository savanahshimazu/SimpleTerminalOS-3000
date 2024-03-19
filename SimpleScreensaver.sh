#!/bin/bash

# Function to enable cursor and exit gracefully
exit_screensaver() {
    # Show cursor
    tput cnorm
    # Clear screen
    clear
    exit 0
}

# Trap the interrupt signal (Ctrl+C)
trap exit_screensaver INT

# Hide cursor
tput civis

# Clear screen
clear

# Get terminal size
width=$(tput cols)
height=$(tput lines)

# Initial position and direction of the text
x=$((width / 2))
y=$((height / 2))
dx=1
dy=1

# Main loop
while true; do
    # Clear screen
    clear
    
    # Print the text at current position
    tput cup $y $x
    echo "Timberwolf Software Solutions"
    
    # Update position
    x=$((x + dx))
    y=$((y + dy))
    
    # Bounce off edges
    if [ $x -le 0 ] || [ $x -ge $((width - 24)) ]; then
        dx=$((dx * -1))
    fi
    if [ $y -le 0 ] || [ $y -ge $((height - 1)) ]; then
        dy=$((dy * -1))
    fi
    
    # Wait for a short time
    sleep 0.2
done
