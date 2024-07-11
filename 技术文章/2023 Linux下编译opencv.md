# ubuntu 安装qt编译opencv包含contribs

## 软件基础

>[qt-opensource-linux-x64-5.12.9.run](https://download.qt.io/archive/qt/5.12/5.12.9/qt-opensource-linux-x64-5.12.9.run)
>
>[opencv-4.4.0.zip](https://codeload.github.com/opencv/opencv/zip/refs/tags/4.4.0)
>
>[opencv_contrib-4.4.0.zip](https://codeload.github.com/opencv/opencv_contrib/zip/refs/tags/4.4.0)

```c++
推荐这样操作
unzip opencv-4.4.0.zip
unzip opencv_contrib-4.4.0.zip
mv opencv-4.4.0 opencv
mv opencv_contrib-4.4.0 opencv_contrib
//将opencv_contrib 移动到opencv里边
```

结果如下,可能略有不同

```c++
drwxrwxr-x 14 mrliu mrliu  4096  7月  8 02:21 ./
drwxrwxr-x  3 mrliu mrliu  4096  7月  8 13:59 ../
drwxrwxr-x 21 mrliu mrliu  4096  7月 18  2020 3rdparty/
drwxrwxr-x  8 mrliu mrliu  4096  7月 18  2020 apps/
drwxrwxr-x 18 mrliu mrliu  4096  7月  8 02:56 build/
drwxrwxr-x  6 mrliu mrliu  4096  7月  8 02:19 .cache/
drwxrwxr-x  7 mrliu mrliu  4096  7月 18  2020 cmake/
-rw-rw-r--  1 mrliu mrliu 66070  7月 18  2020 CMakeLists.txt
-rw-rw-r--  1 mrliu mrliu   191  7月 18  2020 CONTRIBUTING.md
drwxrwxr-x  7 mrliu mrliu  4096  7月 18  2020 data/
drwxrwxr-x  8 mrliu mrliu  4096  7月 18  2020 doc/
-rw-rw-r--  1 mrliu mrliu   455  7月 18  2020 .editorconfig
drwxrwxr-x  3 mrliu mrliu  4096  7月 18  2020 include/
-rw-rw-r--  1 mrliu mrliu  2294  7月 18  2020 LICENSE
drwxrwxr-x 23 mrliu mrliu  4096  7月 18  2020 modules/
drwxrwxr-x  6 mrliu mrliu  4096  7月 17  2020 opencv_contrib/
drwxrwxr-x 12 mrliu mrliu  4096  7月 18  2020 platforms/
-rw-rw-r--  1 mrliu mrliu   709  7月 18  2020 README.md
drwxrwxr-x 20 mrliu mrliu  4096  7月 18  2020 samples/
-rw-rw-r--  1 mrliu mrliu  3820  7月 18  2020 SECURITY.md
```

## 安装编译包

```sh
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install build-essential
sudo apt-get install libgl1-mesa-dev
sudo apt-get install pkg-config
sudo apt-get install libjpeg-dev libpng-dev libtiff-dev
sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev
sudo apt-get install libv4l-dev libxvidcore-dev libx264-dev
sudo apt-get install libgtk-3-dev
sudo apt-get install libatlas-base-dev gfortran
sudo apt-get install python3-dev
mkdir build
cd build/
```

## 更改源码文件

>/home/mrliu/opencv/opencv/opencv_contrib/modules/cudev/include/opencv2/cudev/common.hpp
>
>添加`#include <cuda_fp16.h>`
>
>/home/mrliu/opencv/opencv/modules/gapi/test/gapi_async_tesr.cpp
>
>添加`\#include <thread>`

> 需要使用科学上网

## 然后编译(遇到其他问题需要自行百度)

```cmake
cmake -D CMAKE_BUILD_TYPE=Release -D WITH_PROTOBUF=OFF -D WITH_EIGEN=OFF -D BUILD_opencv_xfeatures2d=OFF -D CMAKE_INSTALL_PREFIX=/usr/local -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules ..
```

```c++
make -j16 //16核心数量 根据你机器决定
make install
```

## 创建pkgcofig文件夹

```c++
sudo mkdir -r /usr/local/lib/pkgconfig
touch opencv.pc
vim opencv.pv
>添加以下内容
prefix=/usr
exec_prefix=${prefix}
includedir=${prefix}/include
libdir=${exec_prefix}/lib

Name: opencv
Description: The opencv library
Version: 2.x.x
Cflags: -I${includedir}/opencv -I${includedir}/opencv2
Libs: -L${libdir} -lopencv_calib3d -lopencv_imgproc -lopencv_contrib -lopencv_legacy -lopencv_core -lopencv_ml -lopencv_features2d -lopencv_objdetect -lopencv_flann -lopencv_video -lopencv_highgui
>
```

## 更新配置文件

```c++
sudo ldconfig
sudo vim /etc/bash.bashrc 
>添加以下内容
PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig  
export PKG_CONFIG_PATH
>
source /etc/bash.bashrc 
sudo updatedb
```

## 然后就可以在qt里使用opencv了

```c++
//pro文件配置 如下
INCLUDEPATH += /usr/local/include \
/usr/local/include/opencv4 \
/usr/local/include/opencv4/opencv2

LIBS += /usr/local/lib/libopencv_calib3d.so \
/usr/local/lib/libopencv_core.so \
/usr/local/lib/libopencv_features2d.so \
/usr/local/lib/libopencv_flann.so \
/usr/local/lib/libopencv_highgui.so \
/usr/local/lib/libopencv_imgcodecs.so \
/usr/local/lib/libopencv_imgproc.so \
/usr/local/lib/libopencv_ml.so \
/usr/local/lib/libopencv_objdetect.so \
/usr/local/lib/libopencv_photo.so \
/usr/local/lib/libopencv_shape.so \
/usr/local/lib/libopencv_stitching.so \
/usr/local/lib/libopencv_superres.so \
/usr/local/lib/libopencv_videoio.so \
/usr/local/lib/libopencv_video.so \
/usr/local/lib/libopencv_videostab.so
```

就可以使用opencv了