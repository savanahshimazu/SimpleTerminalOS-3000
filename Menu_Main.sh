#!/bin/bash

# Function to create directories if they don't exist
create_directories() {
    # Check if directories exist
    for dir in "Entertainment" "Utility" "Web"; do
        if [ ! -d "$dir" ]; then
            dialog --title "Creating Directory" --infobox "Creating $dir directory..." 5 50
            sudo mkdir "$dir"
            sudo cp -r ./STOS3000_updater.sh /Utility
            dialog --title "Success" --msgbox "$dir directory created successfully." 10 30
        fi
    done
}

# Function to create encrypted file
create_encrypted_file() {
    dialog --title "Create New User" --clear \
    --inputbox "Enter Username:" 10 30 2> /tmp/username.tmp \
    --passwordbox "Enter Password:" 10 30 2> /tmp/password.tmp

    username=$(cat /tmp/username.tmp)
    password=$(cat /tmp/password.tmp)

    # Save username to file
    echo "$username" > username.txt

    # Encrypt password and store in file
    echo "$password" | openssl aes-256-cbc -salt -out login_info.enc
}

# Function to get login information
get_login_info() {
    dialog --title "Login" --clear \
    --inputbox "Enter Username:" 10 30 2> /tmp/username.tmp \
    --passwordbox "Enter Password:" 10 30 2> /tmp/password.tmp

    username=$(cat /tmp/username.tmp)
    password=$(cat /tmp/password.tmp)

    # Get stored username
    stored_username=$(cat username.txt)

    # Decrypt the password and check if credentials match
    decrypted_password=$(openssl aes-256-cbc -d -salt -in login_info.enc 2>/dev/null)
    if [ "$decrypted_password" == "$password" ] && [ "$stored_username" == "$username" ]; then
        dialog --title "Welcome" --msgbox "Welcome back!" 10 30
    else
        dialog --title "Error" --msgbox "Invalid username or password." 10 30
        exit 1
    fi
}

# Function to check and install required programs silently
check_and_install_programs() {
    programs=("khal" "mutt" "wordgrinder" "sc" "wcalc" "w3m" "w3m-img")
    to_install=()

    for program in "${programs[@]}"; do
        if ! command -v "$program" &> /dev/null; then
            to_install+=("$program")
        fi
    done

    if [ ${#to_install[@]} -gt 0 ]; then
        sudo apt-get update
        sudo apt-get install -y "${to_install[@]}" &>/dev/null
    fi
}

# Function to prompt the user with a logout dialog menu
logout_prompt() {
    # Prompt the user with a dialog menu
    dialog --backtitle "Logout Prompt" --title "Logout Confirmation" --yesno "Would you like to log out?" 10 30

    # Get the exit status of the dialog command
    exit_status=$?

    # Check the user's choice
    if [ $exit_status -eq 0 ]; then
        # User chose Yes
        echo "Goodbye!"
        pkill -TERM -u $USER
        exit
    else
        # User chose No
        sudo bash Menu_Main.sh
    fi
}

# Function to check and install required programs silently
check_and_install_programs() {
    programs=("khal" "mutt" "wordgrinder" "sc" "wcalc" "w3m" "w3m-img" "mc")
    to_install=()

    for program in "${programs[@]}"; do
        if ! command -v "$program" &> /dev/null; then
            to_install+=("$program")
        fi
    done

    if [ ${#to_install[@]} -gt 0 ]; then
        sudo apt-get update
        sudo apt-get install -y "${to_install[@]}" &>/dev/null
    fi
}

# Function to display the submenu
show_submenu() {
    local folder="$1"
    local options=()
    while IFS= read -r -d '' file; do
        options+=("$(basename "$file" .sh)")
    done < <(find "$folder" -type f -name "*.sh" -print0)
    
    options+=("Back")

    while true; do
        local choice
        choice=$(dialog --clear --title "Submenu - $folder" --menu "Choose an option:" 15 50 5 "${options[@]}" 2>&1 >/dev/tty)
        case "$choice" in
            Back) return;;
            *) . "$folder/$choice.sh"; break;;
        esac
    done

    # After execution, return to the main menu
    return 0
}

# Function to display admin menu
admin_menu() {
    dialog --clear --backtitle "Personal Management & Administration" \
    --title "Main Menu" \
    --menu "Choose an option:" 15 50 7 \
    1 "Calendar" \
    2 "Analog Clock" \
    3 "Email Client" \
    4 "Word Processor" \
    5 "Spreadsheets" \
    6 "Calculator" \
    7 "Notes" \
    8 "Dependency Install" \
    9 "Return to Main Menu" 2> /tmp/menu_choice

    choice=$(cat /tmp/menu_choice)
    case $choice in
        1) calendar;;
        2) analog_clock;;
        3) email_client;;
        4) word_processor;;
        5) spreadsheets;;
        6) calculator;;
        7) notes;;
        8) dependency_install;;
        9) ./Menu_Main.sh;;
        *) echo "Invalid option";;
    esac
}

# Function to install dependencies
dependency_install() {
    # Put your dependency installation commands here
    # For example:
    # sudo apt-get install -y calendar_app analog_clock_app email_client_app word_processor_app spreadsheets_app calculator_app notes_app
    echo "Installing dependencies..."
    sleep 2
    sudo apt-get install -y khal mutt wordgrinder sc wcalc
    echo "Dependencies installed successfully."
    sleep 1
    admin_menu
}

# Sample functions for the options
calendar() {
    echo "Launching Calendar..."
    # Put your calendar application launching command here
    khal
    sleep 2
    admin_menu
}

analog_clock() {
    echo "Launching Analog Clock..."
    # Put your analog clock application launching command here
    sleep 2
    admin_menu
}

email_client() {
    echo "Launching Email Client..."
    # Put your email client application launching command here
    mutt
    sleep 2
    admin_menu
}

word_processor() {
    echo "Launching Word Processor..."
    # Put your word processor application launching command here
    wordgrinder
    sleep 2
    admin_menu
}

spreadsheets() {
    echo "Launching Spreadsheets..."
    # Put your spreadsheets application launching command here
    sc
    sleep 2
    admin_menu
}

calculator() {
    echo "Launching Calculator..."
    # Put your calculator application launching command here
    wcalc
    sleep 2
    admin_menu
}

notes() {
    echo "Launching Notes..."
    # Put your notes application launching command here
    sleep 2
    admin_menu
}

if [ ! -e "login_info.enc" ]; then
    create_encrypted_file
fi

get_login_info
check_and_install_programs
create_directories

# Main menu options
options=(
    1 "Programs [Utility]"
    2 "Programs [Web]"
    3 "Programs [Entertainment]"
    4 "Personal"
    5 "File Manager"
)

# Main menu
while true; do
    choice=$(dialog --clear --title "Main Menu" --menu "Choose an option:" 15 50 5 "${options[@]}" 2>&1 >/dev/tty)

    case "$choice" in
        1) show_submenu "Utility";;
        2) show_submenu "Web";;
        3) show_submenu "Entertainment";;
        4) admin_menu;;
        5) mc;;
        *) logout_prompt;;
    esac
done
