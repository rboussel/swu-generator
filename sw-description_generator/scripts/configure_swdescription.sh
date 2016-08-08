#!/bin/bash
# images_config - A shell script to configure names and versions of files to include in sw-description


compare_versions () {
 
  major_current=$(echo $1 | cut -d. -f1)
  major_new=$(echo $2 | cut -d. -f1)
  if [ $major_new  -gt $major_current ]
  then 
    echo "yes"
  elif [ $major_new  -eq $major_current ]
  then
    minor_current=$(echo $1 | cut -d. -f2)
    minor_new=$(echo $2 | cut -d. -f2)
    if [ $minor_new -gt $minor_current ]
    then 
      echo "yes"
    elif [ $minor_new -eq $minor_current ]
    then 
      revision_current=$(echo $1 | cut -d. -f3)
      revision_new=$(echo $2 | cut -d. -f3)
      if [ $revision_new -gt $revision_current ]
      then 
        echo "yes"
      else 
        echo "no"
      fi
    else 
      echo "no"
    fi
  else 
    echo "no"
  fi
}

verif_version_format () {

  number_point=$(echo $1 | grep -o "\." | wc -l )
  if [ "$number_point" = "1" ]
  then
    major=$(echo $1 | cut -d. -f1) 
    minor=$(echo $1 | cut -d. -f2)
    revision="0"
    if [ ! "$minor" ]; then minor="0";fi
  elif [ "$number_point" = "2" ] 
  then 
    major=$(echo $1 | cut -d. -f1) 
    minor=$(echo $1 | cut -d. -f2)  
    revision=$(echo $1 | cut -d. -f3)  
    if [ ! "$minor" ]; then minor="0";fi
    if [ ! "$revision" ]; then revision="0";fi
  else 
    major=$(echo $1 | cut -d. -f1) 
    minor="0"
    revision="0"
  fi
  echo "$major.$minor.$revision"
}

# Get information about images
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
         --menu "" \
         20 150 100 \
         "${OPTIONS[@]}" \
         2>&1 >/dev/tty)
  retval=$?
    
   case $retval in 
    0)
        case $CHOICE in 
        
        1)# Application name   
           app_name=$(dialog --clear --title "Nom de l'application" \
           --backtitle "Création de la mise à jour" \
           --inputbox "Entrez le nom de l'Application" 8 60 $APP_NAME \
           2>&1 1>&3 | sed "s/ /-/g" )   
           # Save the new value 
           if [ $app_name  ]; then APP_NAME=$app_name; fi
           MENU_CHOICE="CONFIGURE_IMAGE" 
            
            ;;

        2)# Application version 
          app_version=$(dialog --title "Version de l'application" \
           --backtitle "Création de la mise à jour" \
           --inputbox "Entrez la version de l'Application" 8 60 $APP_VERSION \
           2>&1 1>&3 | sed "s/ /./g")
           if [ $app_version ] 
           then
             app_version=$(verif_version_format $app_version)
             is_greater=$(compare_versions $CURRENT_APP_VERSION $app_version )
             if [ $is_greater = "yes" ]; then APP_VERSION=$app_version 
             else dialog --msgbox "Version plus ancienne que la version actuelle" 10 30; 
            fi
           fi
           MENU_CHOICE="CONFIGURE_IMAGE" 
          ;;

        3)# Rootfs name
          rootfs_name=$(dialog --title "Nom du rootfs" \
           --backtitle "Création de la mise à jour" \
           --inputbox "Entrez le nom du rootfs" 8 60 $ROOTFS_NAME \
           2>&1 1>&3 | sed "s/ /-/g")
           if [ $rootfs_name ]; then ROOTFS_NAME=$rootfs_name; fi 
           MENU_CHOICE="CONFIGURE_IMAGE" 
          
          ;;

        4)# Rootfs version 
           rootfs_version=$(dialog --title "Version du rootfs" \
           --backtitle "Création de la mise à jour" \
           --inputbox "Entrez la version du rootfs" 8 60 $ROOTFS_VERSION \
           2>&1 1>&3 | sed "s/ /./g")
           if [ $rootfs_version ]
           then 
             rootfs_version=$(verif_version_format $rootfs_version)
             is_greater=$(compare_versions $CURRENT_ROOTFS_VERSION $rootfs_version )
             if [ $is_greater = "yes" ]; then ROOTFS_VERSION=$rootfs_version 
             else dialog --msgbox "Version plus ancienne que la version actuelle" 10 30; fi 
           fi
           MENU_CHOICE="CONFIGURE_IMAGE" 

            ;;

        5)# Added files 
          added_files=$(dialog --title "Fichiers supplémentaires"  \
           --backtitle "Création de la mise à jour" \
           --inputbox "Entrez le chemin des fichiers à ajouter à l'archive de mise à jour" 8 60 $ADDED_FILES \
           2>&1 1>&3 | sed "s/ /,/g")
           if [ $added_files ]; then ADDED_FILES=$added_files; fi
           MENU_CHOICE="CONFIGURE_IMAGE" 
           ;;

        6)# Next page
           MENU_CHOICE="CONFIGURE_ARCHIVE";;
        7)# Error
          echo "Option error" ;; 
        esac
       ;;
    1) 
       MENU_CHOICE="MAIN_WINDOW" 
       ;;
    3)
        CURRENT_APP_VERSION=$APP_VERSION
        CURRENT_ROOTFS_VERSION=$ROOTFS_VERSION
        $SAVE_ENV
        MENU_CHOICE="CONFIGURE_IMAGE" 
       ;; 
    255)
       MENU_CHOICE="MAIN_WINDOW" 
       ;;
    *) echo "Option error" ;;
    esac
}

# Get information about archive
archive_config () {
  
  OPTIONS=(1 "Reboot prioritaire ($REBOOT_STATE) --->" 
           2 "Paramètre à ajouter au nom ($OTHER_PARAM) --->")

  CHOICE=$(dialog --clear \
         --extra-button \
         --extra-label "Sauvegarder" \
         --cancel-label "Précédent" \
         --backtitle "Création de sw-description" \
         --title "Configuration de l'archive " \
         --menu "" \
         20 110 100 \
         "${OPTIONS[@]}" \
         2>&1 >/dev/tty)
  retval=$?
  case $retval in 
    0)  
      case $CHOICE in 

      1) # Reboot priority
          value=$(dialog --title "Reboot prioritaire" \
           --backtitle "Configuration de l'archive" \
           --yesno "Le système doit il redémarrer après la mise à jour ?" 8 60  \
           2>&1 1>&3) 
           if [ $? = "0" ]; then REBOOT_STATE="REBOOT"; else REBOOT_STATE="NORMAL"; fi
           MENU_CHOICE="CONFIGURE_ARCHIVE"
          ;;

      2)# Other parameter
        other_param=$(dialog --title "Paramètre à ajouter au nom" \
           --backtitle "Configuration de l'archive" \
           --inputbox "Entrez la liste des paramètres à ajouter au nom de l'archive" 8 60 $OTHER_PARAM \
           2>&1 1>&3 | sed "s/ /,/g")
        if [ $other_param ]; then OTHER_PARAM=$other_param; fi
        MENU_CHOICE="CONFIGURE_ARCHIVE"
        ;;
      *) echo "Option error" ;; 
      esac
      ;;
    1)# Previous
      MENU_CHOICE="CONFIGURE_IMAGE" 
      ;;
      
    3)# Save
       $SAVE_ENV
       MENU_CHOICE="CONFIGURE_ARCHIVE"
      ;;
    255)# Escape
        MENU_CHOICE="MAIN_WINDOW"  
    *) echo "Option error" ;; 
   esac
}
