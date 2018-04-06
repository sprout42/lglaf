cd lglaf
echo "Backing up laf"
./partitions.py --dump laf.img laf
echo "Backing up misc"
./partitions.py --dump misc.img misc
echo "Flashing TWRP to laf. This will take a few minutes."
echo "When it is finished, your phone will reboot. Enter download mode again,"
echo "and you will have TWRP."
echo "When the phone reboots, you will have to click on Devices / USB and "
echo "pick LG H918 so that the phone is reattached to VirtualBox"
echo "Once you are back in download mode, run ./post-root-h918.sh"
./partitions.py --restoremisc h918-twrp.img laf
echo "Flash done -- verifying"
./partitions.py --dump testtwrp.img laf
sha256sum -c twrp_hash --quiet --strict --warn
if [ $? != 0 ]; then
	echo "HASH FAILED! You need to try again." && rm testtwrp.img && exit
fi
echo "Hash check was OK. Rebooting the phone"
rm testtwrp.img
./lglaf.py -c "!CTRL RSET"
