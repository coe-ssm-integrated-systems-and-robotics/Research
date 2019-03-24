#!/bin/bash
source ./helper.sh

printf "\e[44m=============================================================\e[0m\n"
printf "\e[44m===            Installing OpenCV On Rasbian               ===\e[0m\n"
printf "\e[44m=============================================================\e[0m\n"
print_job "Preparing system for installation..."
sudo apt-get -y purge wolfram-engine
sudo apt-get -y purge libreoffice*
sudo apt-get -y clean
sudo apt-get -y autoremove

cvVersion="master"
rm -rf opencv/build
rm -rf opencv_contrib/build
mkdir installation
mkdir installation/OpenCV-"$cvVersion"
cwd=$(pwd)
sudo apt-get -y remove x264 libx264-dev
printf "\n\e[32m Done! \e[0m\n"

printf "\e[44m Updating the system packages using apt... \e[0m"
sudo apt-get -y update
sudo apt-get -y upgrade
printf "\n\e[32m Done! \e[0m\n"

echo "Installing OS libraries"
sudo apt-get -y install build-essential checkinstall cmake pkg-config yasm git gfortran libjpeg8-dev libjasper-dev libpng12-dev libtiff5-dev libtiff-dev libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev libxine2-dev libv4l-dev

cd /usr/include/linux
sudo ln -s -f ../libv4l1-videodev.h videodev.h
cd $cwd

sudo apt-get -y install libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libgtk2.0-dev libtbb-dev qt5-default libatlas-base-dev libmp3lame-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev libopencore-amrnb-dev libopencore-amrwb-dev libavresample-dev x264 v4l-utils libprotobuf-dev protobuf-compiler libgoogle-glog-dev libgflags-dev libgphoto2-dev libeigen3-dev libhdf5-dev doxygen
printf "\n\e[32m Done! \e[0m\n"


# Step 3: Install Python libraries
printf "\e[44m Install Python libraries \e[0m"
sudo apt-get -y install python3-dev python3-pip python3-venv
sudo -H pip3 install -U pip numpy setuptools wheel
sudo apt-get -y install python3-testresources
printf "\n\e[32m Done! \e[0m\n"


printf "\e[44m Creating a virtual environment wrapper \e[0m"
python3 -m venv OpenCV-"$cvVersion"-py3
echo "# Virtual Environment Wrapper" >> ~/.bashrc
echo "alias workoncv-$cvVersion=\"source $cwd/OpenCV-$cvVersion-py3/bin/activate\"" >> ~/.bashrc
source "$cwd"/OpenCV-"$cvVersion"-py3/bin/activate
printf "\n\e[32m Done! \e[0m\n"

printf "\e[44m Creating the virtual environment for OpenCV \e[0m"
mkvirtualenv OpenCV-"$cvVersion"-py3 -p python3
workon OpenCV-"$cvVersion"-py3
printf "\n\e[32m Done! \e[0m\n"

printf "\e44m Creating temproray swap to make sure we dont run out of memory... \e[0m"
sudo sed -i 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/g' /etc/dphys-swapfile
sudo /etc/init.d/dphys-swapfile stop
sudo /etc/init.d/dphys-swapfile start
printf "\n\e[32m Done! \e[0m\n"

printf "\e[44m Installing python libraries in the environment... \e[0m"
pip install setuptools wheel numpy dlib
deactivate
printf "\n\e[32m Done! \e[0m\n"

printf "\e[44m Fetching the openCV source code from github... \e[0m"
git clone https://github.com/opencv/opencv.git
cd opencv
git checkout master
cd ..

git clone https://github.com/opencv/opencv_contrib.git
cd opencv_contrib
git checkout master
cd ..
printf "\n\e[32m Done! \e[0m\n"


printf "Configure CMake for building OpenCV"
cd opencv
mkdir build
cd build

cmake -D CMAKE_BUILD_TYPE=RELEASE \
            -D CMAKE_INSTALL_PREFIX=$cwd/installation/OpenCV-"$cvVersion" \
            -D INSTALL_C_EXAMPLES=ON \
            -D INSTALL_PYTHON_EXAMPLES=ON \
            -D WITH_TBB=ON \
            -D ENABLE_NEON=ON \
            -D ENABLE_VFPV3=ON \
            -D WITH_V4L=ON \
            -D OPENCV_PYTHON3_INSTALL_PATH=$cwd/OpenCV-$cvVersion-py3/lib/python3.5/site-packages \
        -D WITH_QT=ON \
        -D WITH_OPENGL=ON \
        -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
        -D BUILD_EXAMPLES=ON ..
printf "\n\e[32m Done! \e[0m\n"

printf "\n\e[44m Compiling OpenCV... \e[0m"
# make -d -j$(nproc)    # Maybe try a lower number of CPU's to prevent freezing.
make -d -j$(nproc)
printf "\n\e[32m Done! \e[0m\n"

printf "\e[44m Installing OpenCV... \e[0m"
make -d install
printf "\n\e[32m Done! \e[0m\n"

cd $cwd

printf "\n\e[44m Removing the temporary swap file... \e[0m"
sudo sed -i 's/CONF_SWAPSIZE=2048/CONF_SWAPSIZE=100/g' /etc/dphys-swapfile
sudo /etc/init.d/dphys-swapfile stop
sudo /etc/init.d/dphys-swapfile start
echo "sudo modprobe bcm2835-v4l2" >> ~/.profile
printf "\n\e[32m Done! \e[0m\n"

printf "\e[32m ============================================================= \e[0m"
printf "\e[32m ===                 Installation is DONE!                 === \e[0m"
printf "\e[32m ============================================================= \e[0m"
