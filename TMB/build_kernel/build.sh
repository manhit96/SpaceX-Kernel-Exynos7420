#!/bin/bash +x

# Kernel build script by ManhIT (ChoiMobile.VN)

clear
echo
echo

######################################## SETUP #########################################

# set variables
FIT=SpaceX_defconfig
Flash="SpaceX-Zero_N920T.W8(Dev)"

SETARCH=arm64
CROSS=/home/spacex/Android_Workspace/Kernel/Toolchain/aarch64-linux-android-4.9/bin/aarch64-linux-android-
IMG=arch/arm64/boot
DTS=arch/arm64/boot/dts
DC=arch/arm64/configs

# updater-script setup
sed -i -e '/ui_print("~~~~~~~~~ SpaceX Kernel for/c\ui_print("~~~~~~~~~ SpaceX Kernel for Galaxy Note 5 ~~~~~~~~~");' Output/META-INF/com/google/android/updater-script

sed -i -e '/by ManhIT ~~~~~~~~~~~~~~~");/c\ui_print("~~~~~~~~~~~~~~~ N920T/W8 - by ManhIT ~~~~~~~~~~~~~~~");' Output/META-INF/com/google/android/updater-script

sed -i -e '/package_extract_file("boot.img/c\package_extract_file("boot.img", "/dev/block/platform/15570000.ufs/by-name/BOOT");' Output/META-INF/com/google/android/updater-script

BK=build_kernel
OUT=Output


# Cleanup old files from build environment
echo -n "Cleanup build environment.........................."
cd .. #move to source directory
rm -rf $BK/ramdisk.cpio.gz
rm -rf $BK/Image*
rm -rf $BK/boot*.img
# rm -rf $BK/dt*.img
rm -rf $IMG/Image
rm -rf $DTS/.*.tmp
rm -rf $DTS/.*.cmd
rm -rf $DTS/*.dtb
rm -rf $OUT/*.img
rm -rf $OUT/*.tar
rm -rf .config
echo "Done"

# Set build environment variables
echo -n "Set build variables................................"
export ARCH=$SETARCH
export CROSS_COMPILE=$CROSS
export SUBARCH=$SETARCH
export ccache=ccache
export USE_SEC_FIPS_MODE=true
export KCONFIG_NOTIMESTAMP=true
sed -i -e '/LINUX_COMPILE_BY=$(whoami/c\LINUX_COMPILE_BY=ManhIT' scripts/mkcompile_h
sed -i -e '/LINUX_COMPILE_HOST=`hostname`/c\LINUX_COMPILE_HOST=ChoiMobile.VN' scripts/mkcompile_h
echo "Done"
echo

#################################### DEFCONFIG CHECKS #####################################

echo -n "Checking for FIT defconfig........................."
if [ -f "$DC/$FIT" ]; then
	echo "Found - FIT"
else
	echo "Not Found - Reset"
	cp $BK/$FIT $DC/$FIT
fi

#################################### IMAGE COMPILATION #####################################

echo -n "Compiling Kernel (FIT)............................."
cp $DC/$FIT .config
make ARCH=$SETARCH -j4
if [ -f "arch/arm64/boot/Image" ]; then
	echo "Done"
	# Copy the compiled image to the build_kernel directory
	mv $IMG/Image $BK/Image
else
	clear
	echo
	echo "Compilation failed on FIT kernel !"
	echo
	while true; do
    		read -p "Do you want to run a Make command to check the error?  (y/n) > " yn
    		case $yn in
        		[Yy]* ) make; echo ; exit;;
        		[Nn]* ) echo; exit;;
        	 	* ) echo "Please answer yes or no.";;
    		esac
	done
fi


###################################### DT.IMG GENERATION #####################################

echo -n "Build dt.img......................................."

./$BK/dtbtool -o $BK/dt.img -s 2048 -p ./scripts/dtc/dtc $DTS/ | sleep 1
# get rid of the temps in dts directory
rm -rf $DTS/.*.tmp
rm -rf $DTS/.*.cmd
rm -rf $DTS/*.dtb

# Calculate DTS size for all images and display on terminal output
du -k "$BK/dt.img" | cut -f1 >sizT
sizT=$(head -n 1 sizT)
rm -rf sizT
echo "$sizT Kb"


###################################### RAMDISK GENERATION #####################################

echo -n "Make Ramdisk archive..............................."
cp $BK/ramdisk_fix_permissions.sh $BK/ramdisk/ramdisk_fix_permissions.sh
cd $BK/ramdisk
chmod 0777 ramdisk_fix_permissions.sh
./ramdisk_fix_permissions.sh
rm -f ramdisk_fix_permissions.sh
find .| cpio -o -H newc | lzma -9 > ../ramdisk.cpio.gz

##################################### BOOT.IMG GENERATION #####################################

echo -n "Make boot.img......................................"
cd ..
./mkbootimg --base 0x10000000 --kernel Image --ramdisk_offset 0x01000000 --tags_offset 0x00000100 --pagesize 2048 --ramdisk ramdisk.cpio.gz --dt dt.img -o boot.img
# copy the final boot.img's to output directory ready for zipping
cp boot*.img $OUT/
echo "Done"


######################################## ZIP GENERATION #######################################

echo -n "Creating flashable file............................."
cd $OUT #move to output directory
zip -r "$Flash".zip *
echo -e
tar -cv boot.img >> "$Flash".tar
echo -e
tar -tvf "$Flash".tar
echo -e
md5sum -t "$Flash".tar >> "$Flash".tar
echo -e
mv -v "$Flash".tar "$Flash".tar.md5
echo -e
md5sum -t "$Flash".tar.md5

echo "Done"

###################################### OPTIONAL SOURCE CLEAN ###################################

echo
cd ../../
read -p "Do you want to Clean the source? (y/n) > " mc
if [ "$mc" = "Y" -o "$mc" = "y" ]; then
	xterm -e make clean
	xterm -e make mrproper
	xterm -e make distclean
fi

rm -rf fmp_hmac.bin
rm -rf fips_fmp_utils
rm -rf arch/arm64/boot/Image.gz-dtb

echo
echo "Build completed"
echo
#build script ends




