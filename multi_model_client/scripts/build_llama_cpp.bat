@echo off
REM build_llama_cpp.bat - 编译 llama.cpp 库（Windows 版本，支持 CUDA 加速）
REM 使用方法: build_llama_cpp.bat [--clean]

setlocal enabledelayedexpansion

echo === llama.cpp Windows 编译脚本 (CUDA 加速) ===
echo.

set CLEAN=false
if "%1"=="--clean" (
    set CLEAN=true
    echo 清理模式已启用
)

REM 项目根目录
set SCRIPT_DIR=%~dp0
set PROJECT_DIR=%SCRIPT_DIR%..
set BUILD_DIR=%PROJECT_DIR%\build\llama_cpp
set SRC_DIR=%BUILD_DIR%\llama.cpp

REM 创建目录
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

REM 检查是否需要克隆 llama.cpp
if not exist "%SRC_DIR%" (
    echo 正在克隆 llama.cpp 仓库...
    git clone --depth 1 https://github.com/ggml-org/llama.cpp.git "%SRC_DIR%"
) else (
    echo llama.cpp 已存在，跳过克隆
)

REM 清理旧构建
if "%CLEAN%"=="true" (
    if exist "%SRC_DIR%\build" (
        echo 清理旧构建...
        rmdir /s /q "%SRC_DIR%\build"
    )
)

REM 创建构建目录
if not exist "%SRC_DIR%\build" mkdir "%SRC_DIR%\build"
cd /d "%SRC_DIR%\build"

REM 检查 CUDA 是否可用
set CUDA_ARGS=
where nvcc >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo 检测到 CUDA，将启用 GPU 加速
    set CUDA_ARGS=-DLLAMA_CUBLAS=ON
) else (
    echo CUDA 未找到，将编译 CPU 版本
    set CUDA_ARGS=-DLLAMA_CUBLAS=OFF
)

REM 配置 CMake
echo 配置 CMake...
cmake .. ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DLLAMA_BUILD_TESTS=OFF ^
    -DLLAMA_BUILD_EXAMPLES=OFF ^
    %CUDA_ARGS%

REM 编译
echo 编译 llama.cpp...
cmake --build . --config Release --parallel

REM 安装
echo 安装库文件...
cmake --install . --prefix "%BUILD_DIR%\install"

REM 复制到项目 lib 目录
set LIB_DIR=%PROJECT_DIR%\lib
if not exist "%LIB_DIR%" mkdir "%LIB_DIR%"

copy "%BUILD_DIR%\install\lib\llama.dll" "%LIB_DIR%\" /Y >nul 2>&1
copy "%BUILD_DIR%\install\lib\llama.lib" "%LIB_DIR%\" /Y >nul 2>&1

echo.
echo === 编译完成！ ===
echo.
echo 库文件位置: %BUILD_DIR%\install\lib\
echo 项目 lib 目录: %LIB_DIR%\
echo.
if "%CUDA_ARGS%"=="-DLLAMA_CUBLAS=ON" (
    echo 已编译 CUDA 版本，请确保已安装 NVIDIA GPU 驱动
) else (
    echo 已编译 CPU 版本
)
echo.

endlocal
