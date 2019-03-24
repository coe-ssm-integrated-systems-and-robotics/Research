#!/bin/bash
start=`date +%s`
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
print_done

print_job "Updating the system packages using apt..."
sudo apt-get -y update
sudo apt-get -y upgrade
print_done

print_job "Installing OS libraries"
sudo apt-get -y install build-essential checkinstall cmake pkg-config yasm git gfortran libjpeg8-dev libjasper-dev libpng12-dev libtiff5-dev libtiff-dev libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev libxine2-dev libv4l-dev

cd /usr/include/linux
sudo ln -s -f ../libv4l1-videodev.h videodev.h
cd $cwd

sudo apt-get -y install libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libgtk2.0-dev libtbb-dev qt5-default libatlas-base-dev libmp3lame-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev libopencore-amrnb-dev libopencore-amrwb-dev libavresample-dev x264 v4l-utils libprotobuf-dev protobuf-compiler libgoogle-glog-dev libgflags-dev libgphoto2-dev libeigen3-dev libhdf5-dev doxygen
print_done

# Step 3: Install Python libraries
print_job "Install Python libraries..."
sudo apt-get -y install python3-dev python3-pip python3-venv
sudo -H pip3 install -U pip numpy setuptools wheel
sudo apt-get -y install python3-testresources
print_done

print_job "Creating a virtual environment wrapper..."
python3 -m venv OpenCV-"$cvVersion"-py3
echo "# Virtual Environment Wrapper" >> ~/.bashrc
echo "alias workoncv-$cvVersion=\"source $cwd/OpenCV-$cvVersion-py3/bin/activate\"" >> ~/.bashrc
source "$cwd"/OpenCV-"$cvVersion"-py3/bin/activate
source "$cwd"/OpenCV-"$cvVersion"-py3/bin/activate
print_done

print_job "Creating the virtual environment for OpenCV..."
mkvirtualenv OpenCV-"$cvVersion"-py3 -p python3
workon OpenCV-"$cvVersion"-py3
print_done

print_job "Creating temproray swap to make sure we dont run out of memory..."
sudo sed -i 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/g' /etc/dphys-swapfile
sudo /etc/init.d/dphys-swapfile stop
sudo /etc/init.d/dphys-swapfile start
print_done

print_job "Installing python libraries in the environment..."
pip install --upgrade pip
pip install wheel
pip install wheel setuptools dlib numpy
deactivate
print_done

printf "Fetching the openCV source code from github..."
git clone https://github.com/opencv/opencv.git
cd opencv
git checkout master
cd ..

git clone https://github.com/opencv/opencv_contrib.git
cd opencv_contrib
git checkout master
cd ..
print_done


print_job "Configure CMake for building OpenCV..."
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
print_done

print_job "Compiling OpenCV..."
# make -d -j$(nproc)    # Maybe try a lower number of CPU's to prevent freezing.
make -d -j$(nproc)
print_done

print_job "Installing OpenCV..."
make -d install
print_done

cd $cwd

print_job "Removing the temporary swap file..."
sudo sed -i 's/CONF_SWAPSIZE=2048/CONF_SWAPSIZE=100/g' /etc/dphys-swapfile
sudo /etc/init.d/dphys-swapfile stop
sudo /etc/init.d/dphys-swapfile start
echo "sudo modprobe bcm2835-v4l2" >> ~/.profile
print_done

print_finished_install

end=`date +%s`

