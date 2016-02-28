#!/bin/bash +x

# Kernel build script by ManhIT (ChoiMobile.VN)


echo
echo

######################################## SETUP #########################################

# Set variables
Flash=SpaceX-Kernel_MM_RC2_G920K
BK=build_kernel
kernelzip=../zipkernel
model=G920K

echo "SM-$model:"

# updater-script setup
sed -i -e '/ui_print("~~~~~~~~~ SpaceX Kernel for/c\ui_print("~~~~~~ SpaceX Kernel for Galaxy S6/S6 Edge ~~~~~~");' $kernelzip/META-INF/com/google/android/updater-script

sed -i -e '/by ManhIT ~~~~~~~~~~~~~~~");/c\ui_print("~~~~~~~~~~~~~~~ G920K - by ManhIT ~~~~~~~~~~~~~~~");' $kernelzip/META-INF/com/google/android/updater-script

sed -i -e '/package_extract_file("boot.img/c\package_extract_file("boot.img", "/dev/block/platform/15570000.ufs/by-name/BOOT");' $kernelzip/META-INF/com/google/android/updater-script


# Cleanup old files from build environment
echo -n "Cleanup build environment.........................."
rm -rf *ramdisk.cpio.*
rm -rf boot*.img
rm -rf $kernelzip/*.img
rm -rf $kernelzip/*.zip
rm -rf $kernelzip/*.tar*
echo "Done"


###################################### RAMDISK GENERATION #####################################

echo -n "Make Ramdisk archive..............................."
cp ../ramdisk_fix_permissions.sh ramdisk/ramdisk_fix_permissions.sh
cd ramdisk
chmod 0777 ramdisk_fix_permissions.sh
./ramdisk_fix_permissions.sh
rm -f ramdisk_fix_permissions.sh
find . | fakeroot cpio -H newc -o | lzop -9 > ../ramdisk.cpio.lzo

##################################### BOOT.IMG GENERATION #####################################

echo -n "Make boot.img......................................"
cd ../
./../mkbootimg --kernel ../Image --ramdisk ramdisk.cpio.lzo --dt dt.img --base 0x10000000 --pagesize 2048 --ramdisk_offset 0x01000000 --tags_offset 0x00000100 --second_offset 0x00f00000 -o boot.img
echo -n "SEANDROIDENFORCE" >> boot.img
# copy the final boot.img's to output directory ready for zipping
cp boot*.img $kernelzip/
echo "Done"


######################################## ZIP GENERATION #######################################

echo -n "Creating flashable file............................."
cd $kernelzip #move to output directory
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

mv "$Flash".zip ../"$model"/
mv "$Flash".tar.md5 ../"$model"/

echo -e
ls -l ../"$model"/boot.img
ls -l ../"$model"/*.zip
ls -l ../"$model"/*.tar.*

echo
echo "Done"
echo
#build script ends




