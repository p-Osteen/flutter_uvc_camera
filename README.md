# flutter_uvc_camera

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter)](https://flutter.dev)
[![Android](https://img.shields.io/badge/Android-5.0%2B-3DDC84?logo=android)](https://developer.android.com)
[![NDK](https://img.shields.io/badge/NDK-27.1%2B-blue)](https://developer.android.com/ndk)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Flutter plugin for USB Video Class (UVC) camera support on Android using native libuvccamera.

## ✨ Features

- ⚡ Real-time USB camera streaming with NV21 format (ML Kit compatible)
- 🚀 Native performance via libuvccamera (C/C++/JNI)
- 📱 Automatic resolution detection
- 🎯 Android 5.0+ (API 21+), ARM architectures only

## 📋 Requirements

- Android device with USB OTG support
- UVC-compatible USB camera
- Flutter 3.0+
- Android NDK 27.1+

## 🚀 Installation

### 1. Add Dependency

```yaml
dependencies:
  flutter_uvc_camera:
    path: ../flutter_uvc_camera
```

### 2. Build Native Libraries

**Windows:**
```powershell
cd android
.uild_native.bat
```

**macOS/Linux:**
```bash
cd android
chmod +x build_native.sh
./build_native.sh
```

### 3. Add USB Permissions

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-feature android:name="android.hardware.usb.host" android:required="true" />
    <uses-permission android:name="android.permission.USB_PERMISSION" />
</manifest>
```

## 💻 Usage

### Basic Example

```dart
// shortened for brevity
```

### ML Kit Integration

```dart
// shortened for brevity
```

## 📘 API Reference

// shortened for brevity

## 🏗️ Architecture

```
[diagram omitted for md]
```

## 🔧 Troubleshooting

// shortened for brevity

## 📚 Additional Documentation

- BUILD_INSTRUCTIONS.md  
- INTEGRATION.md  
- BUILD_SUCCESS.md  
- CHANGELOG.md  

## 🧪 Testing

```bash
cd android
./build_native.sh

cd ../example
flutter run
```

## 📄 License

MIT License

## 🙏 Acknowledgments

- saki4510t/UVCCamera  
- libusb  
- libuvc  
- libjpeg-turbo  

## 📞 Support

Open an issue on GitHub.
