#!/bin/bash
sudo su
#Устанавливаем утилиту xfsdump, будет нужна для снятия копии с тома /
yum install -y xfsdump
yum install -y xfsprogs
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
        mkfs.xfs /dev/vg_root_temp/lv_root_temp
        mount /dev/vg_root_temp/lv_root_temp /mnt/
        lsblk
    #Копируем все с раздела / в /mnt
        xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt/
    #Должен быть SUCCESS
    #Проверяем что копирование прошло успешно
         ls -l /mnt/
    #Переконфигурируем grub для того, чтобы при старте перейти в новый / (root)
    #Сымитируем текущий root -> сделаем в него chroot и обновим grub:
         for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
    #Изменение корневого каталога диска
         chroot /mnt/
    #Сгенерировать конфигурацию GRUB2 в файл
         grub2-mkconfig -o /boot/grub2/grub.cfg
    #Обновляем образ initrd
         cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;s/.img//g"` --force; done
    #Для того, чтобы при загрузке был смонтирован нужны root заменяем значения
         sed -i 's/VolGroup00\x2FLogVol00/vg_root_temp\x2Flv_root_temp/g' /boot/grub2/grub.cfg
         