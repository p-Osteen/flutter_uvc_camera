# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### 🐛 Fixed
- USB permission request not working reliably on Android 12+ (API 31+)
  - Added FLAG_MUTABLE to PendingIntent for USB permission dialog
  - Added BuildCheck.isAPI31() helper method for Android 12+ detection
  - Fixes intermittent permission dialog not appearing issue

## [0.2.0] - 2025-11-27

### ✨ Added
- Native library integration (libuvccamera, libuvc, libusb, libjpeg-turbo)
- NDK build system with automated scripts (build_native.bat, build_native.sh)
- ARM architecture support (armeabi-v7a, arm64-v8a)
- Complete UVCCamera Kotlin integration with frame streaming
- USB device detection and permission handling
- Real-time frame delivery via MethodChannel
- SurfaceTexture support for preview functionality
- Comprehensive documentation (BUILD_INSTRUCTIONS.md)

### 🔧 Changed
- Updated Application.mk: android-21, ARM-only (removed x86/mips)
- Gradle configuration with conditional Flutter dependencies
- Minimum API level 21 (Android 5.0+)
- Enhanced device filtering to only select actual UVC video devices

### 🐛 Fixed
- FLUTTER_ROOT null error in standalone builds
- x86 PIC linking errors (removed x86 architectures)
- NDK compatibility with modern versions
- Device selection logic (filters out non-video USB devices)
- Preview thread initialization with dummy SurfaceTexture
- Package name structure (com.flutter_uvc_camera)

## [0.1.0] - 2025-11-26

### ✨ Added
- Initial plugin structure
- USB device detection API
- Frame streaming API specification
- Example app scaffold
- Basic Flutter plugin boilerplate

---

<div align="center">

[View Full History](https://github.com/p-Osteen/flutter_uvc_camera/commits/main)

</div>
