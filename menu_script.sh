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
read -p "enter the number of coloums u want seclect if you want to select all colums enter 'all' " colnum 

if [ $colnum == "all" ];
then
wherefunc "$tablename" "all"
return
fi
if ! [[ "$colnum" =~ ^[0-9]+$ ]];
then 
echo " invalid input , enter number or 'all' "
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



















###########################################
connect_display() 
{
    echo "------------------------------------------------------------"
 echo -e " 1) "Create Table"\t2) "List Table"\t   \t3) "Drop Table"\t4) "Insert into Table"\n 5) "Select from Table"\t6) "Delete from Table"\t7) "Update Table"\t8) "Quit""
}
main_display()
{
     echo "------------------------------------------------------------"
    echo -e " 1) "Create_Database"\t 2) "List_Database"\n 3) "Connect_Database"\t 4) "Drop_Database"\t 5) "Quit""
}





###################################################################
                          # main menu #
###################################################################
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
        main_display
        ;;
        ####################################################################
        List_Database)
        echo " the list of data bases " 
        ls ./DBS_dir 
        main_display
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
          1) createTable 
          connect_display
          ;;

    #####################################
          2)
            echo "List of Tables:"
            ls "$current_db" | grep -v ".metadata"
            connect_display
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
          7)echo "updata" 
          connect_display
          ;;
          8) break ;;
          *) echo "invalid option " 
          connect_display
          ;;
#######################################
          esac 
          done 
      
          else 
              echo "this data base not exist " 

          fi

          main_display
        ;;
        
        Drop_Database)
        read -p "enter name of DB you want to drop "  dbname 
        if [ ! -d "./DBS_dir/$dbname" ];
        then echo "this data base not exist "
        else rm -r ./DBS_dir/$dbname
        echo "data base dropped successfully " 
        fi
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
