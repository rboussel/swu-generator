#!/bin/bash
# configuration.sh - A shell script to configure sw-description generator 

configuration () {
  # Options for the box 
  OPTIONS=(1 "Dossier de destination ($DESTINATION_DIR) --->"
         2 "Dossier source ($SOURCE_DIR) --->"
         3 "Chemin vers la clé privée ($PRIVATE_KEY_PATH) --->" 
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
 
  case $retval in 
    0) # Get parameters

      case $CHOICE in
        1)              
            destination_dir=$(dialog --title "Dossier de destination" \
            --backtitle "Configuration" \
            --inputbox "Entrez le chemin de destination"  8 60 $DESTINATION_DIR \
             2>&1 1>&3 | sed "s/ /\//g" )
             if [ $DESTINATION_DIR ]; then DESTINATION_DIR=$destination_dir; IS_CONFIG_SAVED="false" ; fi
             MENU_CHOICE="CONFIGURE_GENERATOR"
             ;;
        2)
            source_dir=$(dialog --title "Dossier source" \
            --backtitle "Configuration " \
            --inputbox "Entrez le chemin source" 8 60 $SOURCE_DIR \
            2>&1 1>&3 | sed "s/ /\//g"  )
            if [ $source_dir ]; then SOURCE_DIR=$source_dir; IS_CONFIG_SAVED="false" ; fi
            MENU_CHOICE="CONFIGURE_GENERATOR"

           ;;
            
        3)
            private_key_path=$(dialog --title "Chemin vers la clé privée" \
            --backtitle "Configuration" \
            --inputbox "Entrez le chemin de la clé privée" 8 60 $PRIVATE_KEY_PATH \
            2>&1 1>&3 | sed "s/ /\//g" )
            if [ $private_key_path ]; then PRIVATE_KEY_PATH=$private_key_path; IS_CONFIG_SAVED="false" ; fi
            MENU_CHOICE="CONFIGURE_GENERATOR"
            ;;
         *) echo "Option error" ;;    

            esac 
        ;;
    
    1)  # Get back
        MENU_CHOICE="MAIN_WINDOW";;
    3) # Save
        $SAVE_ENV
        MENU_CHOICE="CONFIGURE_GENERATOR";;
    255) MENU_CHOICE="MAIN_WINDOW";;
    *) echo "Option error" ;;
     esac
   }




