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
}

generate_password(){
    local passwd=$(openssl rand -base64 24)
    echo $passwd
}

encrypt_password(){
    local master="$1"
    local passwd="$2"
    local encrypted_password=$(echo "$passwd" | openssl enc -aes-256-cbc -pbkdf2 -a -iter 10000 -pass "pass:$master") 
    echo $encrypted_password
}

new_password(){
    local master="$1"
    while true; do
        echo "Please enter an account name (exit with 'q'): "
        read user

        if [ "$user" == "q" ]
        then
            echo "Returning to main menu..."
            return 0
        else
            local account_name="$user"
            if [ ! -d "data/passwords" ]
            then
                mkdir data/passwords
            fi
            if [ -f "data/passwords/$account_name" ]
            then
                echo "Account already exists, would you like to overwrite it?: (y/n)"
                read user
                if [ $user == 'y' ]
                then
                    local new_password=$(generate_password)
                    local enc_password=$(encrypt_password $master $new_password)
                    echo "$enc_password" > "data/passwords/$account_name"
                    echo "Succesfully overwritten $account_name"
                else
                    echo "No actions taken. Returning..."
                    continue
                fi
            else
                echo "You are creating account: $account_name. Are you sure? (y/n)"
                read user
                if [ $user == 'y' ]
                then
                    local new_password=$(generate_password)
                    local enc_password=$(encrypt_password $master $new_password)
                    touch data/passwords/$account_name
                    echo "$enc_password" > "data/passwords/$account_name"
                    echo "Successfully created $account_name and stored password"
                else
                    echo "No actions taken. Returning..."
                    continue
                fi
            fi
        fi
    done
}
