#!/bin/bash
sudo su
#Создаем временный том для /var
        lsblk
        #Создаемм PV
        pvcreate /dev/sdc
        #Создаемм VG
        vgcreate vg_home /dev/sdc
        #Создаемм LV
        lvcreate -L 2G -n lv_home vg_home
        #Создаем ФС на новом томе и монтируем
        mkfs.xfs /dev/vg_home/lv_home
        mount /dev/vg_home/lv_home /mnt
        cp -aR /lv_home/* /mnt/
        rm -rf /home/*
        #Отмонтируем новый /home от /mnt
        umount /mnt
        #Монтируем новый /var в var
        mount /dev/vg_home/lv_home /home
        #Правим fstab для монтирования /home при старте системы
        echo "`blkid | grep home: | awk '{print $2}'` /var xfs defaults 0 0" >> /etc/fstab