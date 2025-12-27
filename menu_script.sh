#!/bin/bash

####################################################################### 
                        # function to create table #
#######################################################################                        

createTable() {
    read -p "enter the table name: " tablename
    
   
    if [ -f "$current_db/$tablename" ]; then
        echo "table $tablename already exist "
    else 
        PK=""
        sep="|"
        metadata=""
       
        read -p "enter the number of coloums: " colnum 
        if [ $colnum -le 0 ];
        then 
        echo " you entered invalid number "
        return  ;
        fi 
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
                        # function to insert into table #
##########################################################################   
insert_into_table() 
{
   read -p "enter the table name you want to insert into " tablename
   if [ ! -f "$current_db/$tablename" ];
   then 
   echo " this table not exist "  
   else
   IFS='|' read -r -a colarray < "$current_db/$tablename.metadata"
   row=""
    for colmeta in "${colarray[@]}"
    do 
    IFS=':' read -r colname coltype ispk <<< "$colmeta"
    while true ; 
    do 
     read -p "enter value for $colname ($coltype) " value 
     if [ "$coltype" == "int" ]; 
     then 
     if ! [[ "$value" =~ ^[0-9]+$ ]] ;
     then 
     echo "invalid input , please enter an integer "
     continue 
     fi
     elif [ "$coltype" == "date" ];
     then 
     if ! [[ "$value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
     then 
     echo "invalid date type ,please enter yyyy-mm-dd "
     continue
     fi 
     fi
     if [ "$ispk" == "PK" ];
     then 
     if awk -F: -v val="$value" '$1 == val || val == "" {found=1; exit} END {if (!found) exit 1}' "$current_db/$tablename" ; 
     then 
     echo " invalid pk , it must be unique and not null "
     continue 
     fi
     fi
     if [[ $value == *":"* ]] ;
     then 
     echo "you can't use ":" in the value "
     continue
     fi
     break 

   done

    if [ -z "$row" ];
    then 
    row="$value"
    else 
    row+=":$value"
    fi

    done
    echo "$row" >> "$current_db/$tablename"
    echo "row inserted successfully"

    fi 

}                    

#############################################################################
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
    ## 
          3) read -p "enter the table name you want to drop : " tablename
          if [ -f "$current_db/$tablename" ];
          then 
          rm "$current_db/$tablename" "$current_db/$tablename.metadata"
          echo "this table dropped successfully "
          else 
          echo "this table not exist " 
          fi
          
          
          ;;

          4) insert_into_table ;;

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
