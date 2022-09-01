#!/bin/bash
script -a lvreduce.txt
sudo su
#Устанавливаем утилиту xfsdump, будет нужна для снятия копии с тома /
yum install -y xfsdump
#1-Уменьшаем раздел / до 8ГБ
    #Создаем временный том для /
        lsblk
        #Создаемм PV
        pvcreate /dev/sdb
        pvs
        #Создаемм VG
        vgcreate vg_root_temp /dev/sdb
        vgs
        #Создаемм LV
        lvcreate -n lv_root_temp -l +100%FREE /dev/vg_root_temp
        lvs
    #Создаем ФС на новом томе
        makefs.xfs /dev/vg_root_temp/lv_root_temp
        mkdir /mnt/root_temp/
        mount /dev/vg_root_temp/lv_root_temp/mnt/root_temp/
        lsblk
    #Копируем все с раздела / в /mnt
        xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt/root_temp/
    #Должен быть SUCCESS
    #Проверяем что копирование прошло успешно
         ls -l /mnt/root_temp/
    #Переконфигурируем grub для того, чтобы при старте перейти в новый / (root)
    #Сымитируем текущий root -> сделаем в него chroot и обновим grub:
         for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/root_temp/$i; done
    #Изменение корневого каталога диска
         chroot /mnt/root_temp
    #Сгенерировать конфигурацию GRUB2 в файл
         grub2-mkconfig -o /boot/grub2/grub.cfg