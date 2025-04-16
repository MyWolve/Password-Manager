#!/bin/bash

initialize(){
    # Check if the file data/.MASTER exists
    if [ ! -f "password-manager/data/.MASTER" ] 
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
            echo "$MASTER_PASSWORD" > "password-manager/data/.MASTER"
            
            echo "Master saved successfully..."
            return 0
        else
            echo "The passwords do not match. Try again."
        fi
    done
}

check_master_password(){
    echo "Checking master password"
}

