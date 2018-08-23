#!/bin/bash
# Cheesy wrapper script to help n00bs till I can finish lglaf

clear
echo "This will install TWRP."
echo
echo "You do NOT need to do ANYTHING!"
echo
echo "If it fails, NO damage is done to your phone."
echo
echo "If the hash check fails, it will make ${RETRIES} attempts."
echo
echo "If after ${RETRIES} attempts, it does not get a hash match, it will abort."
echo
echo "NO damage has been done to your phone."
echo
echo "You can re-run this script as many times as you want, however,"
echo "if you are not getting a hash match, you should try a different PC,"
echo "or a different cable, or a different USB port."
read -n1 -r -p "Press SPACE to continue..." KEY

if [ "$KEY" = '' ]; then
	echo "Flashing... this will take a while."
else
	echo "Exiting"
	exit
fi

# This is for the H872 -- DO NOT MODIFY, and DO NOT run this on any other model
SRC_OFFSET=12294
DST_OFFSET=6
TWRP="h872-twrp.img"
TWRPTMP="h872-twrp-tmp.img"
TWRPTEST="test.img"
SIZE=$(stat -c%s $TWRP)
echo "Size of TWRP: "$SIZE
BS=1024
COUNT=$((SIZE / BS))
echo "Count for the dd trim: "$COUNT
TRIES=0
RETRIES=5
rm ${TWRPTMP} > /dev/null 2>&1
rm ${TWRPTEST} > /dev/null 2>&1

function flash () {
	echo "Flashing TWRP to lafbak. Please wait..."
	./partitions.py --restoremisc  ${TWRP} lafbak
	echo "Dumping lafbak for hash check..."
	./partitions.py --dump ${TWRPTMP} lafbak
	echo "Trimming trailing zeros"
	dd if=${TWRPTMP} of=${TWRPTEST} bs=${BS} count=${COUNT} > /dev/null #2>&1 # This strips the trailing whitespace so the dump is the same size as TWRP
	TMPSIZE=$(stat -c%s $TWRPTEST)
	echo "Temp file size: "$TMPSIZE
	SHA1=`sha256sum ${TWRP} | awk '{print $1}'`
	SHA2=`sha256sum ${TWRPTEST} | awk '{print $1}'`
	STRHASH1="S${SHA1}"
	STRHASH2="S${SHA2}"
	echo "Checking hash..."
	echo "TWRP hash:" $STRHASH1
	echo "Test dump hash: " $STRHASH2
	if [[ "$STRHASH1" != "$STRHASH2" ]] ; then
		echo
		echo "Hash check failed! Retrying for ${RETRIES} times."
		echo
		rm ${TWRPTMP}
		rm ${TWRPTEST}
		until [ $TRIES -ge $RETRIES ]
		do
		  TRIES=$[$TRIES+1] && sleep 2 && echo "Attempt ${TRIES} - Press ctrl C to break" && flash
		done && echo "Hash check failed after ${RETRIES} attempts - exiting" && exit
	fi
	echo "Hash check passed. Copying TWRP to laf"
	./lglaf.py -c '!OPEN'
	FD_NUM=`./lglaf.py -c '!EXEC  lsof\0' | grep sda | grep lsof | awk '{print $4}' | cut -f1 -d"u"`
	./lglaf.py -c '!COPY '$FD_NUM,$SRC_OFFSET,$SIZE,$DST_OFFSET
	./lglaf.py -c '!CLSE '$FD_NUM
	rm ${TWRPTMP} > /dev/null 2>&1
	rm ${TWRPTEST} > /dev/null 2>&1
	./lglaf.py -c '!CTRL POFF'
	echo "Flash sucessful! Unplug your USB cable and your phone will power off."
	echo "Once your phone is off, go back into download mode - hold vol up and plug the USB cable back in."
	echo "Once TWRP loads, you need to flash TWRP onto recovery. You can run step2.sh if you want"
	echo "an automated root."
}
flash
