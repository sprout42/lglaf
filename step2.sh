#!/bin/bash
# another n00b script that roots the phone...
echo "Make sure your phone has full booted into TWRP."
echo
read -n1 -r -p "Press any key to continue..." key

if [ "$KEY" = '' ]; then
        echo "Rooting your phone. It will reboot back into TWRP."
	echo "Don't do anything until your phone has booted back to the OS."
else
        echo "Exiting"
        exit
fi
echo "Unmounting data"
adb shell umount /data
adb shell umount /sdcard
echo
echo "Formatting data"
adb shell mkfs.ext2 /dev/block/bootdevice/by-name/userdata
echo
echo "Mounting data"
adb shell mount /dev/block/bootdevice/by-name/userdata /data
adb shell mount /dev/block/bootdevice/by-name/userdata /sdcard
echo
echo "Mounting system r/w"
adb shell mount -o rw /system
echo
echo "Installing TWRP onto recovery"
adb push h872-twrp.img /sdcard/
adb shell dd if=/sdcard/h872-twrp.img of=/dev/block/bootdevice/by-name/recovery
echo
echo "Making sure recovery sticks"
adb shell rm /system/recovery-from-boot.p
echo
echo "Rooting your phone!"
echo "Your phone will reboot back into the OS once rooted."
adb push Magisk-v16.0.zip /cache/recovery
adb shell echo ""--update_package=/cache/recovery/Magisk-v16.0.zip" > /cache/recovery/command"
echo "Rebooting. Do NOT shut off your phone until it is back in the OS."
echo "Enjoy your rooted phone!"
echo "You should really install Magisk Manager now."
adb reboot recovery
