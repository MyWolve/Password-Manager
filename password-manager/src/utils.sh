list_accounts(){
    if [ -z "$(ls data/passwords/)" ]
    then
        echo "No accounts available. Try creating one!"
        return 1;
    else
        echo $(ls -l data/passwords)
    fi
}