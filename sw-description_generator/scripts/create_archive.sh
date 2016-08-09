#!/bin/bash
# create_archive.sh - Script to create a signed .swu archive due to the sw-description file.

FILES="sw-description sw-description.sig"
IS_APP_MAJ="false"
IS_ROOTFS_MAJ="false"

launch_swu_creation () {
  date=$(date "+%F")

  #Verif if app configs changed
  if [ $APP_VERSION = $PREV_APP_VERSION -a $APP_NAME = $PREV_APP_NAME ]
  then  dialog --title "Création de l'archive de mise à jour" --msgbox "[APP] Version non modifiée" 8 30 
  else 
    IS_APP_MAJ="true"
    lauch_creation "application" $APP_NAME $APP_VERSION $APP_MAIN_DEVICE $APP_ALT_DEVICE $date "APP"
    PREV_APP_NAME=$APP_NAME
    PREV_APP_VERSION=$APP_VERSION
  fi

  #Verif if rootfs configs changed
  if [ $ROOTFS_VERSION = $PREV_ROOTFS_VERSION -a $PREV_ROOTFS_NAME = $ROOTFS_NAME ]
  then dialog --title "Création de l'archive de mise à jour" --msgbox "[ROOTFS] Version non modifiée" 8 30
  else 
    IS_ROOTFS_MAJ="true"
    lauch_creation "rootfs" $ROOTFS_NAME $ROOTFS_VERSION $ROOTFS_MAIN_DEVICE $ROOTFS_ALT_DEVICE $date "ROOTFS"
    PREV_ROOTFS_NAME=$ROOTFS_NAME
    PREV_ROOTFS_VERSION=$ROOTFS_VERSION
  fi

  #If an archive is created, generate a version file
  if [ "$IS_APP_MAJ" == "true" -o "$IS_ROOTFS_MAJ" == "true" ]
  then
    write_version_file; 
    show_version_file; 
    IS_APP_MAJ="false"; 
    IS_ROOTFS_MAJ="false";
  fi
  MENU_CHOICE="MAIN_WINDOW"
 }

show_version_file () {
  
  result=$(dialog --no-lines --title 'Version file' --backtitle 'Add Comments' --editbox  $VERSION_FILE 30 90 2>&1 1>&3)
  echo -e "$result" > $VERSION_FILE

}

write_version_file () {
 
  if [ $IS_APP_MAJ = "true" ]; then 
  echo -e " \
  # Fichier de Mise à jour -- $(date)\n \
  # \n \
  # [ APPLICATION ] \n \
  # Commentaires: \n \
  # \n \
  # \n \
  # \n \
  # \n \
  # \n\
  Nom: $APP_NAME Version: $APP_VERSION Version Rootfs minimale: $CURRENT_ROOTFS_VERSION \n \n " > $VERSION_FILE
  fi

  if [ $IS_ROOTFS_MAJ = "true" ]; then 
  echo -e " \
  # [ ROOTFS ] \n \
  # Commentaires: \n \
  # \n \
  # \n \
  # \n \
  # \n \
  # \n\
  Nom: $ROOTFS_NAME Version: $ROOTFS_VERSION \n \n" >> $VERSION_FILE
  fi

}

# Make Application and Rootfs archives
lauch_creation () {

  fill_in_swdescription $1 $SOURCE_DIR $2 $3 $COMPATIBILITY $4 $5
  compute_hash $SOURCE_DIR 
  configure_swdescription_sig $PRIVATE_KEY_PATH $SOURCE_DIR
  if [ $OTHER_PARAM = "no" ]
  then 
    create_swu $SOURCE_DIR $DESTINATION_DIR $6 $7 $3 $REBOOT_STATE 
  else 
    create_swu $SOURCE_DIR $DESTINATION_DIR $6 $7 $3 $REBOOT_STATE $OTHER_PARAM
  fi
}

# Fill sw-description template with variables values
  fill_in_swdescription () {
  #Copy the right template in source dir
  cp "$GENERATOR_TEMPLATE_DIR/$1/sw-description" "$2/sw-description"
  sed -i "s/@version/$4/" "$2/sw-description"
  sed -i "s/@compatibility/$5/" "$2/sw-description"
  sed -i "s/@filename/$3/" "$2/sw-description"
  sed -i "s#@main_device#$6#" "$2/sw-description"
  sed -i "s#@alt_device#$7#" "$2/sw-description"
  }
 
# Compute images hashes
compute_hash(){

  names=$( cat $1/sw-description | sed -n '/@/p' | cut -d@ -f2 | uniq )
  for name in $names;do
	FILES+=" $name";
  #Pour le moment c'est que dans le dossier source
	sha256=$(sha256sum "$1/$name" | cut -d ' ' -f1 )
	sed -i "s/@$name/\"$sha256\";/"  "$1/sw-description" ; done ;
}

# Create the signature
configure_swdescription_sig(){
	if test -f $1
	then
		openssl dgst -sha256 -sign $1 "$2/sw-description" > "$2/sw-description.sig"
	else
		echo "Private key doesn't exist"
		exit 1
	fi
}

# Put files in the cpio archive
create_swu(){
	cd $1
  clear 
  archive_name="$3_$4_$5_$6_$7.swu"

  for file in $FILES; do
		echo $file;done | cpio -ov -H crc > "$DESTINATION_DIR/$archive_name"
    FILES="sw-description sw-description.sig"
  rm "sw-description" "sw-description.sig"
  cd - 
  if [ $4 = "APP" ]; then create_app_archive "$DESTINATION_DIR/$archive_name" $3 $5 ; fi
}

create_app_archive () {
  
  echo $CURRENT_ROOTFS_VERSION > $MINIMAL_ROOTFS_VERSION_FILE
  files="$1 $MINIMAL_ROOTFS_VERSION_FILE"
  for file in $files; do  
    echo $file ;done | cpio -ov -H crc > "$DESTINATION_DIR/$2_APP_$3.swu"
  rm $1 $MINIMAL_ROOTFS_VERSION_FILE
}

