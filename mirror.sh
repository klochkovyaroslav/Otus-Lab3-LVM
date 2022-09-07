#!/bin/bash
sudo su
#Создаем временный том для /var
        lsblk
        #Создаемм PV
        pvcreate /dev/sdd /dev/sde
        #Создаемм VG
        vgcreate vg_mirror_var /dev/sdd /dev/sde
        #Создаемм LV
        lvcreate -L 950M -m1 -n lv_mirror_var vg_mirror_var
        #Создаем ФС на новом томе и монтируем
        mkfs.ext4 /dev/vg_mirror_var/lv_mirror_var
        mount /dev/vg_mirror_var/lv_mirror_var /mnt
        cp -aR /var/* /mnt/
        #rm -rf /var/*
        #Отмонтируем новый /var от /mnt
        umount /mnt
        #Монтируем новый /var в var
        mount /dev/vg_mirror_var/lv_mirror_var /var
        #Правим fstab для монтирования /var при старте системы
        echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
        init 6
