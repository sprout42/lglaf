cd lglaf
echo "Restoring misc"
adb push misc.img /sdcard/
adb shell dd if=/sdcard/misc.img of=/dev/block/bootdevice/by-name/misc
echo "Flashing TWRP onto recovery"
adb push h918-twrp.img /sdcard/
adb shell dd if=/sdcard/h918-twrp.img of=/dev/block/bootdevice/by-name/recovery
echo "TWRP is much more useful than laf. I would recommend keeping TWRP on"
echo "your laf partition. However, if you *REALLY*want to have laf back, answer yes"
while true; do
	read -p "Do you want to flash laf back onto your device. (y/n): " resp
	case $resp in
		[Yy]* ) adb push laf.img /sdcard/ && adb shell dd if=/sdcard/laf.img of=/dev/block/bootdevice/by-name/laf; cat ~/final.txt; break;;
		[Nn]* ) cat ~/final.txt; exit;;
	esac
done
