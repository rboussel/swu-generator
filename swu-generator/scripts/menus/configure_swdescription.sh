#!/bin/bash
# configure_swdescription.sh - A shell script to configure names and versions of files to include in sw-description

# Get informations about images
images_config () {
  
  # Box options
  OPTIONS=(1 "Nom de l'Application ($APP_NAME) --->" 
           2 "Version de l'Application ($APP_VERSION) --->" 
           3 "Nom du rootfs ($ROOTFS_NAME) --->"
           4 "Version du rootfs ($ROOTFS_VERSION) --->"
           5 "Fichiers supplémentaires ($ADDED_FILES) --->"
           6 "Suite")
 
  CHOICE=$(dialog --clear \
         --extra-button \
         --extra-label "Sauvegarder" \
         --cancel-label "Précédent" \
         --backtitle "Création de sw-description" \
         --title "Configuration des images" \
         --menu "" 20 150 100 "${OPTIONS[@]}" 2>&1 >/dev/tty)
      
  case $? in 
  # 0) "Accepter" pressed - Show the corresponding box
  # 1) "Précédent" pressed - Go to main window
  # 3) "Sauvegarder" pressed - Save configs
  # 255) Escap pressed - Go to main window
  # *) Other - Print error message

      0)
          case $CHOICE in
              1)# Application name
                app_name=$(dialog --clear --title "Nom de l'application" --backtitle "Création de la mise à jour" \
                --inputbox "Entrez le nom de l'Application" 8 60 $APP_NAME 2>&1 1>&3 | sed "s/ /-/g" )   
                $VERIFY_INPUT $app_name "APP_NAME" 
                MENU_CHOICE="CONFIGURE_IMAGE" ;;

              2)# Application version 
                app_version=$(dialog --title "Version de l'application" --backtitle "Création de la mise à jour" \
                --inputbox "Entrez la version de l'Application" 8 60 $APP_VERSION 2>&1 1>&3 | sed "s/ /./g")
                $TEST_VERSIONS $app_version $CURRENT_APP_VERSION "APP_VERSION" 
                MENU_CHOICE="CONFIGURE_IMAGE" ;;

              3)# Rootfs name
                rootfs_name=$(dialog --title "Nom du rootfs" --backtitle "Création de la mise à jour" \
                --inputbox "Entrez le nom du rootfs" 8 60 $ROOTFS_NAME 2>&1 1>&3 | sed "s/ /-/g")
                $VERIFY_INPUT $rootfs_name "ROOTFS_NAME" 
                MENU_CHOICE="CONFIGURE_IMAGE" ;;
         
              4)# Rootfs version 
                rootfs_version=$(dialog --title "Version du rootfs" --backtitle "Création de la mise à jour" \
                --inputbox "Entrez la version du rootfs" 8 60 $ROOTFS_VERSION 2>&1 1>&3 | sed "s/ /./g")
                $TEST_VERSIONS $rootfs_version $CURRENT_ROOTFS_VERSION "ROOTFS_VERSION"
                MENU_CHOICE="CONFIGURE_IMAGE" ;;

              5)# Added files 
                added_files=$(dialog --title "Fichiers supplémentaires"  --backtitle "Création de la mise à jour" \
                --inputbox "Entrez le chemin des fichiers à ajouter à l'archive de mise à jour" 8 60 $ADDED_FILES 2>&1 1>&3 | sed "s/ /,/g")
                $VERIFY_INPUT $added_files "ADDED_FILES" 
                MENU_CHOICE="CONFIGURE_IMAGE" ;;

              6)# Next page
                MENU_CHOICE="CONFIGURE_ARCHIVE" ;;
        
              *)# Error
                echo "Option error" ;; 
              esac ;;

        1) 
          MENU_CHOICE="MAIN_WINDOW" ;;

        3)
          CURRENT_APP_VERSION=$APP_VERSION
          CURRENT_ROOTFS_VERSION=$ROOTFS_VERSION
          PREVIOUS_REBOOT_STATE=$REBOOT_STATE

          $SAVE_ENV
          MENU_CHOICE="CONFIGURE_IMAGE" ;; 

        255)
          MENU_CHOICE="MAIN_WINDOW" ;;

        *) echo "Option error" ;;
        esac
}

