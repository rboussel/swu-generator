#!/bin/sh
# images_config - A shell script to configure names and versions of files to include in sw-description

CURRENT_APP_VERSION=$APP_VERSION
CURRENT_ROOTFS_VERSION=$ROOTFS_VERSION

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

#verif_version_format () {}

# Get information about images
images_config () {
  
  # Box options
  OPTIONS=(1 "Nom de l'Application ($1) --->" 
           2 "Version de l'Application ($2) --->" 
           3 "Nom du rootfs ($3) --->"
           4 "Version du rootfs ($4) --->"
           5 "Fichiers supplémentaires ($5) --->"
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
  
  # Init variables
  APP_NAME=$1 
  APP_VERSION=$2 
  ROOTFS_NAME=$3 
  ROOTFS_VERSION=$4 
  ADDED_FILES=$5

   case $retval in 
    0)
        case $CHOICE in 
        
        1)# Application name       
           APP_NAME=$(dialog --clear --title "Nom de l'application" \
           --backtitle "Création de la mise à jour" \
           --inputbox "Entrez le nom de l'Application" 8 60 $1 \
           2>&1 1>&3 | sed "s/ /-/g" )   
           # Save the new value 
           if [ $APP_NAME  ]
           then
              images_config $APP_NAME $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES  $6 $7 
           else 
              images_config $1 $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES  $6 $7 
           fi
            ;;

        2)# Application version 
          APP_VERSION=$(dialog --title "Version de l'application" \
           --backtitle "Création de la mise à jour" \
           --inputbox "Entrez la version de l'Application" 8 60 $2 \
           2>&1 1>&3 | sed "s/ /./g")
           if [ $APP_VERSION ]
           then
             $APP_VERSION=verif_version_format $APP_VERSION
             is_greater=$(compare_versions $CURRENT_APP_VERSION $APP_VERSION ) 
             if [ $is_greater = "yes" ]
             then 
               images_config $APP_NAME $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES  $6 $7 
             else 
               dialog --msgbox "Version plus ancienne que la version actuelle" 10 30; 
               images_config $APP_NAME $2 $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES  $6 $7 
             fi

            else
             images_config $APP_NAME $2 $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES  $6 $7 
             fi
          ;;

        3)# Rootfs name
          ROOTFS_NAME=$(dialog --title "Nom du rootfs" \
           --backtitle "Création de la mise à jour" \
           --inputbox "Entrez le nom du rootfs" 8 60 $3 \
           2>&1 1>&3 | sed "s/ /-/g")
           if [ $ROOTFS_NAME ]
           then 
             images_config $APP_NAME $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES  $6 $7 
           else
             images_config $APP_NAME $APP_VERSION $3 $ROOTFS_VERSION $ADDED_FILES  $6 $7 
             fi
            ;;

        4)# Rootfs version 
           ROOTFS_VERSION=$(dialog --title "Version du rootfs" \
           --backtitle "Création de la mise à jour" \
           --inputbox "Entrez la version du rootfs" 8 60 $4 \
           2>&1 1>&3 | sed "s/ /./g")
           if [ $ROOTFS_VERSION ]
           then 
             is_greater=$(compare_versions $CURRENT_ROOTFS_VERSION $ROOTFS_VERSION )
             if [ $is_greater = "yes" ]
             then 
               images_config $APP_NAME $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES $6 $7 
             else
               dialog --msgbox "Version plus ancienne que la version actuelle" 10 30; 
               images_config $APP_NAME $APP_VERSION $ROOTFS_NAME $4 $ADDED_FILES $6 $7 
             fi
            else 
               images_config $APP_NAME $APP_VERSION $ROOTFS_NAME $4 $ADDED_FILES $6 $7 
            fi
           ;;

        5)# Added files 
          ADDED_FILES=$(dialog --title "Fichiers supplémentaires"  \
           --backtitle "Création de la mise à jour" \
           --inputbox "Entrez le chemin des fichiers à ajouter à l'archive de mise à jour" 8 60 $5 \
           2>&1 1>&3 | sed "s/ /,/g")
           if [ $ADDED_FILES ]
           then 
             images_config $APP_NAME $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES  $6 $7 
           else
             images_config $APP_NAME $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $5  $6 $7 
           fi
           ;;

        6) #Next page
          archive_config $APP_NAME $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES  $6 $7 
          ;;
        esac
       ;;
    1) 
       main_window 
       ;;
    3)
        source "$GENERATOR_SCRIPTS_PATH/save_config" 
        images_config $APP_NAME $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES  $6 $7 
       ;; 
    255)
       main_window
       ;;
      
    esac
}

# Get information about archive
archive_config () {
  
  OPTIONS=(1 "Reboot prioritaire ($6) --->" 
           2 "Paramètre à ajouter au nom ($7) --->")

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

  REBOOT_STATE=$6
  OTHER_PARAM=$7

  case $retval in 
    0)  
      case $CHOICE in 

      1) # Reboot priority
          value=$(dialog --title "Reboot prioritaire" \
           --backtitle "Configuration de l'archive" \
           --yesno "Le système doit il redémarrer après la mise à jour ?" 8 60  \
           2>&1 1>&3) 
           if [ $? = "0" ] 
           then 
             REBOOT_STATE="REBOOT"
           else 
             REBOOT_STATE="NORMAL"
           fi
           archive_config $1 $2 $3 $4 $5  $REBOOT_STATE $OTHER_PARAM 
        ;;

      2)# Other parameter
        OTHER_PARAM=$(dialog --title "Paramètre à ajouter au nom" \
           --backtitle "Configuration de l'archive" \
           --inputbox "Entrez la liste des paramètres à ajouter au nom de l'archive" 8 60 $7 \
           2>&1 1>&3 | sed "s/ /,/g")
        if [ $OTHER_PARAM ]
           then 
             archive_config $1 $2 $3 $4 $5  $REBOOT_STATE $OTHER_PARAM
           else
             archive_config $1 $2 $3 $4 $5  $REBOOT_STATE $7
            fi
        ;;
      esac
      ;;
    1)# Previous
      images_config  $1 $2 $3 $4 $5  $REBOOT_STATE $OTHER_PARAM 
      ;;
      
    3)# Save
       source "$GENERATOR_SCRIPTS_PATH/save_config"
       archive_config  $1 $2 $3 $4 $5  $REBOOT_STATE $OTHER_PARAM
      ;;
    255)# Escape
        main_window  
   esac
}
images_config $APP_NAME $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES $REBOOT_STATE $OTHER_PARAM
