@echo off
REM Build script for libuvccamera native libraries
REM This script builds the JNI libraries required for UVC camera streaming

echo ========================================
echo Building libuvccamera Native Libraries
echo ========================================
echo.

REM Check if NDK is configured
if not exist "local.properties" (
    echo ERROR: local.properties not found!
    echo Please create local.properties with ndk.dir setting
    echo Example:
    echo   sdk.dir=C:\\Users\\YourName\\AppData\\Local\\Android\\sdk
    echo   ndk.dir=C:\\Users\\YourName\\AppData\\Local\\Android\\sdk\\ndk\\25.2.9519653
    pause
    exit /b 1
)

REM Parse NDK path from local.properties
for /f "tokens=2 delims==" %%a in ('findstr /c:"ndk.dir" local.properties') do set NDK_DIR=%%a
set NDK_DIR=%NDK_DIR:\=/%

if "%NDK_DIR%"=="" (
    echo ERROR: ndk.dir not found in local.properties!
    echo Please add ndk.dir to local.properties
    echo Example: ndk.dir=C:\\Users\\YourName\\AppData\\Local\\Android\\sdk\\ndk\\25.2.9519653
    pause
    exit /b 1
)

REM Remove quotes if present
set NDK_DIR=%NDK_DIR:"=%

echo NDK Directory: %NDK_DIR%
echo.

REM Check if ndk-build exists
if not exist "%NDK_DIR%\ndk-build.cmd" (
    echo ERROR: ndk-build.cmd not found at: %NDK_DIR%\ndk-build.cmd
    echo Please verify your NDK installation
    pause
    exit /b 1
)

REM Navigate to JNI directory
cd UVCCamera\libuvccamera\src\main
if errorlevel 1 (
    echo ERROR: Could not navigate to UVCCamera\libuvccamera\src\main
    pause
    exit /b 1
)

echo Building native libraries...
echo.

REM Run ndk-build
"%NDK_DIR%\ndk-build.cmd" -j8

if errorlevel 1 (
    echo.
    echo ========================================
    echo BUILD FAILED!
    echo ========================================
    cd ..\..\..\..
    pause
    exit /b 1
)

echo.
echo ========================================
echo BUILD SUCCESSFUL!
echo ========================================
echo.
echo Native libraries have been built in:
echo   UVCCamera\libuvccamera\src\main\libs\
echo.
echo Next steps:
echo   1. Uncomment 'implementation project(:libuvccamera)' in build.gradle
echo   2. Follow INTEGRATION.md to complete the Kotlin integration
echo.

cd ..\..\..\..
pause
