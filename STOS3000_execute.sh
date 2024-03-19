#!/bin/bash

# Function to display main menu
display_main_menu() {
    dialog --clear --backtitle "User Profile Selection" --title "Main Menu" \
    --menu "Choose an option:" 15 60 3 \
    1 "Select Existing Profile" \
    2 "Create New Profile" \
    3 "Exit" \
    2> menu_selection.txt
}

# Function to display existing profiles
display_existing_profiles() {
    profiles=$(ls -d User_* 2>/dev/null)
    if [ -z "$profiles" ]; then
        dialog --clear --backtitle "User Profile Selection" --title "No Profiles Found" \
        --msgbox "No existing profiles found. Please create a new profile." 10 60
        return 1
    else
        profile_array=()
        for profile in $profiles; do
            profile_array+=("$profile" "")
        done
        dialog --clear --backtitle "User Profile Selection" --title "Existing Profiles" \
        --menu "Choose a profile to run:" 15 60 5 "${profile_array[@]}" \
        2> profile_selection.txt
        return 0
    fi
}

# Function to display prompt for new profile name
display_new_profile_prompt() {
    dialog --clear --backtitle "User Profile Selection" --title "New Profile" \
    --inputbox "Enter the name for the new profile:" 10 60 \
    2> new_profile_name.txt
}

# Function to create a new profile directory
create_new_profile() {
    name=$(cat new_profile_name.txt)
    mkdir "User_$name"
    cp Menu_Main.sh "User_$name/"
    chmod -R 755 "User_$name"  # Set appropriate permissions
    cd "User_$name" || exit
    sudo bash Menu_Main.sh
    cd ..
}

# Main script logic
while true; do
    display_main_menu
    choice=$(cat menu_selection.txt)

    case $choice in
        1)
            display_existing_profiles
            if [ $? -eq 0 ]; then
                selected_profile=$(cat profile_selection.txt)
                cd "$selected_profile" || exit
                sudo bash Menu_Main.sh
                cd ..
            else
                continue
            fi
            ;;
        2)
            display_new_profile_prompt
            create_new_profile
            ;;
        3)
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select again."
            ;;
    esac
done
