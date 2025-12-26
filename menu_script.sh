#!/bin/bash

####################################################################### 

createTable() {
    read -p "enter the table name: " tablename
    
    # We use $current_db which is defined in the main script
    if [ -f "$current_db/$tablename" ]; then
        echo "table $tablename already exist "
    else 
        PK=""
        sep="|"
        metadata=""
       
        read -p "enter the number of coloums: " colnum 
        read -p "enter the primary key name: " pkname 
        
        echo " choose the type of pk " 
        select choice in int str 
        do
            case $REPLY in 
                1) pktype="int"; break ;;
                2) pktype="str"; break ;;
                *) echo "invalid choice";;
            esac 
        done 

        metadata+="$pkname:$pktype:PK" 

        count=2

        while [ $count -le $colnum ] 
        do 
            read -p "enter the coloum name: " colname 
            echo "choose the data type of the coloum " 
            select choice in int str date 
            do 
                case $REPLY in 
                    1) coltype="int"; break ;;
                    2) coltype="str"; break ;;
                    3) coltype="date"; break ;;
                    *) echo "invalid choice";;
                esac 
            done 
            metadata+="$sep$colname:$coltype" 
            (( count ++ ))
        done 
        
        touch "$current_db/$tablename"
        echo "$metadata" > "$current_db/$tablename.metadata"
        echo "Table '$tablename' created successfully!"
    fi 
}

##########################################################################


mkdir -p DBS_dir
echo "choose from the following"
PS3="enter your choice " 
select choice in Create_Database List_Database Connect_Database Drop_Database Quit
do
    case $choice in
        Create_Database)
        read -p "enter db name : " dbname 
        if [ -d "./DBS_dir/$dbname" ];
        then echo "this data base was already exist "
        else mkdir ./DBS_dir/$dbname
        echo "data base created successfully " 
        fi
        ;;
        ####################################################################
        List_Database)
        echo " the list of data bases " 
        ls ./DBS_dir 
        ;;
        #######################################################################
        Connect_Database)
        read -p "enter the data base name " dbname
          if [ -d "./DBS_dir/$dbname" ];
          then 
          current_db="./DBS_dir/$dbname"
           select choice in "Create Table" "List Table" "Drop Table" "Insert into Table" "Select from Table" "Delete from Table" "Update Table" "Quit"
          do 
          case $REPLY in
          1) createTable ;;

    #####################################
          2) echo " list table" 
          echo "List of Tables:"
            ls "$current_db" | grep -v ".metadata"
                 ;;
    ################################################
    ## we will handle these cases later 
          3) echo "drop table " ;;
          4)echo "insert into table" ;;
          5)echo "select from table " ;;
          6)echo "delete table " ;;
          7)echo "updata" ;;
          8) break ;;
          *) echo "invalid option " ;;
#######################################
          esac 
          done 
      
          else 
              echo "this data base not exist " 

          fi

          
        ;;
        
        Drop_Database);;
        Quit)
            break
            ;;
        *) 
            echo "Invalid option" 
            ;;
        
    esac
done
