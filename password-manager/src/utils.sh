# List accounts in passwords/ directory
list_accounts(){
    if [ -z "$(ls data/passwords/)" ]
    then
        echo "No accounts available. Try creating one!"
        return 1;
    else
        echo $(ls -l data/passwords)
    fi
}

# Generate a random base64 string that is 24 bytes long
generate_password(){
    local passwd=$(openssl rand -base64 24)
    echo $passwd
}

# Accepts two inputs as parameters, the master password, and the password to be encrypted with it
encrypt_password(){
    local master="$1"
    local passwd="$2"
    local encrypted_password=$(echo "$passwd" | openssl enc -aes-256-cbc -pbkdf2 -a -iter 10000 -pass "pass:$master") 
    # Outputs result of encrypted_password to terminal, so make sure you set up a local variable to catch it
    echo $encrypted_password
}

# Generates a random, encrpyted password corresponding with a provided account name and stores it
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

decrypt_password(){
    local master="$1"
    local ciphertext="$2"
    local decrypted=$(echo "$ciphertext" | openssl enc -d -aes-256-cbc -pbkdf2 -a -iter 10000 -pass "pass:$master")
    if [ $? -eq 0 ]
    then    
        echo $decrypted
        return 0
    else
        echo "Error: Failed to decrypt"
        return 1
    fi
}

# NOTE: This only works by appending a new blank copy/paste to the clipboard. Erasing the clipboard history would require elevated privleges in most cases.
_clipboard(){
    local text="${1:-}"
    case "$(uname -s)" in
        Darwin)
            printf "%s" "$text" | pbcopy ;;
        Linux)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                printf "%s" "$text" | clip.exe
            elif [ -n "$WAYLAND_DISPLAY" ]; then
                printf "%s" "$text" | wl-copy
            elif [ -n "$DISPLAY" ]; then
                printf "%s" "$text" | xclip -selection clipboard 2>/dev/null \
                    || printf "%s" "$text" | xsel --clipboard --input 2>/dev/null
            fi ;;
        MINGW*|CYGWIN*|MSYS*)
            printf "%s" "$text" | clip ;;
    esac
}

display_password(){
    local password="$1"
    local timeout=10

    _clipboard "$password"
    echo "Password copied to clipboard (clears in ${timeout}s from pressing enter)."
    read -p "Press enter to continue..."
    clear
    { sleep "$timeout" && _clipboard; } &
}

retrieve_password(){
    local master="$1"
    if [ -z  "$(ls data/passwords/)" ]
    then
        echo "No passwords available. Try creating one!"
        return 1
    fi
    while true; do
        echo "Please enter an account name: "
        read accName
        if [ ! -f "data/passwords/$accName" ]
        then
            echo "Account $accName does not exist. Try again? (y/n)"
            read user
            if [ $user == 'y' ]
            then
                continue
            else
                echo "Exiting..."
                return 0
            fi
        else
            local encrypted_password=$(cat data/passwords/$accName)
            echo "Confirming Master password..."
            local decryptedPassword=$(decrypt_password "$master" "$encrypted_password")
            if [ $? -eq 0 ]
            then
                echo "Master password matches encrypt! Decrypting..."
                display_password $decryptedPassword
                return 0
            else
                echo "Failed to decrypt"
                return 1
            fi
        fi
    done
}

delete_account(){
    if [ -z "$(ls data/passwords/)" ]
    then
        echo "You don't have any accounts to delete. Consider creating one!"
        return 1
    fi
    while true; do
        echo "Please enter an account name: (enter 'q' to exit)"
        read accName
        if [ $accName == 'q' ]
        then
            echo "Exiting..."
            return 0
        else
            if [ ! -f "data/passwords/$accName" ]
            then
                echo "Account $accName does not exist. Try again? (y/n)"
                read user
                if [ $user == 'y' ]
                then
                    continue
                else
                    echo "Exiting..."
                    return 0
                fi
            else
                echo "Account $accName found. Are you sure you want to delete it? (y/n)"
                read user
                if [ $user == 'y' ]
                then
                    echo "Deleting $accName..."
                    rm data/passwords/$accName
                else
                    echo "Exiting..."
                    return 0
                fi
            fi
        fi
    done
}

change_password(){
    if [ -z "$(ls data/passwords/)" ]
    then
        echo "You don't have any passwords to change. Consider creating one!"
        return 1
    fi
    while true; do
        local master="$1"
        echo "Please confirm master password to continue: (enter 'q' to exit)"
        read pwd
        if [ $pwd == $master ]
        then
            echo "Master password confirmed. Continuing..."
            break
        elif [ $pwd == 'q' ]
        then
            echo "Exiting..."
            return 0
        else
            echo "That's not correct. Try again!"
        fi
    done
        while true; do
        echo "Please enter an account name: (enter 'q' to exit)"
        read accName
        if [ $accName == 'q' ]
        then
            echo "Exiting..."
            return 0
        elif [ ! -f "data/passwords/$accName" ]
            then
                echo "Account $accName does not exist. Try again? (y/n)"
                read user
                if [ $user == 'y' ]
                then
                    continue
                else
                    echo "Exiting..."
                    return 0
                fi
            else
                echo "Account $accName found. Are you sure you want to change this password? (y/n)"
                read user
                if [ $user == 'y' ]
                then
                    echo "Are you sure? This is irreversible! (y/n)"
                    read user
                    if [ $user == 'y' ]
                    then
                        echo "Deleting $accName..."
                        rm data/passwords/$accName
                        echo "Changing $accName password..."
                        
                        local new_password=$(generate_password)
                        local encrypted_password=$(encrypt_password $master $new_password)
                        echo "$encrypted_password" > "data/passwords/$accName"
                        echo "Succesfully overwritten $accName"

                    else
                        echo "Exiting..."
                        return 0
                    fi
                else
                    echo "Exiting..."
                    return 0
                fi
            fi
        done
}