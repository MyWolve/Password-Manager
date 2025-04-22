#!/bin/bash

initialize(){
    # Check if the file data/.MASTER exists
    if [ ! -f "data/.MASTER" ] 
    then
        create_master_password
    else
        check_master_password
    fi
}

create_master_password(){
    echo "Creating master password..."

    while true; do
        echo "Enter master password: "
        read master

        echo "Enter master password again: "
        read masterCopy
        
        if [ "$master" == "$masterCopy" ]
        then
            export MASTER_PASSWORD=$(openssl passwd -6 -salt $(openssl rand -base64 16) "$master") 
            touch data/.MASTER
            echo "$MASTER_PASSWORD" > "data/.MASTER"
            
            echo "Master saved successfully..."
            return 0
        else
            echo "The passwords do not match. Try again."
        fi
    done
}

get_salt(){
    echo "$1" | cut -d '$' -f 3
}

check_master_password(){
    echo "Checking master password"
    local password_hash=$(cat data/.MASTER)
    local password_salt=$(get_salt "$password_hash")
    while true; do
        echo "Please enter master password: "
        # User enters password
        read userPassword
        # Stored in global variable
        MASTER_PASSWORD=$userPassword
        # Calculate hash of input with selected salt
        local user_hash=$(openssl passwd -6 -salt $password_salt "$MASTER_PASSWORD")
        # Compare user hash with password hash
        if [ $password_hash == $user_hash ]
        then
            # If match, they're (probably) the same so exit.
            echo "Passwords match. Continuing..."
            return 0
        # Otherwise, try again.
        else
            echo "Passwords do not match. Try again."
        fi
    done
    #echo "$password_hash"
    #echo "$password_salt"
}
