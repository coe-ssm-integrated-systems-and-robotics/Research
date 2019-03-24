#!/bin/bash

printf "\e[44m =============================================================\n \e[0m"
printf "\e[44m ===            Installing OpenCV On Ubuntu                ===\n \e[0m"
printf "\e[44m =============================================================\n \e[0m"
cvVersion="master"

printf "\e[44m Preparing system for installation... \e[0m\n"
rm -rf opencv/build
rm -rf opencv_contrib/build
mkdir installation
mkdir installation/OpenCV-"$cvVersion"
cwd=$(pwd)
printf "\n\e[32m Done! \e[0m\n"

printf "\e[44m Updating the system packages using apt... \e[0m\n"
sudo apt -y update
sudo apt -y upgrade
sudo add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"
sudo apt -y update
printf "\n\e[32m Done! \e[0m\n"

echo "Installing OS libraries"
sudo apt -y remove x264 libx264-dev
sudo apt -y install build-essential checkinstall cmake pkg-config yasm git gfortran libjpeg8-dev libpng-dev software-properties-common software-properties-common  libjasper1 libtiff-dev libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev libxine2-dev libv4l-dev

cd /usr/include/linux
sudo ln -s -f ../libv4l1-videodev.h videodev.h
cd "$cwd"

sudo apt -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgtk2.0-dev libtbb-dev qt5-default libatlas-base-dev libfaac-dev libmp3lame-dev libtheora-dev libvorbis-dev libxvidcore-dev libopencore-amrnb-dev libopencore-amrwb-dev libavresample-dev x264 v4l-utils libprotobuf-dev protobuf-compiler libgoogle-glog-dev libgflags-dev libgphoto2-dev libeigen3-dev libhdf5-dev doxygen
printf "\n\e[32m Done! \e[0m\n"

printf "\e[44m Install Python libraries \e[0m\n"
sudo apt -y install python3-dev python3-pip python3-venv
sudo -H pip3 install -U pip numpy
sudo apt -y install python3-testresources
printf "\n\e[32m Done! \e[0m\n"

printf "\e[44m Creating a virtual environment wrapper \e[0m\n"
cd $cwd
python3 -m venv OpenCV-"$cvVersion"-py3
echo "# Virtual Environment Wrapper" >> ~/.bashrc
echo "alias workoncv-$cvVersion=\"source $cwd/OpenCV-$cvVersion-py3/bin/activate\"" >> ~/.bashrc
source "$cwd"/OpenCV-"$cvVersion"-py3/bin/activate
printf "\n\e[32m Done! \e[0m\n"

printf "\e[44m Installing python libraries in the environment... \e[0m\n"
pip install numpy scipy matplotlib scikit-image scikit-learn ipython dlib --user
deactivate
printf "\n\e[32m Done! \e[0m\n"

printf "\e[44m Fetching the openCV source code from github... \e[0m\n"
git clone --progress --verbose https://github.com/opencv/opencv.git
cd opencv
git checkout $cvVersion
cd ..

git clone --progress --verbose  https://github.com/opencv/opencv_contrib.git
cd opencv_contrib
git checkout $cvVersion
cd ..
printf "\n\e[32m Done! \e[0m\n"

printf "\e[44m Configure CMake for building OpenCV \e[0m\n"
cd opencv
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=RELEASE \
 -D CMAKE_VERBOSE_MAKEFILE:BOOL=ON\
            -D CMAKE_INSTALL_PREFIX=$cwd/installation/OpenCV-"$cvVersion" \
            -D INSTALL_C_EXAMPLES=ON \
            -D INSTALL_PYTHON_EXAMPLES=ON \
            -D WITH_TBB=ON \
            -D WITH_V4L=ON \
            -D OPENCV_PYTHON3_INSTALL_PATH=$cwd/OpenCV-$cvVersion-py3/lib/python3.6/site-packages \
        -D WITH_QT=ON \
        -D WITH_OPENGL=ON \
        -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
        -D BUILD_EXAMPLES=ON ..

printf "\n\e[32m Done! \e[0m\n"


printf "\e[44m Compiling OpenCV... \n\e[0m"
make -j$(nproc)
printf "\n\e[32m Done! \e[0m\n"

printf "\e[44m Installing OpenCV... \n\e[0m"
make install
printf "\n\e[32m Done! \e[0m\n"


printf "\e[32m =============================================================\n \e[0m"
printf "\e[32m ===                 Installation is DONE!                 ===\n \e[0m"
printf "\e[32m =============================================================\n \e[0m"