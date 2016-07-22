#!/bin/sh
# swdescription_generator.sh - A shell script to print menu and init config variables 

export GENERATOR_CONFIG_FILE="config/generator.config"
export GENERATOR_SCRIPTS_PATH="scripts/"

# Init variables with config file
init_variables () {

  DESTINATION_DIR=$(grep "Destination directory" $GENERATOR_CONFIG_FILE | cut -d= -f2) 
  SOURCE_DIR=$(grep "Source directory" $GENERATOR_CONFIG_FILE | cut -d= -f2) 
  PRIVATE_KEY_PATH=$(grep "Private key" $GENERATOR_CONFIG_FILE | cut -d= -f2) 
  PUBLIC_KEY_PATH=$(grep "Public key" $GENERATOR_CONFIG_FILE | cut -d= -f2) 
  
  echo $DESTINATION_DIR $SOURCE_DIR $PRIVATE_KEY_PATH $PUBLIC_KEY_PATH
  }

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
          1)
            ./$GENERATOR_SCRIPTS_PATH/create_swdescription.sh  
              ;;
          2)
            ./$GENERATOR_SCRIPTS_PATH/configuration.sh $1 $2 $3 $4             
            ;;
          3)
            ./$GENERATOR_SCRIPTS_PATH/create_archive.sh 
            ;;
     esac
     ;;
   1) #Cancel 
     exit
     ;;
    esac
}

exec 3>&1

read DESTINATION_DIR SOURCE_DIR PRIVATE_KEY_PATH PUBLIC_KEY_PATH <<< $(init_variables)
main_window $DESTINATION_DIR $SOURCE_DIR $PRIVATE_KEY_PATH $PUBLIC_KEY_PATH $GENERATOR_CONFIG_FILE

exec 3>&-

unset "GENERATOR_SCRIPTS_PATH"
unset "GENERATOR_CONFIG_FILE"



