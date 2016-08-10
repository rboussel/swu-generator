Swu-generator
=============

Swu-generator is a generator for sw-description and .swu archive necessary for an update with [SWUpdate](http://sbabic.github.io/swupdate/)

Exemple case 
------------
Currently the generator is made to work with a specific case and use dual copy strategy. 
The example case contains four partitions. There are two Rootfs partitions and two Application partitions.
The generator create two different archives for the update and the app .swu archive is put in an other archive 
which contain a minimal_rootfs_version file. This file specify the minimal rootfs version required for the new application version. 
The sw-description modify also some u-boot variables. 

.Swu Creation 
-------------

To create an archive: 

- Launch swu-generator
- Configure the generator
- Fill in images and archive informations
- Create the archive 
