#!/bin/sh

echo "OpenCV installation for Mac"
echo "please make sure XCode is previously installed."

echo "Installing Homebrew..."

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# update homebrew
brew update

# Add Homebrew path in PATH
echo "# Homebrew" >> ~/.bash_profile
echo "export PATH=/usr/local/bin:$PATH" >> ~/.bash_profile
source ~/.bash_profile

echo "Installing Python 3..."
brew install python3

echo "Installing Cmake..."
brew install cmake

echo "Installing QT5..."
brew install qt5

QT5PATH=/usr/local/Cellar/qt/5.11.2_1
# Save current working directory
cwd=$(pwd)

echo "Installing numpy and pip globally..."
sudo -H pip3 install -U pip numpy

echo "Installing python virtual environment..."
sudo -H python3 -m pip install virtualenv virtualenvwrapper
VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3

echo "Setting up environment variables..."
echo "VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3" >> ~/.bash_profile
echo "# Virtual Environment Wrapper" >> ~/.bash_profile
echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bash_profile
cd $cwd
source /usr/local/bin/virtualenvwrapper.sh

#=================================================================

echo "Installing OpenCV 4.0"
cvVersion="master"

echo "Cleaning the build environment..."
rm -rf opencv/build
rm -rf opencv_contrib/build

# Create directory for installation
mkdir installation
mkdir installation/OpenCV-"$cvVersion"

echo "Creating the virtual environment for openCV..."
mkvirtualenv OpenCV-"$cvVersion"-py3 -p python3
workon OpenCV-"$cvVersion"-py3

echo "Installing cmake, numpy, scipy matplotlib scikit-{image,learn} ipython and dlib into the virtual environment..."
pip install -v cmake numpy scipy matplotlib scikit-image scikit-learn ipython dlib

# quit virtual environment
deactivate
######################################

echo "Fetching the openCV source code from github..."
git clone --progress --verbose https://github.com/opencv/opencv.git
cd opencv
git checkout ${cvVersion}
cd ..

git clone --progress --verbose https://github.com/opencv/opencv_contrib.git
cd opencv_contrib
git checkout ${cvVersion}
cd ..

cd opencv
mkdir build
cd build

echo "Configure CMake for building OpenCV"
cmake -D CMAKE_BUILD_TYPE=RELEASE \
            -D CMAKE_VERBOSE_MAKEFILE:BOOL=ON\
            -D CMAKE_INSTALL_PREFIX=$cwd/installation/OpenCV-"$cvVersion" \
            -D INSTALL_C_EXAMPLES=ON \
            -D INSTALL_PYTHON_EXAMPLES=ON \
            -D WITH_TBB=ON \
            -D WITH_V4L=ON \
            -D OPENCV_SKIP_PYTHON_LOADER=ON \
            -D CMAKE_PREFIX_PATH=$QT5PATH \
            -D CMAKE_MODULE_PATH="$QT5PATH"/lib/cmake \
            -D OPENCV_PYTHON3_INSTALL_PATH=~/.virtualenvs/OpenCV-"$cvVersion"-py3/lib/python3.7/site-packages \
        -D WITH_QT=ON \
        -D WITH_OPENGL=ON \
        -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
        -D BUILD_EXAMPLES=ON ..

echo "Compiling OpenCV..."
make -d -j$(sysctl -n hw.physicalcpu)
make -d install

cd ${cwd}