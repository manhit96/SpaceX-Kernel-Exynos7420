#!/bin/bash +x

# Kernel build script by ManhIT (ChoiMobile.VN)

clear
echo
echo

######################################## SETUP #########################################

# Set variables
FIT=SpaceX_recovery_defconfig
SETARCH=arm64
CROSS=../../Toolchain/aarch64-linux-android-4.9/bin/aarch64-linux-android-
IMG=arch/arm64/boot
DTS=arch/arm64/boot/dts
DC=arch/arm64/configs
BK=build_recovery

# Cleanup old files from build environment
echo -n "Cleanup build environment.........................."
cd .. #move to source directory
rm -rf $BK/Image*
rm -rf $IMG/Image
rm -rf $DTS/.*.tmp
rm -rf $DTS/.*.cmd
rm -rf $DTS/*.dtb
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


#################################### IMAGE COMPILATION #####################################

echo -n "Compiling Kernel (FIT)............................."
cp $BK/$FIT .config
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


#################################### BOOT.IMG COMPILATION #####################################

./build.sh

###################################### OPTIONAL SOURCE CLEAN ###################################

make clean
make mrproper
make distclean

rm -rf fmp_hmac.bin
rm -rf fips_fmp_utils
rm -rf arch/arm64/boot/Image.gz-dtb

echo
echo "Build completed"
echo
#build script ends



