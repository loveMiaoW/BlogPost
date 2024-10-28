# CMAKE

## 提前了解

> 源码链接: 

### 项目组成对应关系

- 00 - 一个源文件
- 01 - 同一目录下多个源文件
- 02 - 同一目录下许多源文件
- 03 - 头文件和源文件分类
- 04 - 生成动态库和静态库
- 05 - 链接库

### 一些知识

- CMAKE_MINIMUM_REQUIRED(VERSION argc): 要求最低CMake版本。
- PROJECT(project_name): 设置项目名称。
- ADD_EXECUTABLE(target src_files):  生成可执行文件。
- AUX_SOURCE_DIRECTORY(path var_list): 搜索目录中源文件并存储在变量中。
- INCLUDE_DIRECTORIES(path): 去目录中找头文件。
- ADD_LIBRARY(lib_name lib_type src_files): 生成库文件。
- EXECUTABLE_OUTPUT_PATH: 可执行文件生成路径。
- LIBRARY_OUTPUT_PATH: 库文件生成路径。
- SET_TARGET_PROPERTTIES(): 重命名。
- TARGET_LINK_LIBRARIES(*.exe/*.out/*.sh lib_name): 链接库。

## 安装

略

## 程序编译

### 一个源文件

### 同一目录下多个源文件

### 同一目录下许多源文件

### 头文件和源文件分类

### 生成动态库和静态库

### 链接库

