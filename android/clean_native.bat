@echo off
REM Clean script for libuvccamera native libraries

echo Cleaning native libraries...

REM Parse NDK path from local.properties
for /f "tokens=2 delims==" %%a in ('findstr /c:"ndk.dir" local.properties') do set NDK_DIR=%%a
set NDK_DIR=%NDK_DIR:\=/%
set NDK_DIR=%NDK_DIR:"=%

if "%NDK_DIR%"=="" (
    echo WARNING: ndk.dir not found in local.properties
    echo Manually deleting libs directories...
    if exist "UVCCamera\libuvccamera\src\main\libs" rd /s /q "UVCCamera\libuvccamera\src\main\libs"
    if exist "UVCCamera\libuvccamera\src\main\obj" rd /s /q "UVCCamera\libuvccamera\src\main\obj"
    echo Clean complete!
    pause
    exit /b 0
)

cd UVCCamera\libuvccamera\src\main
"%NDK_DIR%\ndk-build.cmd" clean
cd ..\..\..\..

echo Clean complete!
pause
