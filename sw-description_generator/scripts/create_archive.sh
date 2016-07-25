#!/bin/sh
# create_archive.sh - Script to create a signed .swu archive due to the sw-description file.

FILES="sw-description sw-description.sig"

main () {

  date=$(date "+%F")
  lauch_creation "application" $APP_NAME $APP_VERSION $APP_MAIN_DEVICE $APP_ALT_DEVICE $date "APP" 
  lauch_creation "rootfs" $ROOTFS_NAME $ROOTFS_VERSION $ROOTFS_MAIN_DEVICE $ROOTFS_ALT_DEVICE $date "ROOTFS" 
 }

# Make Application and Rootfs archives
lauch_creation () {

  fill_in_swdescription $1 $SOURCE_DIR $2 $3 $COMPATIBILITY $4 $5
  compute_hash $SOURCE_DIR 
  create_swdescription_sig $PRIVATE_KEY_PATH $SOURCE_DIR
  create_swu $SOURCE_DIR $DESTINATION_DIR $6 $7 $3 $REBOOT_STATE $OTHER_PARAM
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
create_swdescription_sig(){
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
#que dans les sources aussi 
	cd $1
	for file in $FILES; do
		echo $file;done | cpio -ov -H crc > "$2/$3_$4_$5_$6_$7.swu"
	#rm sw-description sw-description.sig 
  FILES="sw-description sw-description.sig"
  cd -
}

main
exit 0
