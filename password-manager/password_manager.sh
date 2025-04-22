#!/bin/bash
source src/initialize.sh

main(){
    # Main function will be implemented later
    while true; 
    do
        initialize
        show_menu
    done
}
# $6$3FxfZUzPvC/IIJ66$P.El7d85X/RxKNFbGUhC.1jFN2eb1gEvM3Ge.e9KXW9tQa9kgQsFk2VpXG3B2CRFFs/klL18WaPByeLuX4lU5/

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
            echo "You chose: 'Add new Password'. This feature is not yet implemented."
            ;;
        2)
            echo "You chose: 'Retrieve Password'. This feature is not yet implemented."
            ;;
        3)
            echo "You chose: 'List Accounts'. This feature is not yet implemented."
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
