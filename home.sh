#!/bin/bash
sudo su
#Создаем временный том для /var
        lsblk
        #Создаемм PV
        pvcreate /dev/sdc
        #Создаемм VG
        vgcreate vg_home /dev/sdc
        #Создаемм LV
        lvcreate -l 50%FREE -n lv_home /dev/vg_home
        #Создаем ФС на новом томе и монтируем
        mkfs.xfs /dev/vg_home/lv_home
        mount /dev/vg_home/lv_home /mnt
        cp -aR /home/* /mnt/
        rm -rf /home/*
        #Отмонтируем новый /home от /mnt
        umount /mnt
        #Монтируем новый /var в var
        mount /dev/vg_home/lv_home /home
        #Правим fstab для монтирования /home при старте системы
        echo "`blkid | grep home: | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
        #Генерируем файлы в /home 
        touch /home/file{1..20}
        ls -l /home
        #Создаем LV для спапшота
        lvcreate -L 2G -s -n home_snap /dev/vg_home/lv_home
        lvs
        #Проверки использования места снапшотом
        dmsetup status
        #Удалить файлы
        rm -f /home/file{11..20}
    #Восстановиться из снапшота
        #Отмантировать /home
        umount /home
        #Сделанм слияние снапшота с исходным LV
        lvconvert --merge /dev/vg_home/lv_home
        #Монтируем обратно /home
        mount /home
        ls -l /home


