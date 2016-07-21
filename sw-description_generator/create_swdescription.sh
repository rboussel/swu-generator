#!/bin/sh
# images_config - A shell script to configure names and versions of files to include in sw-description

# Get information about images
images_config () {

  OPTIONS=(1 "Nom de l'Application ($1) --->" 
           2 "Version de l'Application ($2) ---> " 
           3 "Nom du rootfs ($3) --->"
           4 "Version du rootfs ($4) --->"
           5 "Fichiers supplémentaires ($5) --->"
           6 "Suite")

  CHOICE=$(dialog --clear \
         --extra-button \
         --extra-label "Sauvegarder" \
         --cancel-label "Précédent" \
         --backtitle "Création de sw-description" \
         --title "Configuration des images " \
         --menu "" \
         20 70 100 \
         "${OPTIONS[@]}" \
         2>&1 >/dev/tty)
 
  retval=$?

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
           if [ $APP_NAME  ]
           then
              images_config $APP_NAME $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES $6 $7 $8 
           else 
              images_config $1 $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES $6 $7 $8 
           fi
            ;;

        2)# Application version 
          APP_VERSION=$(dialog --title "Version de l'application" \
           --backtitle "Création de la mise à jour" \
           --inputbox "Entrez la version de l'Application" 8 60 $2 \
           2>&1 1>&3 | sed "s/ /./g")
           if [ $APP_VERSION ]
           then 
             images_config $APP_NAME $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES $6 $7 $8 
            else
             images_config $APP_NAME $2 $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES $6 $7 $8 
             fi
          ;;

        3)# Rootfs name
          ROOTFS_NAME=$(dialog --title "Nom du rootfs" \
           --backtitle "Création de la mise à jour" \
           --inputbox "Entrez le nom du rootfs" 8 60 $3 \
           2>&1 1>&3 | sed "s/ /-/g")
           if [ $ROOTFS_NAME ]
           then 
             images_config $APP_NAME $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES $6 $7 $8 
           else
             images_config $APP_NAME $APP_VERSION $3 $ROOTFS_VERSION $ADDED_FILES $6 $7 $8 
             fi
            ;;

        4)# Rootfs version 
           ROOTFS_VERSION=$(dialog --title "Version du rootfs" \
           --backtitle "Création de la mise à jour" \
           --inputbox "Entrez la version du rootfs" 8 60 $4 \
           2>&1 1>&3 | sed "s/ /./g")
           if [ $ROOTFS_VERSION ]
           then 
             images_config $APP_NAME $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES $6 $7 $8 
           else
             images_config $APP_NAME $APP_VERSION $ROOTFS_NAME $4 $ADDED_FILES $6 $7 $8 
             fi
           ;;

        5)# Added files 
          ADDED_FILES=$(dialog --title "Fichiers supplémentaires"  \
           --backtitle "Création de la mise à jour" \
           --inputbox "Entrez le chemin des fichiers à ajouter à l'archive de mise à jour" 8 60 $5 \
           2>&1 1>&3 | sed "s/ /,/g")
           if [ $ADDED_FILES ]
           then 
             images_config $APP_NAME $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES $6 $7 $8 
           else
             images_config $APP_NAME $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $5 $6 $7 $8 
           fi
           ;;

        6) #Next page
          archive_config $APP_NAME $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES $6 $7 $8 
          ;;
        esac
       ;;
    1) 
       ./swdescription_generator.sh
       ;;
    3) 
        write_config $APP_NAME $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES $6 $7 $8 
        images_config $APP_NAME $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES $6 $7 $8 
       ;; 
    255) 
       ./swdescription_generator.sh 
       ;;
      
    esac
}

# Get information about archive
archive_config () {
  
  OPTIONS=(1 "Version de l'Archive ($6) --->" 
           2 "Reboot prioritaire ($7) --->" 
           3 "Paramètre à ajouter au nom ($8) --->")

  CHOICE=$(dialog --clear \
         --extra-button \
         --extra-label "Sauvegarder" \
         --cancel-label "Précédent" \
         --backtitle "Création de sw-description" \
         --title "Configuration de l'archive " \
         --menu "" \
         20 70 100 \
         "${OPTIONS[@]}" \
         2>&1 >/dev/tty)
 
  retval=$?

  ARCHIVE_VERSION=$6
  REBOOT_STATE=$7
  OTHER_PARAM=$8

  case $retval in 
    0)  
      case $CHOICE in 

      1)# Archive version
        ARCHIVE_VERSION=$(dialog --title "Version de l'archive" \
           --backtitle "Configuration de l'archive" \
           --inputbox "Entrez la version de l'archive" 8 60 $6 \
           2>&1 1>&3 | sed "s/ /./g")
        if [ $ARCHIVE_VERSION ]
           then 
             archive_config $1 $2 $3 $4 $5 $ARCHIVE_VERSION $REBOOT_STATE $OTHER_PARAM 

           else
             archive_config $1 $2 $3 $4 $5 $6 $REBOOT_STATE $OTHER_PARAM 
            fi
        ;;

      2) # Reboot priority
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
           archive_config $1 $2 $3 $4 $5 $ARCHIVE_VERSION $REBOOT_STATE $OTHER_PARAM 
        ;;

      3)# Other parameter
        OTHER_PARAM=$(dialog --title "Paramètre à ajouter au nom" \
           --backtitle "Configuration de l'archive" \
           --inputbox "Entrez la liste des paramètres à ajouter au nom de l'archive" 8 60 $8 \
           2>&1 1>&3 | sed "s/ /,/g")
        if [ $OTHER_PARAM ]
           then 
             archive_config $1 $2 $3 $4 $5 $ARCHIVE_VERSION $REBOOT_STATE $OTHER_PARAM
           else
             archive_config $1 $2 $3 $4 $5 $ARCHIVE_VERSION $REBOOT_STATE $8
            fi
        ;;
      esac
      ;;
    1)#Previous
      images_config  $1 $2 $3 $4 $5 $ARCHIVE_VERSION $REBOOT_STATE $OTHER_PARAM 
      ;;
      
    3)# Save
       write_config  $1 $2 $3 $4 $5 $ARCHIVE_VERSION $REBOOT_STATE $OTHER_PARAM
       archive_config  $1 $2 $3 $4 $5 $ARCHIVE_VERSION $REBOOT_STATE $OTHER_PARAM

;;
    255)
       ./swdescription_generator.sh;;
   esac
}

init_variables () {

  CONFIG_FILE="generator.config"
 
  APP_NAME=$(grep "Application name" $CONFIG_FILE | cut -d= -f2)  
  APP_VERSION=$(grep "Application version" $CONFIG_FILE | cut -d= -f2)  
  ROOTFS_NAME=$(grep "Rootfs name" $CONFIG_FILE | cut -d= -f2)  
  ROOTFS_VERSION=$(grep "Rootfs version" $CONFIG_FILE | cut -d= -f2)  
  ADDED_FILES=$(grep "Added files" $CONFIG_FILE | cut -d= -f2)  
  ARCHIVE_VERSION=$(grep "Archive version" $CONFIG_FILE | cut -d= -f2)  
  REBOOT_STATE=$(grep "Reboot state" $CONFIG_FILE | cut -d= -f2)  
  OTHER_PARAM=$(grep "Other parameter" $CONFIG_FILE | cut -d= -f2)  

  echo $APP_NAME $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES $ARCHIVE_VERSION $REBOOT_STATE $OTHER_PARAM

  }

replace_word () {

  value=$(grep "$2" "$1" | cut -d= -f2)
  sed -i "s/$value/"$3"/" $1 
}


write_config () {
  
 config_file="generator.config"
 replace_word  $config_file "Application name=" "$1"
 replace_word  $config_file "Application version=" $2
 replace_word  $config_file "Rootfs name=" $3
 replace_word  $config_file "Rootfs version=" $4
 replace_word  $config_file "Added files=" $5
 replace_word  $config_file "Archive version=" $6
 replace_word  $config_file "Reboot state=" $7 
 replace_word  $config_file "Other parameter=" $8

}

read APP_NAME APP_VERSION ROOTFS_NAME ROOTFS_VERSION ADDED_FILES ARCHIVE_VERSION REBOOT_STATE OTHER_PARAM <<< $(init_variables)

images_config $APP_NAME $APP_VERSION $ROOTFS_NAME $ROOTFS_VERSION $ADDED_FILES $ARCHIVE_VERSION $REBOOT_STATE $OTHER_PARAM

