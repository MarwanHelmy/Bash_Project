#!/bin/bash
echo "choose from the following"
select choice in Create_Database List_Database Connect_Database Drop_Database Quit
do
	case $choice in
		Create_Database) echo "1" ;;
		List_Database) echo "2";;
		Connect_Database);;
		Drop_Database);;
        Quit)
            break
            ;;
        *) 
            echo "Invalid option" 
            ;;
		
	esac
done
