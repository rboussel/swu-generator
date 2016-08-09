#!/bin/bash
# main_menu.sh - A shell script to print main menu

# Print menu
main_window () {

  # Options for the box
  OPTIONS=(1 "Configuration des images et de l'archive --->"
         2 "Configuration du générateur de mise à jour ---> "
         3 "Création d'une mise à jour --->")

  CHOICE=$(dialog --clear \
                --backtitle "Générateur d'archive de  mise à jour" \
                --title "Générateur d'archive de mise à jour" \
                --cancel-label "Quitter" \
                --menu "" 10 60 4 "${OPTIONS[@]}" 2>&1 >/dev/tty)
    
  case $? in 
      0) #Chose an option 
          case $CHOICE in
              1)# Configure sw-description
                MENU_CHOICE="CONFIGURE_IMAGE" ;;

              2)# Configure the generator
                MENU_CHOICE="CONFIGURE_GENERATOR" ;;

              3)# Create .swu archive
                if [ $IS_CONFIG_SAVED = "false" ]; then $SAVE_ENV; fi
                MENU_CHOICE="CREATE_SWU" ;;

              esac ;;
   
      1)# Cancel
        clear
        exit 0 ;;

      esac
}


 





