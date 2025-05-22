# make fresh partition
sudo mkfs.ext4 /dev/sdb1

# make the new home directory 
# mount to the new directory
sudo mount /dev/sdb1 /mnt/newhome

# move data keeping all the attributes
sudo rsync -aHAXv --progress /home/ /mnt/newhome/


blkid /dev/sdb1
# Note the UUID 
sudo vim /etc/fstab
#Example
UUID=123e4567-e89b-12d3-a456-426614174000 /home ext4 defaults 0 2

# noatime - performance options

sudo umount /mnt/newhome
sudo mount /dev/sdb1 /home
ls -la /home