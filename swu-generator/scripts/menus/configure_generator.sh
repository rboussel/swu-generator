#!/bin/bash
# configure_generator.sh - A shell script to configure sw-description generator 

generator_config() {
  # Options for the menu 
  OPTIONS=(1 "Dossier de destination ($DESTINATION_DIR) --->"
         2 "Dossier source ($SOURCE_DIR) --->"
         3 "Chemin vers la clé privée ($PRIVATE_KEY_PATH) --->" )
         
  CHOICE=$(dialog --clear \
         --extra-button \
         --extra-label "Sauvegarder" \
         --cancel-label "Précédent" \
         --backtitle "Configuration de l'outil de mise à jour" \
         --title "Configuration" \
         --menu "" 20 150 100 "${OPTIONS[@]}" 2>&1 >/dev/tty)
 
  case $? in
      0) # Get the selected parameter
          
          case $CHOICE in
              1)# Destination directorie path              
                destination_dir=$(dialog --title "Dossier de destination"  --backtitle "Configuration" --inputbox "Entrez le chemin de destination" 8 60 $DESTINATION_DIR \
                2>&1 1>&3 | sed "s/ /\//g" )
                $VERIFY_INPUT $destination_dir "DESTINATION_DIR" 
                MENU_CHOICE="CONFIGURE_GENERATOR";;

              2)# Source dir path
                source_dir=$(dialog --title "Dossier source" --backtitle "Configuration " --inputbox "Entrez le chemin source" 8 60 $SOURCE_DIR 2>&1 1>&3 | sed "s/ /\//g"  )
                $VERIFY_INPUT $source_dir "SOURCE_DIR" 
                MENU_CHOICE="CONFIGURE_GENERATOR";;
            
              3)# Private key path
                private_key_path=$(dialog --title "Chemin vers la clé privée" --backtitle "Configuration" --inputbox "Entrez le chemin de la clé privée" 8 60 \
                $PRIVATE_KEY_PATH 2>&1 1>&3 | sed "s/ /\//g" )
                $VERIFY_INPUT $private_key_path "PRIVATE_KEY_PATH" 
                MENU_CHOICE="CONFIGURE_GENERATOR";;

              *) echo "Option error" ;;    
              esac ;;
    
      1) # Get back
         MENU_CHOICE="MAIN_WINDOW" ;;

      3) # Save
         $SAVE_ENV
         MENU_CHOICE="CONFIGURE_GENERATOR" ;;

      255) MENU_CHOICE="MAIN_WINDOW" ;;

      *) echo "Option error" ;;
      esac
   }




