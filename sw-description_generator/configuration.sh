#!/bin/sh
# configuration.sh - A shell script to configure sw-description generator 

configuration () {
  # Options for the box 
  OPTIONS=(1 "Dossier de destination"
         2 "Dossier source"
         3 "Chemin vers la clé privée" 
         4 "Chemin vers la clé publique"
         5 "Chemin vers le fichier de configuration")
   CHOICE=$(dialog --clear \
                --extra-button  \
                --extra-label "Sauvegarder" \
                --backtitle "Configuration de l'outil de mise à jour" \
                --title "Configuration" \
                --menu "" \
                100 100 100 \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)
  # Init variables
  retval=$?
  DESTINATION_DIR=$1
  SOURCE_DIR=$2 
  PRIVATE_KEY_PATH=$3 
  PUBLIC_KEY_PATH=$4 
  CONFIG_FILE=$5

  case $retval in 
    0) # Get parameters

      case $CHOICE in
        1)              
            DESTINATION_DIR=$(dialog --title "Dossier de destination" \
            --backtitle "Configuration" \
            --inputbox "Entrez le chemin de destination"  8 60 $1 \
             2>&1 1>&3 )
             if [ $? = "0" ]
             then 
                configuration  $DESTINATION_DIR $SOURCE_DIR $PRIVATE_KEY_PATH $PUBLIC_KEY_PATH $CONFIG_FILE
             else 
                configuration  $1 $SOURCE_DIR $PRIVATE_KEY_PATH $PUBLIC_KEY_PATH $CONFIG_FILE
             fi
             ;;
        2)
            SOURCE_DIR=$(dialog --title "Dossier source" \
            --backtitle "Configuration " \
            --inputbox "Entrez le chemin source" 8 60 $2\
            2>&1 1>&3 )
            if [ $? = "0" ]
             then 
                configuration  $DESTINATION_DIR $SOURCE_DIR $PRIVATE_KEY_PATH $PUBLIC_KEY_PATH $CONFIG_FILE
             else 
                configuration  $DESTINATION_DIR $2 $PRIVATE_KEY_PATH $PUBLIC_KEY_PATH $CONFIG_FILE
             fi


            ;;
            
        3)
            PRIVATE_KEY_PATH=$(dialog --title "Chemin vers la clé privée" \
            --backtitle "Configuration" \
            --inputbox "Entrez le chemin de la clé privée" 8 60 $3 \
            2>&1 1>&3)
            if [ $? = "0" ]
             then 
                configuration  $DESTINATION_DIR $SOURCE_DIR $PRIVATE_KEY_PATH $PUBLIC_KEY_PATH $CONFIG_FILE
             else 
                configuration  $DESTINATION_DIR $SOURCE_DIR $3 $PUBLIC_KEY_PATH $CONFIG_FILE
             fi

            ;;
        4)
            PUBLIC_KEY_PATH=$(dialog --title "Chemin vers la clé publique" \
            --backtitle "Configuration" \
            --inputbox "Entrez le chemin de la clé publique" 8 60 $4 \
            2>&1 1>&3)
            if [ $? = "0" ]
             then 
                configuration  $DESTINATION_DIR $SOURCE_DIR $PRIVATE_KEY_PATH $PUBLIC_KEY_PATH $CONFIG_FILE
             else 
                configuration  $DESTINATION_DIR $SOURCE_DIR $PRIVATE_KEY_PATH $4 $CONFIG_FILE
             fi

            ;;
        5)
            CONFIG_FILE=$(dialog --title "Chemin vers le fichier de configuration" \
            --backtitle "Configuration" \
            --inputbox "Entrez le chemin du fichier de configuration du système de mise à jour" 8 60 \
            2>&1 1>&3 $5 )
            if [ $? = "0" ]
             then 
                configuration  $DESTINATION_DIR $SOURCE_DIR $PRIVATE_KEY_PATH $PUBLIC_KEY_PATH $CONFIG_FILE
             else 
                configuration  $DESTINATION_DIR $SOURCE_DIR $PRIVATE_KEY_PATH $PUBLIC_KEY_PATH $5
             fi

            ;;
      esac 
      ;;
    
    1)  # Get back
        ./swdescription_generator.sh $DESTINATION_DIR $SOURCE_DIR $PRIVATE_KEY_PATH $PUBLIC_KEY_PATH $CONFIG_FILE

        ;;
    3) # Save
        write_config $DESTINATION_DIR $SOURCE_DIR $PRIVATE_KEY_PATH $PUBLIC_KEY_PATH $CONFIG_FILE
        ;;
     esac

   }

# Write config variables in sw-description generator config file
write_config () {

  echo -e " \
  Dossier de destination=$1 \n \
  Dossier source=$2 \n \
  Chemin vers la clé privée=$3 \n \
  Chemin vers la clé publique=$4 \n \
  Chemin vers le fichier de configuration=$5 " > $5
}

exec 3>&1

configuration $1 $2 $3 $4 $5
exec 3>&-



