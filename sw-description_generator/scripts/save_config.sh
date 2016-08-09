#!/bin/bash
# save_config - A shell script to save environnement variables file

save_config () {

  for var in $(cat $GENERATOR_CONFIG_FILE | cut -d= -f1) 
  do 
    echo "${var}=${!var}" >> "$GENERATOR_CONFIG_FILE.tmp"
  done

  sort -u "$GENERATOR_CONFIG_FILE.tmp" > $GENERATOR_CONFIG_FILE
  rm $GENERATOR_CONFIG_FILE.tmp

  dialog  --title "Confirmation de sauvegarde" --msgbox "Configurations sauvegardés" 8 30 
  IS_CONFIG_SAVED="true"
 
}

save_dialog () {

  dialog  --title "Confirmation de sauvegarde" --yesno "Les configurations vont être sauvegardées" 10 60

  if [ $? = "0" ]
  then 
    save_config
  fi
}

