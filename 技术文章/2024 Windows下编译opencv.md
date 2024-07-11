## Windows _64bits Qt MinGW方式编译opencv

### 文件

>opencv_3.4.3
>
>opencv_contrib_3.4.3
>
>cmake_版本任意
>
>qt_版本任意
>
>python_版本任意

安装cmake,qt,python等不在叙述，但是将可执行文件加入到系统变量。

就像这样，缺一不可。

>C:\tools\cmake\bin  
>
>C:\Qt\Qt5.14.2\Tools\mingw730_64\bin
>
>C:\Qt\Qt5.14.2\5.14.2\mingw73_64\bin
>
>C:\Qt\Qt5.14.2\5.14.2\mingw73_64\lib

![](https://cdn.jsdelivr.net/gh/lovemiaow/noteImages@master/2024/02/202403162336696.png)

### 详细安装过程

巴拉巴拉巴拉，以后补充。

### 在qt使用opencv

首先将`${*}\opencv\opencv_build\install\x64\mingw\bin` 这个目录，添加到系统环境变量。

这个是目录是在你创建的`opencv_build`文件夹里的`install`之后。

![](https://cdn.jsdelivr.net/gh/lovemiaow/noteImages@master/2024/02/202403162349454.png)

![image-20240316235050532](C:\Users\MrLiu\AppData\Roaming\Typora\typora-user-images\image-20240316235050532.png)

![](https://cdn.jsdelivr.net/gh/lovemiaow/noteImages@master/2024/02/202403162351290.png)

创建QT项目，在项目的`pro`文件中，添加如下引用。

```c++
INCLUDEPATH += C:\Users\MrLiu\Desktop\opencv\opencv_build\install\include
LIBS += C:\Users\MrLiu\Desktop\opencv\opencv_build\install\x64\mingw\lib\libopencv_*.a
```

*** **一定要写成你自己的目录，而不是复制我的。**

然后在main.cpp里添加测试程序，就像这样。

```c++
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

using namespace cv;

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    MainWindow w;
    Mat image=imread("C:\\Users\\MrLiu\\Desktop\\2023.JPG",1);//一定要使用绝对路径，其他可以会报错
    namedWindow( "Display window", WINDOW_AUTOSIZE);
    imshow( "Display window", image );
    return a.exec();
}
```

然后就可以运行了。

![](https://cdn.jsdelivr.net/gh/lovemiaow/noteImages@master/2024/02/202403162348877.png)

![](https://cdn.jsdelivr.net/gh/lovemiaow/noteImages@master/2024/02/202403162347191.png)