# Changelog

## [0.2.0] - 2025-11-27

### Added
- Native library integration (libuvccamera, libuvc, libusb, libjpeg-turbo)
- NDK build system with automated scripts (`build_native.bat`, `build_native.sh`)
- ARM architecture support (armeabi-v7a, arm64-v8a)
- Enhanced Kotlin plugin with frame streaming structure
- USB permission handling
- Comprehensive documentation (BUILD_INSTRUCTIONS.md, INTEGRATION.md)

### Changed
- Updated Application.mk: android-21, ARM-only (removed x86/mips)
- Gradle configuration with conditional Flutter dependencies
- Minimum API level 21 (Android 5.0+)

### Fixed
- FLUTTER_ROOT null error in standalone builds
- x86 PIC linking errors (removed x86 architectures)
- NDK compatibility with modern versions

## [0.1.0] - 2025-11-26

### Added
- Initial plugin structure
- USB device detection API
- Frame streaming API (simulated)
- Example app
