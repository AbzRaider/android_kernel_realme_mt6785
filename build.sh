#!/bin/bash


function compile() 
{

source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
ccache -M 100G
export ARCH=arm64
export KBUILD_BUILD_HOST=MARKxDEVS
export KBUILD_BUILD_USER="AbzRaider"
git clone --depth=1 https://github.com/techyminati/android_prebuilts_clang_host_linux-x86_clang-6443078  clang
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 los-4.9-64
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 los-4.9-32

if ! [ -d "out" ]; then
	echo "Kernel OUT Directory Not Found . Making Again"
mkdir out

else

	
	sleep 5
	echo "out directory already exists , Making Dirty Build !! "
	echo "If you want to clean Build , just rm -rf out"
	
fi

make O=out ARCH=arm64 RM6785_defconfig

PATH="${PWD}/clang/bin:${PATH}:${PWD}/clang/bin:${PATH}:${PWD}/clang/bin:${PATH}" \
PATH="${PWD}/clang/bin:${PATH}:${PWD}/los-4.9-32/bin:${PATH}:${PWD}/los-4.9-64/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC="clang" \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE="${PWD}/los-4.9-64/bin/aarch64-linux-android-" \
                      CROSS_COMPILE_ARM32="${PWD}/los-4.9-32/bin/arm-linux-androideabi-" \
                      CONFIG_NO_ERROR_ON_MISMATCH=y
}

function zupload()
{
if  [ -d "AnyKernel" ]; then	
	rm -rf AnyKernel
fi
git clone --depth=1 https://github.com/AbzRaider/AnyKernel33 -b lp-rm6785 AnyKernel
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
cd AnyKernel
zip -r9 LP-OSS-KERNEL-RM6785.zip *
curl --upload-file "LP-OSS-KERNEL-RM6785.zip" https://free.keep.sh
}

compile
zupload
