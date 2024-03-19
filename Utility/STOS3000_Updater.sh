#!/bin/bash

# Function to display error message and exit
display_error() {
    dialog --title "Error" --msgbox "$1" 10 40
    exit 1
}

# Function to clone repository and update files
update_files() {
    # Clone the repository into Update_Temp folder
    sudo git clone "$1" ./Update_Temp || display_error "Failed to clone repository."

    # Copy files from Update_Temp to parent directory
    sudo cp -r ./Update_Temp/* . || display_error "Failed to copy files."
    sudo cp -r ./Update_Temp/STOS3000_updater.sh ./Utility
    sudo rm -r ./Update_Temp

    # Change permissions recursively
    sudo chmod -R 777 .
}

# Display input box to get GitHub link
github_link="https://github.com/savanahshimazu/SimpleTerminalOS3000.git"

# Check if link is provided
if [ -z "$github_link" ]; then
    display_error "GitHub link not provided."
fi

# Check if git is installed
if ! command -v git &> /dev/null; then
    display_error "Git is not installed. Please install Git and try again."
fi

# Navigate to the parent directory
cd .

# Check if Update_Temp directory exists, if not create it
if [ ! -d "Update_Temp" ]; then
    mkdir Update_Temp || display_error "Failed to create Update_Temp directory."
fi

# Update files
update_files "$github_link"

# Display success message
dialog --title "Success" --msgbox "Update completed successfully." 10 40
