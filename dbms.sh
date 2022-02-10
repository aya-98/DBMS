
 #!/bin/bash
 
 
  
 csep=" : "
rSep="\n"


function main_menu {
  echo -e "\n    Main Menu "
  echo " 1) Create Database "
  echo " 2) List Database "
  echo " 3) Connect to Database "
  echo " 4) Drop Database "
  echo -e " 5) Exit \n  "
 
  
  read -p  " Enter Choice: " c
  case $c in
    
    1)  create_db ;;
    2)  ls ./databases; main_menu;;
    3)  connect_db ;;
    4)  drop_db ;;
    5)  exit ;;
    
    *) echo " Wrong Choice " ; main_menu ;
  esac
}



function connect_db {
  
  read -p "Enter Database Name: " 
  cd ./databases/$REPLY
  if [[ $? != 0 ]]; then
    echo "Database $REPLY doesn't exist"
    main_menu
    
    else
    echo -e "\n now you are connecting to $REPLY Database "
     second_menu
  
    fi
  
}


function create_db {
  
  read -p "Enter Database Name: "
  mkdir ./databases/$REPLY
  if [[ $? != 0 ]]
  then
    echo "Error Database $REPLY already exists enter another name "
    
  else
    echo -e "\n  Database  $REPLY is created Successfully "
  fi
   
  main_menu
}


function drop_db {
  
  read "Enter Database Name: "
  rm -r ./databases/$REPLY 
  if [[ $? != 0 ]]; then
    echo "Database Not found"
  
   else
    echo -e "\n  Database  $REPLY is droped  "
  fi
  main_menu
}

function second_menu {
  echo -e "\n  Table Menu "
  
  echo "1) Create New Table   "
  echo "2) List existing Tables  "
  echo "3) Drop Table        "
  echo "4) Insert Into Table  "
  echo "5) Select From Table  "
  echo "6) Delete From Table "
  echo "7) Update Table   " 
  echo "8) Back To Main Menu   "
  echo -e "9) Exit  \n    "
  
 
  read -p "Enter Choice: " c
  case $c in
    2)  ls ; second_menu ;;
    1)  create_table ;;
    4)  insert_table;;
    5)  clear; select_menu ;;
    7)  update_table;;
    6)  delete_table;;
    3)  drop_table;;
    8) clear; cd ../.. ; main_menu ;;
    9) exit ;;
    *) echo " Wrong Choice " ; second_menu;
  esac

}

function create_table {


    while [ true ]
    do
    
  read  -p "Enter Table Name: " tname
  if [ -f $tname ]
   then
    echo "table already exists , Enter another name"
    continue
  fi
  read -p  "Enter Number of Columns: " cnum
  
  counter=1
  
  temp=""
  table_struc="Column"$csep"Datatype"$csep"key"
  
  echo  " Enter column defination as following columnName datatype( int or str )  pk[ optional ]"
  
  echo " ex:  id int pk "
  
  while [ $counter -le $cnum ]
  do
   
    
    flag= true
    while [ $flag=true ]
    do
      cname="" ; ctype="" ; key="" ;
      echo " Enter field no.$counter : " 
      read cname ctype key
      #echo $cname $ctype $key
     if [[ ( $cname != "" &&  $cname != "pk" )  && ( $ctype = "int" || $ctype = "str" )  ]]
     then
        
        flag= false
        break
        
       else
         echo " Enter a valid format for field defination "
      fi
       
    done
    
    
    table_struc+=$rSep$cname$csep$ctype$csep$key;
    
    
    if [ $counter = $cnum ]
     then
      temp=$temp$cname
      
    else
      temp=$temp$cname$csep
    fi
    ((counter++))
    
  done
  
  touch .$tname
  echo -e $table_struc  >> .$tname
  touch $tname
  echo -e $temp >> $tname
  if [[ $? == 0 ]]
  then
    echo -e "\n Table Created Successfully"
    break
  else
    echo -e "\n Error Creating Table $tname"
    break
  fi
  done
  
  second_menu
}

function drop_table {
  
  read -p "Enter Table Name: " tName
  
  if [[ -f $tName ]]
  then
    rm $tName .$tName ;
    echo "Table Dropped Successfully"
  else
    echo " Table $tName isn't existed "
  fi
  second_menu
}

function insert_table {

   read -p " Enter Table name : " tname
   
  if ! [[ -f $tname ]] ; then
    
    echo "Table $tname isn't existed "
    second_menu
  fi
  
  cnum=`awk 'END{print NR}' .$tname`
  value=""
  row=""
  for (( i = 2; i <= $cnum; i++ )); do
    cname=$(awk 'BEGIN{FS=" : "}{ if(NR=='$i') print $1}' .$tname)
    ctype=$( awk 'BEGIN{FS=" : "}{if(NR=='$i') print $2}' .$tname)
    key=$( awk 'BEGIN{FS=" : "}{if(NR=='$i') print $3}' .$tname)
    
    
   
    read -p "Enter value of column $cname  = " value

    # Validate Input
    
    if [[ $ctype == "int" ]]; then
      while ! [[ $value =~ ^[0-9]*$ ]]; do
        echo -e "invalid DataType please enter numbers!! "
        read -p "Enter value of column $cname  = " value
      done
    fi

    if [[ $key == "pk" ]]; then
      while [[ true ]]
      
       do
      
      if [[ $value =~ ^[`awk 'BEGIN{FS=" : " ; ORS=" "}{if(NR != 1)print $(('$i'-1))}' $tname`]$ ]]
       then
      
      echo -e " Primary Key must be unique this value already exists enter another value!!"
          
         elif [[ $value == "" ]] ; then 
         
         echo -e "  primary key shouldn't be null please enter a value"
           
        else
          break;
        fi
        read -p "Enter value of column $cname  = " value
      done
      fi

    #Set row
    if [[ $i == $cnum ]]; then
      row=$row$value$rSep
    else
      row=$row$value$csep
    fi
  done
  echo -e $row"\c" >> $tname
  if [[ $? == 0 ]]
  then
    echo -e "\n Data Inserted Successfully"
  else
    echo -e "\n Error while Inserting into Table $tname"
  fi
  
  second_menu
}
 



function update_table {

  ans=y
         while [[ $ans = [yY] ]]  
         do
  read -p "Enter Table Name: " tName
  
  if ! [[ -f $tName ]] ; then
    
    echo "Table $tName isn't existed "
    break
  fi
  
  read -p "Enter Column name to set : " col
  
  cid=$(awk 'BEGIN{FS=" : "}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$col'") print i}}}' $tName)
  if [[ $cid == "" ]]
  then
    echo "this column doesn't exist"
      break
      fi
      
    
    read -p "Enter Value that you what to update: " old_val
    row=""
    row=$(awk 'BEGIN{FS=" : "}{if ($'$cid'=="'$old_val'") print NR}' $tName)
    if [[ $row == "" ]]
    then
      echo "this value doesn't exist in $col column " ;
       break ;
    else
      read -p "Enter new Value to set: " new_val
      
        # Validate Input
        cname=$(awk 'BEGIN{FS=" : "}{ if(NR=='$cid'+1) print $1}' .$tName)
    ctype=$( awk 'BEGIN{FS=" : "}{if(NR=='$cid'+1) print $2}' .$tName)
    key=$( awk 'BEGIN{FS=" : "}{if(NR=='$cid'+1) print $3}' .$tName)
    
    
    
   
   
     if [[ $ctype == "int" ]]; then
      while ! [[ $new_val =~ ^[0-9]*$ ]]; do
        echo -e "\n invalid DataType please enter numbers!! "
        read -p "Enter new Value to set: " new_val
      done
    fi
    
    if [[ $key == "pk" ]]; then
      while [[ true ]]
      
       do
      
      if [[ $new_val =~ ^[`awk 'BEGIN{FS=" : " ; ORS=" "}{if(NR != 1)print $'$cid'}' $tName`]$ ]]
       then
      
      echo -e " Primary Key must be unique this value already exists enter another value!!"
          
         elif [[ $new_val == "" ]] ; then 
         
         echo -e "  primary key shouldn't be null please enter a value"
           
        else
          break;
        fi
        read -p "Enter new Value to set: " new_val
      done
      fi

        sed -i ''$row's/'$old_val'/'$new_val'/g' $tName 
        echo -e "/n Row Updated Successfully"
        
        read -p " Do you want to update another time ? Enter ( Y or N ) " ans
     fi 
  done
  
  second_menu
}

function select_menu {
  echo -e "\n\n  Select Menu"
  echo "1) Select without condition "
  echo "2) Select under condition "
  echo -e "3) Back To Table Menu \n "
  
  read -p "Enter Choice: " c
  case $c in
    1) sel_without_condition ;;
    2) sel_under_condition ;;
    3)clear; second_menu ;;
    
  esac
}

function sel_without_condition {
 
 read -p "Enter Table Name: " tName
 
 if ! [[ -f $tName ]] ; then
    
    echo "Table $tName isn't existed "
    second_menu
  fi
 
  select ch in " select all columns without condition " "select Specific column without condition"
  do
  case $REPLY in 
  
 1) column -t -s ' : ' $tName 
  if [[ $? != 0 ]]
  then
    echo "Error During Displaying Table $tName"
  fi
  break
  ;;

2) read -p "Enter Column Name: " col
   cid=$(awk 'BEGIN{FS=" : "}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$col'") print i}}}' $tName)
   awk 'BEGIN{FS=" : "}{print $'$cid'}' $tName 
    break
  ;;
esac
done
select_menu
}



function sel_under_condition {
   
   read -p "Enter Table Name: " tName
   
   if ! [[ -f $tName ]] ; then
    
    echo "Table $tName isn't existed "
    second_menu
  fi
   
   read -p "Enter Condition as field operator value : " col op val
  
   cid=$(awk 'BEGIN{FS=" : "}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$col'") print i}}}' $tName)
  if [[ $cid == "" ]]
  then
    echo " this field doesn't exist "
    
  else
  
  select ch in " select all columns " "select specific column "
   do
   case $REPLY in 
   
   1)  func1 $cid $op $val 0 $tName
      
     break 
    ;;
        
   
    
     2) read -p "Enter column Name: " col2 ;
      fid=$(awk 'BEGIN{FS=" : "}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$col2'") print i}}}' $tName) ;
      func1 $cid $op $val 1 $tName $fid ;
      break 
        ;;
      
   esac
   done
   
   fi
   select_menu
 
}

function func1 {

 if [ $4 = 0 ]
 then
   case $2 in 
   '=') awk 'BEGIN{FS=" : "}{if ( $'$1'=="'$3'" ) print $0}' $5 |  column -t -s ' : '  ;;
   '!=') awk 'BEGIN{FS=" : "}{if ( $'$1'!="'$3'" ) print $0}' $5 |  column -t -s ' : ' ;; 
   '>') awk 'BEGIN{FS=" : "}{if ( $'$1' > "'$3'" ) print $0}' $5  |  column -t -s ' : ' ;; 
   '<') awk 'BEGIN{FS=" : "}{if ( $'$1' < "'$3'" ) print $0}' $5  |  column -t -s ' : ' ;; 
   '>=') awk 'BEGIN{FS=" : "}{if ( $'$1' >= "'$3'" ) print $0}' $5 |  column -t -s ' : ' ;; 
   '<=') awk 'BEGIN{FS=" : "}{if ( $'$1' <= "'$3'" ) print $0}' $5 |  column -t -s ' : '  ;; 
   esac
   
   elif [ $4 = 1  ]
    then
    case $2 in 
   '=') awk 'BEGIN{FS=" : " ; ORS="\n" }{if ( $'$1'=="'$3'" ) print $'$6'}' $5   ;;
   '!=') awk 'BEGIN{FS=" : " ; ORS="\n" }{if ( $'$1'!="'$3'" ) print $'$6'}' $5   ;; 
   '>') awk 'BEGIN{FS=" : " ; ORS="\n" }{if ( $'$1' > "'$3'" ) print $'$6'}' $5   ;; 
   '<') awk 'BEGIN{FS=" : " ; ORS="\n" }{if ( $'$1' < "'$3'" ) print $'$6'}' $5  ;; 
   '>=') awk 'BEGIN{FS=" : " ; ORS="\n" }{if ( $'$1' >= "'$3'" ) print $'$6'}' $5  ;; 
   '<=') awk 'BEGIN{FS=" : " ; ORS="\n" }{if ( $'$1' <= "'$3'" ) print $'$6'}' $5  ;; 
   esac
   fi


}

function delete_table {

  read -p "Enter Table Name: " tName
  
  if ! [[ -f $tName ]] ; then
    
    echo "Table $tName isn't existed "
    second_menu
  fi
  
  read -p "Enter Conditional Column name: " col
   cid=""
   cid=$(awk 'BEGIN{FS=" : "}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$col'") print i}}}' $tName)
  if [[ $cid == "" ]]
  then
    echo " this field doesn't exist "
    
  else
     rec=""
     read -p "Enter Conditional value : " val
    
    rec=$(awk 'BEGIN{FS=" : "}{if ($'$cid'=="'$val'") print NR}' $tName 2>>./.error.log)
    if [ $rec != "" ] 
      then
      sed -i ''$rec'd' $tName 2>>./.error.log
      echo -e "\n Row Deleted Successfully"
     else
      echo -e "\n this Conditional value doesn't exist  "
     fi
     fi
     second_menu
 
}

main_menu




