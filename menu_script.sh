#!/bin/bash

###################################################################
                          # main menu #
###################################################################
Main()
{
welecome

mkdir -p DBS_dir
echo "choose from the following"
PS3="enter your choice " 
select choice in Create_Database List_Database Connect_Database Drop_Database Quit
do
    case $choice in
        Create_Database)
        create_database
        main_display
        ;;

        List_Database)
        echo " the list of data bases " 
        ls ./DBS_dir 
        main_display
        ;;
       
        Connect_Database) 
        Connect_Database
          main_display
        ;;
        
        Drop_Database)
        Drop_Database 
         main_display
         ;;
        Quit)
            break
            ;;
        *) 
            echo "Invalid option" 
            main_display
            ;;
        
    esac
done
}

###################################################################
                          # Welcome #
###################################################################
welecome()
{

    clear
   msg_lines=(
        "####################################################"
        "##          Welcome to Our DBMS Project           ##"
        "##                                                ##"
        "##      This project Designed & Developed By:     ##"
        "##               -> Marwan Helmy                  ##"
        "##               -> Mahmoud Eissa                 ##"
        "##                                                ##"
        "##       Supervised by: Eng Mohamed ElSabugh      ##"
        "####################################################"
    )

    for line in "${msg_lines[@]}"; do        
        length=${#line}
        for (( i=0; i<length; i++ )); do
            echo -n "${line:i:1}"             
            sleep 0.026
        done
        
        echo "" 
    done
    echo ""
    echo "     Starting System..."
  read 
    clear
}
####################################################################### 
                        # function to create data base #
####################################################################### 
create_database()
{
        read -p "enter db name : " dbname 
        if [[ $dbname =~ "*" ]];
        then
        echo "you should not enter '*'"
            return
        fi
        if [ -z $dbname ];
        then
        echo "you should write the name of DB"
            return
        fi

        if [ -d "./DBS_dir/$dbname" ];
        then echo "this data base was already exist "
        else mkdir ./DBS_dir/$dbname
        echo "data base created successfully " 
        fi
        }

####################################################################### 
                        # function connect to data base #
####################################################################### 
Connect_Database()
{

        read -p "enter the data base name " dbname
          if [ ! -d "./DBS_dir/$dbname" ];
          then 
                 echo "this data base not exist "      
          else

          current_db="./DBS_dir/$dbname"
           select choice in "Create Table" "List Table" "Drop Table" "Insert into Table" "Select from Table" "Delete from Table" "Update Table" "Quit"
          do 
          case $REPLY in
          1) createTable 
          connect_display
          ;;

          2) List_Table
            connect_display
                 ;;


          3) Drop_Table
             connect_display
              ;;

          4) insert_into_table
            connect_display
               ;;

          5) Select_From_table 
             connect_display
               ;;
          6)delete_from_table
          connect_display
          ;;
          7) update_table
          connect_display
          ;;
          8) break ;;
          *) echo "invalid option " 
          connect_display
          ;;

          esac 
          done 
            
            fi
            }

####################################################################### 
                        # Drop Database #
#######################################################################    
Drop_Database()
{
      read -p "enter name of DB you want to drop "  dbname 
      if [ -z "$dbname" ];
         then
             echo "you should enter the data base name "
          return
         fi
        if [ ! -d "./DBS_dir/$dbname" ];
        then echo "this data base not exist "
        else rm -r ./DBS_dir/$dbname
        echo "data base dropped successfully " 
        fi
}
####################################################################### 
                        # Create table #
#######################################################################                        

createTable() {
    read -p "enter the table name: " tablename
            if [[ $tablename =~ "*" ]];
        then
        echo "you should not enter '*'"
            return
        fi
                if [ -z $tablename ];
        then
        echo "you should write the name of Table"
            return
        fi
   
    if [ -f "$current_db/$tablename" ]; then
        echo "table $tablename already exist "
    else 
        PK=""
        sep="|"
        metadata=""
       
        read -p "enter the number of columns: " colnum 
        if [ $colnum -le 0 ];
        then 
        echo " you entered invalid number "
        return  ;
        fi 
        read -p "Enter the first column name (primary key) : " pkname 
        
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
            read -p "enter the coloum $count name : " colname 
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
                        # List Table #
##########################################################################  
List_Table() 
{
          if [ -z "$(ls "$current_db")" ];
          then
           echo "No tables, Data base is empty "
           else
            echo "List of Tables:"
            ls "$current_db" | grep -v ".metadata"
            fi
            }

##########################################################################
                        # Drop table #
##########################################################################   
Drop_Table()
           {
          read -p "enter the table name you want to drop : " tablename
      if [ -z "$tablename" ];
         then
             echo "you should enter table name "
          return
         fi
          if [ -f "$current_db/$tablename" ];
          then 
          rm "$current_db/$tablename" "$current_db/$tablename.metadata"
          echo "this table dropped successfully "
          else 
          echo "this table not exist " 
          fi
           }

##########################################################################
                        #  Insert into table #
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
                       # select from table #
#############################################################################
Select_From_table(){
read -p "Enter name of the table you want select from " tablename
if [ ! -f $current_db/$tablename ];
then 
echo "This table not exist"
return
fi

IFS='|' read -r -a metadataarray < "$current_db/$tablename.metadata"
read -p "enter the number of coloums u want seclect if you want to select all colums enter '*' " colnum 

if [[ $colnum =~ "*" ]];
then
wherefunc "$tablename" "all"
return
fi
if ! [[ "$colnum" =~ ^[0-9]+$ ]];
then 
echo " invalid input , enter number or '*' "
return 
fi

col=1
coloumsindex=""
while [ $col -le $colnum ]
do
read -p "enter the colum $col name " colname
foundindex=""
idx=1
for meta in "${metadataarray[@]}" ; 
do 
IFS=':' read -r name _ _ <<< "$meta"
if [ "$name" == "$colname" ] ;
then 
foundindex=$idx 
break 
fi 
((idx++))
done 
if [ -z "$foundindex" ];
then 
echo "coloum not found " 
return 
fi 
 
   if [ -z "$coloumsindex" ];
    then 
    coloumsindex="$foundindex"
    else 
    coloumsindex+=",$foundindex"
    fi

   (( col++ ))
done 
wherefunc "$tablename" "$coloumsindex"

}

###################### where func #################
wherefunc() {
    local tablename=$1
    local coloumsindex=$2

    
    IFS='|' read -r -a metadataarray < "$current_db/$tablename.metadata"
    

    local full_header=""
    for meta in "${metadataarray[@]}"; do
        IFS=':' read -r name _ _ <<< "$meta"
        if [ -z "$full_header" ]; then
            full_header="$name"
        else
            full_header="$full_header:$name"
        fi
    done

    local final_header=""
    if [ "$coloumsindex" == "all" ]; then
        final_header="$full_header"
    else
        final_header=$(echo "$full_header" | cut -d':' -f"$coloumsindex")
    fi

    read -p "enter condition col name (press enter if you don't need condition) " condcol
    
    {
        echo "$final_header"
    
        if [ -z "$condcol" ]; then 
            if [ "$coloumsindex" == "all" ]; then 
                cat "$current_db/$tablename"
            else 
                cut -d':' -f"$coloumsindex" "$current_db/$tablename"
            fi
        else 
            read -p "enter value for $condcol: " condvalue
            condindex=""
            idx=1
            for meta in "${metadataarray[@]}"; do 
                IFS=':' read -r name _ _ <<< "$meta"
                if [ "$name" == "$condcol" ]; then 
                    condindex=$idx
                    break 
                fi
                ((idx++))
            done
            if [ -z "$condindex" ]; then 
                echo "condition col not found " >&2 
                return 
            fi 
            
            if [ "$coloumsindex" == "all" ]; then 
                awk -F: -v c_idx="$condindex" -v c_val="$condvalue" '$c_idx == c_val' "$current_db/$tablename"
            else 
                awk -F: -v c_idx="$condindex" -v c_val="$condvalue" '$c_idx == c_val' "$current_db/$tablename" | cut -d':' -f"$coloumsindex"
            fi
        fi

    } | column -t -s ':' -o ' | ' 
 


}

##############################################################################
                               # delete #
##############################################################################
delete_from_table()
{
read -p "Enter name of the table you want to delete from " tablename
if [ ! -f $current_db/$tablename ];
then 
echo "This table not exist"
return
fi

while true;
do 
read -p "enter condition col name (press enter if you don't need condition) " condcol
if [ -z "$condcol" ];
then
read -p "you will delete all table data [y/n] : " ans
if   [ "$ans" == "y" ];
then
  > "$current_db/$tablename"
  echo "Table data is deleted successfully"
return
fi

else

 IFS='|' read -r -a metadataarray < "$current_db/$tablename.metadata"

            
            condindex=""
            idx=1
            for meta in "${metadataarray[@]}"; do 
                IFS=':' read -r name _ _ <<< "$meta"
                if [ "$name" == "$condcol" ]; then 
                    condindex=$idx
                    break 
                fi
                ((idx++))
            done
            if [ -z "$condindex" ]; then 
                echo "condition col not found "
                continue
            fi 
             read -p "enter value for $condcol: " condvalue

 awk -F: -v idx="$condindex" -v val="$condvalue" ' $idx != val '  "$current_db/$tablename" > "$current_db/$tablename.tmp"

mv "$current_db/$tablename.tmp" "$current_db/$tablename"

echo "Rows deleted successfully"

return
fi
done

}

###############################################################################
                                # update # 
###############################################################################
update_table() {
    read -p "Enter name of the table you want to update: " tablename
    
    if [ ! -f "$current_db/$tablename" ]; then
        echo "This table does not exist"
        return
    fi
    
    IFS='|' read -r -a metadataarray < "$current_db/$tablename.metadata"

    while true; do
        read -p "Enter the number of columns you want to update: " colnum 
        if ! [[ "$colnum" =~ ^[0-9]+$ ]]; then 
            echo "Invalid input, enter integer number : "
            continue 
        fi
        break
    done

    declare -a target_indices
    declare -a new_values
    pk_modified=false
    col=1
    while [ $col -le $colnum ]; do
        read -p "Enter name of column #$col to update: " colname
        
        foundindex=""
        col_type=""
        is_pk=""
        idx=1

        for meta in "${metadataarray[@]}"; do
            IFS=':' read -r name type pk <<< "$meta"
            if [ "$name" == "$colname" ]; then
                foundindex=$idx
                col_type=$type
                is_pk=$pk
                break
            fi
            ((idx++))
        done

        if [ -z "$foundindex" ]; then
            echo "Column '$colname' not found."
            continue 
        fi

        if [ "$foundindex" -eq 1 ]; then
            pk_modified=true
        fi
     
   
         while true; do
             if [ "$col_type" == "date" ];
                then 
             echo "please enter this format 'yyyy-mm-dd'"
            fi
              read -p "Enter new value for $colname ($col_type): " value
            
            if [ "$col_type" == "int" ]; then
                if ! [[ "$value" =~ ^[0-9]+$ ]]; then
                    echo "Invalid input, please enter an integer."
                    continue
                fi
            fi
            
            if [ "$col_type" == "date" ]; then
                
                 if ! [[ "$value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                 echo "invalid input "
                    continue
                 fi
            fi

            if [[ "$value" == *":"* ]]; then
                echo "Value cannot contain ':'."
                continue
            fi

            if  [ "$foundindex" -eq 1 ]; then
                if [[ -z "$value" ]]; then
                    echo "Invalid input: PK cannot be null/empty."
                    continue
                fi
                if cut -d':' -f"$foundindex" "$current_db/$tablename" | grep -w -q "$value"; then
                    echo "Invalid input: PK must be unique. '$value' already exists."
                    continue
                fi
            fi
            break
        done
 
        target_indices+=("$foundindex")
        new_values+=("$value")
        ((col++))
    done 
read -p "Enter the condition column name (Press Enter to update ALL rows): " condcol
    
    update_all=false
    condindex=""

    if [ -z "$condcol" ]; then
        update_all=true
        echo "You are about to update ALL rows."
    else
        idx=1
        
        #loop to get the index number of the condition column 
        for meta in "${metadataarray[@]}"; do 
            IFS=':' read -r name _ _ <<< "$meta"
            if [ "$name" == "$condcol" ]; then 
                condindex=$idx
                break 
            fi
            ((idx++))
        done
        
        if [ -z "$condindex" ]; then 
            echo "Condition column not found."
            return
        fi 
        
        read -p "Enter value for condition ($condcol): " condvalue
    fi
if [ "$pk_modified" = true ]; then
        
        match_count=0
        
        if [ "$update_all" = true ]; then
            match_count=$(wc -l < "$current_db/$tablename")
        else
        readarray -t rows < "$current_db/$tablename"
        for line in "${rows[@]}";
         do
         IFS=':' read -r -a columns <<< "$line"
                current_val="${columns[$((condindex-1))]}"
                clean_row_val=$(echo "$current_val" | xargs)
                clean_user_val=$(echo "$condvalue" | xargs)
                
                if [ "$clean_row_val" == "$clean_user_val" ];
                 then
                    ((match_count++))
                fi
            done 
        fi

        if [ "$match_count" -gt 1 ];
         then
            echo "You can not set the same Primary Key for multible rows"
            return
        fi
    fi
    temp_file="$current_db/$tablename.tmp"
    touch "$temp_file"
    updated_flag=false

    while IFS=':' read -r -a row; do
        
        should_update=false

        if [ "$update_all" = true ]; then
            should_update=true
        else

            current_val="${row[$((condindex-1))]}"
            clean_row_val=$(echo "$current_val" | xargs)
            clean_user_val=$(echo "$condvalue" | xargs)
            
            if [ "$clean_row_val" == "$clean_user_val" ]; then
                should_update=true
            fi
        fi
         # loop to update columns in the matched rows  
        if [ "$should_update" = true ]; then
            for i in "${!target_indices[@]}"; do
                curr_col_idx=${target_indices[$i]} 
                curr_new_val=${new_values[$i]}     
                row[$((curr_col_idx-1))]="$curr_new_val"
            done
            updated_flag=true
        fi
        
        (IFS=':'; echo "${row[*]}") >> "$temp_file"
        
    done < "$current_db/$tablename"

    mv "$temp_file" "$current_db/$tablename"

    if [ "$updated_flag" = true ]; 
    then
             echo "Rows matching condition updated successfully."
    else
        echo "No rows matched the condition."
    fi
}


###################################################################
                          # Display connect menu #
###################################################################

connect_display() 
{
    echo "------------------------------------------------------------"
 echo -e " 1) "Create Table"\t2) "List Table"\t   \t3) "Drop Table"\t4) "Insert into Table"\n 5) "Select from Table"\t6) "Delete from Table"\t7) "Update Table"\t8) "Quit""
}

###################################################################
                          # Display main menu #
###################################################################

main_display()
{
     echo "------------------------------------------------------------"
    echo -e " 1) "Create_Database"\t 2) "List_Database"\n 3) "Connect_Database"\t 4) "Drop_Database"\t 5) "Quit""
}

###################################################################
                          # Call Main #
###################################################################
Main