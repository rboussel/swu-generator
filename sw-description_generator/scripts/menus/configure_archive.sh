#!/bin/bash
# configure_archive.sh - A shell script to configure the swu archive
archive_config () {
  
  OPTIONS=(1 "Reboot prioritaire ($REBOOT_STATE) --->" 
           2 "Paramètre à ajouter au nom ($OTHER_PARAM) --->")

  CHOICE=$(dialog --clear \
         --extra-button \
         --extra-label "Sauvegarder" \
         --cancel-label "Précédent" \
         --backtitle "Création de sw-description" \
         --title "Configuration de l'archive " \
         --menu "" 20 110 100 "${OPTIONS[@]}" 2>&1 >/dev/tty)
  
  case $? in 
      0)  
          case $CHOICE in 
              1)# Reboot priority
                dialog --title "Reboot prioritaire" --backtitle "Configuration de l'archive" --yesno "Le système doit il redémarrer après la mise à jour ?" 8 60 2>&1 1>&3 
                if [ $? = "0" ]; then REBOOT_STATE="REBOOT"; else REBOOT_STATE="NORMAL"; fi
                IS_CONFIG_SAVED="false"
                MENU_CHOICE="CONFIGURE_ARCHIVE" ;;

              2)# Other parameter
                other_param=$(dialog --title "Paramètre à ajouter au nom" --backtitle "Configuration de l'archive" \
                --inputbox "Entrez la liste des paramètres à ajouter au nom de l'archive" 8 60 $OTHER_PARAM 2>&1 1>&3 | sed "s/ /,/g")
                $VERIFY_INPUT $other_param "OTHER_PARAM"
                MENU_CHOICE="CONFIGURE_ARCHIVE";; 

              *) echo "Option error" ;; 
              esac ;;

      1)# Previous
          MENU_CHOICE="CONFIGURE_IMAGE" ;;
      
      3)# Save
        $SAVE_ENV
        MENU_CHOICE="CONFIGURE_ARCHIVE" ;;

      255)# Escape
          MENU_CHOICE="MAIN_WINDOW" ;; 

      *) echo "Option error" ;; 
      esac
}
