#!/bin/bash
# Build script for libuvccamera native libraries
# This script builds the JNI libraries required for UVC camera streaming

echo "========================================"
echo "Building libuvccamera Native Libraries"
echo "========================================"
echo

# Check if NDK is configured
if [ ! -f "local.properties" ]; then
    echo "ERROR: local.properties not found!"
    echo "Please create local.properties with ndk.dir setting"
    echo "Example:"
    echo "  sdk.dir=/Users/YourName/Library/Android/sdk"
    echo "  ndk.dir=/Users/YourName/Library/Android/sdk/ndk/25.2.9519653"
    exit 1
fi

# Parse NDK path from local.properties
NDK_DIR=$(grep "ndk.dir" local.properties | cut -d'=' -f2 | tr -d '\r')

if [ -z "$NDK_DIR" ]; then
    echo "ERROR: ndk.dir not found in local.properties!"
    echo "Please add ndk.dir to local.properties"
    echo "Example: ndk.dir=/Users/YourName/Library/Android/sdk/ndk/25.2.9519653"
    exit 1
fi

echo "NDK Directory: $NDK_DIR"
echo

# Check if ndk-build exists
if [ ! -f "$NDK_DIR/ndk-build" ]; then
    echo "ERROR: ndk-build not found at: $NDK_DIR/ndk-build"
    echo "Please verify your NDK installation"
    exit 1
fi

# Navigate to JNI directory
cd UVCCamera/libuvccamera/src/main || {
    echo "ERROR: Could not navigate to UVCCamera/libuvccamera/src/main"
    exit 1
}

echo "Building native libraries..."
echo

# Run ndk-build
"$NDK_DIR/ndk-build" -j8

if [ $? -ne 0 ]; then
    echo
    echo "========================================"
    echo "BUILD FAILED!"
    echo "========================================"
    cd ../../../..
    exit 1
fi

echo
echo "========================================"
echo "BUILD SUCCESSFUL!"
echo "========================================"
echo
echo "Native libraries have been built in:"
echo "  UVCCamera/libuvccamera/src/main/libs/"
echo
echo "Next steps:"
echo "  1. Uncomment 'implementation project(:libuvccamera)' in build.gradle"
echo "  2. Follow INTEGRATION.md to complete the Kotlin integration"
echo

cd ../../../..
