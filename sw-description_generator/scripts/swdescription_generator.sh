#!/bin/sh
# swdescription_generator.sh - A shell script to print menu and init config variables 

#Script Configuration
export GENERATOR_CONFIG_FILE="config/generator.config"
export GENERATOR_SCRIPTS_PATH="scripts/"
export GENERATOR_TEMPLATE_DIR="template"
source $GENERATOR_CONFIG_FILE

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
                --menu "" \
                10 60 4 \
                "${OPTIONS[@]}"\
                2>&1 >/dev/tty)
  retval=$?
  
  case $retval in 
  0) #Chose an option 
    case $CHOICE in
          1)# Configure sw-description 
            source $GENERATOR_SCRIPTS_PATH/create_swdescription.sh  
              ;;
          2)# Configure the generator
            source $GENERATOR_SCRIPTS_PATH/configuration.sh            
            ;;
          3)# Create .swu archive 
            source $GENERATOR_SCRIPTS_PATH/create_archive.sh 
            ;;
     esac
     ;;
   1) #Cancel 
     exit 0
     ;;
    esac
}

exec 3>&1

main_window 

exec 3>&-

unset "GENERATOR_SCRIPTS_PATH"
unset "GENERATOR_CONFIG_FILE"
unset "GENERATOR_TEMPLATE_DIR"
exit 0


