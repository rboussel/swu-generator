#!/bin/sh
# configuration.sh - A shell script to configure sw-description generator 

configuration () {
  # Options for the box 
  OPTIONS=(1 "Dossier de destination ($1) --->"
         2 "Dossier source ($2) --->"
         3 "Chemin vers la clé privée ($3) --->" 
        )
         
   CHOICE=$(dialog --clear \
                --extra-button  \
                --extra-label "Sauvegarder" \
                --cancel-label "Précédent" \
                --backtitle "Configuration de l'outil de mise à jour" \
                --title "Configuration" \
                --menu "" \
                20 150 100 \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)
  # Init variables
  retval=$?
  DESTINATION_DIR=$1
  SOURCE_DIR=$2 
  PRIVATE_KEY_PATH=$3 
  PUBLIC_KEY_PATH=$4 

  case $retval in 
    0) # Get parameters

      case $CHOICE in
        1)              
            DESTINATION_DIR=$(dialog --title "Dossier de destination" \
            --backtitle "Configuration" \
            --inputbox "Entrez le chemin de destination"  8 60 $1 \
             2>&1 1>&3 | sed "s/ /\//g" )
             if [ $DESTINATION_DIR ]
             then 
                configuration  $DESTINATION_DIR $SOURCE_DIR $PRIVATE_KEY_PATH $PUBLIC_KEY_PATH 
             else 
                configuration  $1 $SOURCE_DIR $PRIVATE_KEY_PATH $PUBLIC_KEY_PATH 
             fi
             ;;
        2)
            SOURCE_DIR=$(dialog --title "Dossier source" \
            --backtitle "Configuration " \
            --inputbox "Entrez le chemin source" 8 60 $2\
            2>&1 1>&3 | sed "s/ /\//g"  )
            if [ $SOURCE_DIR ]
             then 
                configuration  $DESTINATION_DIR $SOURCE_DIR $PRIVATE_KEY_PATH $PUBLIC_KEY_PATH 
             else 
                configuration  $DESTINATION_DIR $2 $PRIVATE_KEY_PATH $PUBLIC_KEY_PATH 
             fi
           ;;
            
        3)
            PRIVATE_KEY_PATH=$(dialog --title "Chemin vers la clé privée" \
            --backtitle "Configuration" \
            --inputbox "Entrez le chemin de la clé privée" 8 60 $3 \
            2>&1 1>&3 | sed "s/ /\//g" )
            if [ $PRIVATE_KEY_PATH ]
             then 
                configuration  $DESTINATION_DIR $SOURCE_DIR $PRIVATE_KEY_PATH $PUBLIC_KEY_PATH 
             else 
                configuration  $DESTINATION_DIR $SOURCE_DIR $3 $PUBLIC_KEY_PATH 
                fi
            ;;

            esac 
        ;;
    
    1)  # Get back
        ./"$GENERATOR_SCRIPTS_PATH/swdescription_generator.sh" 
        ;;
    3) # Save
        source "$GENERATOR_SCRIPTS_PATH/save_config"
        configuration $DESTINATION_DIR $SOURCE_DIR $PRIVATE_KEY_PATH $PUBLIC_KEY_PATH 
        ;;
     esac

   }

configuration $DESTINATION_DIR $SOURCE_DIR $PRIVATE_KEY_PATH 


