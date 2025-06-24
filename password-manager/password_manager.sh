#!/bin/bash
source src/initialize.sh
source src/passwords.sh
source src/utils.sh

main(){
    initialize
    while true; 
    do
        show_menu
    done
}

show_menu(){
    echo "Password Manager Menu: "
    echo "1. Add new Password"
    echo "2. Retrieve Password"
    echo "3. List Accounts"
    echo "4. Exit"

    echo -n "Please select an option (1-4): "

    read option
    case $option in
        1)
            echo "You chose: 'Add new Password'."
            new_password "$MASTER_PASSWORD"
            ;;
        2)
            echo "You chose: 'Retrieve Password'."
            retrieve_password "$MASTER_PASSWORD"
            ;;
        3)
            echo "You chose: 'List Accounts'."
            list_accounts
            ;;
        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
}

# You may choose to later include arguments to main
main "$@"
