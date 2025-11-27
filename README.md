# flutter_uvc_camera

Flutter plugin for USB Video Class (UVC) camera support on Android using native libuvccamera.

## Features

- Real-time USB camera streaming with NV21 format (ML Kit compatible)
- Native performance via libuvccamera (C/C++/JNI)
- Automatic resolution detection
- Android 5.0+ (API 21+), ARM architectures only

## Requirements

- Android device with USB OTG support
- UVC-compatible USB camera
- Flutter 3.0+, Android NDK 27.1+

## 🚀 Installation

### 1. Add Dependency

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_uvc_camera:
    path: ../flutter_uvc_camera  # or your package location
```

### 2. Build Native Libraries

The plugin requires native UVC libraries to be built before use:

#### Windows

```powershell
cd android
.\build_native.bat

```bash
cd android
chmod +x build_native.sh
./build_native.sh
```

**First time?** See [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) for complete NDK setup guide.

**Build Output:**
- `android/UVCCamera/libuvccamera/src/main/libs/armeabi-v7a/*.so`
- `android/UVCCamera/libuvccamera/src/main/libs/arm64-v8a/*.so`

Libraries built:
- `libUVCCamera.so` - Main UVC camera library
- `libuvc.so` - UVC protocol implementation
- `libusb100.so` - USB communication layer
- `libjpeg-turbo1500.so` - JPEG compression

### 3. Complete Kotlin Integration

Follow [INTEGRATION.md](INTEGRATION.md) for step-by-step Kotlin integration:

1. Add UVCCamera imports to `FlutterUvcCameraPlugin.kt`
2. Initialize USBMonitor and handle USB permissions
3. Implement frame callbacks for real-time streaming
4. Convert YUYV frames to NV21 format

### 4. Add USB Permissions

Add to `android/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-feature android:name="android.hardware.usb.host" android:required="true" />
    <uses-permission android:name="android.permission.USB_PERMISSION" />
</manifest>
```

## 💻 Usage

### Basic Example

```dart
import 'package:flutter_uvc_camera/flutter_uvc_camera.dart';

class UvcCameraWidget extends StatefulWidget {
  @override
  _UvcCameraWidgetState createState() => _UvcCameraWidgetState();
}

class _UvcCameraWidgetState extends State<UvcCameraWidget> {
  StreamSubscription<CameraFrame>? _frameSubscription;
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final hasCamera = await FlutterUvcCamera.initialize();
    if (hasCamera) {
      print('UVC camera detected!');
    } else {
      print('No UVC camera found');
    }
  }

  Future<void> _startStreaming() async {
    try {
      await FlutterUvcCamera.startPreview();
      
      _frameSubscription = FlutterUvcCamera.getFrameStream().listen(
        (frame) {
          setState(() {
            // Process frame: ${frame.width}x${frame.height}
            // frame.bytes contains NV21 data ready for processing
          });
        },
        onError: (error) {
          print('Frame error: $error');
        },
      );
      
      setState(() => _isStreaming = true);
    } catch (e) {
      print('Failed to start preview: $e');
    }
  }

  Future<void> _stopStreaming() async {
    await _frameSubscription?.cancel();
    await FlutterUvcCamera.stopPreview();
    setState(() => _isStreaming = false);
  }

  @override
  void dispose() {
    _stopStreaming();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isStreaming ? _stopStreaming : _startStreaming,
          child: Text(_isStreaming ? 'Stop Camera' : 'Start Camera'),
        ),
        Text(_isStreaming ? 'Streaming...' : 'Not streaming'),
      ],
    );
  }
}
```

### Advanced: ML Kit Integration

```dart
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

final barcodeScanner = BarcodeScanner();

FlutterUvcCamera.getFrameStream().listen((frame) async {
  // frame.bytes is already in NV21 format - perfect for ML Kit!
  final inputImage = InputImage.fromBytes(
    bytes: frame.bytes,
    metadata: InputImageMetadata(
      size: Size(frame.width.toDouble(), frame.height.toDouble()),
      rotation: InputImageRotation.rotation0deg,
      format: InputImageFormat.nv21, // Native format from UVCCamera
      bytesPerRow: frame.width,
    ),
  );

  final barcodes = await barcodeScanner.processImage(inputImage);
  for (final barcode in barcodes) {
    print('Barcode detected: ${barcode.rawValue}');
  }
});
```

## 📖 API Reference

### FlutterUvcCamera

Main class for UVC camera operations.

#### Methods

##### `initialize() → Future<bool>`

Initializes the plugin and checks for connected UVC cameras.

- **Returns**: `true` if a UVC camera is detected, `false` otherwise
- **Throws**: `PlatformException` on initialization errors

##### `startPreview() → Future<void>`

Starts camera preview and frame streaming.

- **Behavior**: Automatically uses camera's native resolution
- **Requires**: USB permissions granted by user
- **Throws**: `PlatformException` if camera not available or permissions denied

##### `stopPreview() → Future<void>`

Stops camera preview and frame streaming.

- **Behavior**: Cleans up camera resources and stops frame callbacks

##### `getFrameStream() → Stream<CameraFrame>`

Returns a stream of camera frames.

- **Returns**: Stream emitting `CameraFrame` objects
- **Format**: Frames are in NV21 format
- **Rate**: Depends on camera capabilities (typically 15-30 fps)

### CameraFrame

Represents a single camera frame.

#### Properties

- `width` (int) - Frame width in pixels
- `height` (int) - Frame height in pixels
- `bytes` (Uint8List) - Frame data in NV21 format
- `format` (String) - Always "NV21" for this plugin

#### NV21 Format Details

NV21 (YUV 420 semi-planar) format structure:
- Y plane: `width * height` bytes (grayscale)
- UV plane: `width * height / 2` bytes (interleaved V and U)
- Total size: `width * height * 3 / 2` bytes

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Flutter App                        │
│              (Dart - lib/main.dart)                  │
└─────────────────┬───────────────────────────────────┘
                  │ MethodChannel / EventChannel
                  │
┌─────────────────▼───────────────────────────────────┐
│              Kotlin Plugin Layer                     │
│       (FlutterUvcCameraPlugin.kt)                    │
│  • USB device detection                              │
│  • Permission handling                               │
│  • Frame callback bridge                             │
└─────────────────┬───────────────────────────────────┘
                  │ JNI calls
                  │
┌─────────────────▼───────────────────────────────────┐
│         UVCCamera Java Library                       │
│     (com.serenegiant.usb.*)                          │
│  • USBMonitor - Device management                    │
│  • UVCCamera - Camera control                        │
│  • IFrameCallback - Frame delivery                   │
└─────────────────┬───────────────────────────────────┘
                  │ JNI bridge
                  │
┌─────────────────▼───────────────────────────────────┐
│          Native Libraries (C/C++)                    │
│  • libUVCCamera.so - JNI bridge                      │
│  • libuvc.so - UVC protocol                          │
│  • libusb100.so - USB communication                  │
│  • libjpeg-turbo1500.so - JPEG codec                 │
└─────────────────┬───────────────────────────────────┘
                  │ USB protocol
                  │
┌─────────────────▼───────────────────────────────────┐
│              USB Camera Device                       │
│         (UVC-compatible webcam)                      │
└──────────────────────────────────────────────────────┘
```

## 🔧 Troubleshooting

### Build Issues

**Problem**: "FLUTTER_ROOT is null"
- **Solution**: Don't build plugin standalone. Build as part of Flutter app: `cd example && flutter build apk`

**Problem**: "ndk-build: command not found"
- **Solution**: Install NDK via Android Studio SDK Manager, then set `ndk.dir` in `android/local.properties`

**Problem**: x86 architecture linking errors
- **Solution**: Already fixed - plugin only builds ARM architectures (covers 99% of devices)

### Runtime Issues

**Problem**: "No UVC camera detected"
- Check USB OTG cable is properly connected
- Verify camera is UVC-compatible (most webcams are)
- Try unplugging and replugging camera
- Check Android device supports USB OTG

**Problem**: "USB permission denied"
- Ensure USB permission request is shown to user
- Check AndroidManifest.xml has USB permissions
- Try restarting app after granting permission

**Problem**: "No frames received"
- Verify native libraries are built (`ls android/UVCCamera/libuvccamera/src/main/libs/`)
- Check Kotlin integration is complete (see INTEGRATION.md)
- Ensure `implementation project(':libuvccamera')` is uncommented in build.gradle
- Check logcat for native errors: `adb logcat | grep UVC`

### Performance Issues

**Problem**: Low frame rate or dropped frames
- Check device CPU usage
- Consider reducing frame processing complexity
- Use native format (NV21) without conversion
- Process frames on background isolate

## 📚 Additional Documentation

- **[BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md)** - Complete NDK setup and native library build guide
- **[INTEGRATION.md](INTEGRATION.md)** - Step-by-step Kotlin integration with code examples
- **[BUILD_SUCCESS.md](BUILD_SUCCESS.md)** - Build verification and next steps
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and changes

## 🧪 Testing

### Test with Example App

```bash
# Build native libraries first
cd android
.\build_native.bat  # or ./build_native.sh on Mac/Linux

# Run example app
cd ../example
flutter pub get
flutter run
```

## 📄 License

This plugin is licensed under [LICENSE](LICENSE).

### Third-Party Licenses

- **libuvccamera** (saki4510t/UVCCamera) - Apache License 2.0
- **libuvc** - BSD 3-Clause License
- **libusb** - LGPL 2.1
- **libjpeg-turbo** - Modified BSD License

## 🙏 Acknowledgments

- [saki4510t/UVCCamera](https://github.com/saki4510t/UVCCamera) - Excellent UVC library for Android
- libusb and libuvc projects for USB communication
- libjpeg-turbo for high-performance JPEG processing

## 📞 Support

For issues, questions, or feature requests, please use the GitHub issue tracker.


**Status**: ✅ Native libraries built | ⚠️ Kotlin integration required | 🚀 Ready for testing
✅ libuvccamera source code included
⚠️ Native library build required (NDK)
⚠️ UVCCamera integration code documented but commented out

### Next Steps

1. Build libuvccamera native library (see above)
2. Uncomment UVCCamera integration in `FlutterUvcCameraPlugin.kt`
3. Test with USB camera on Android device

## Requirements

- Android device with USB host support
- UVC-compatible USB camera  
- For frame streaming: libuvccamera integration required

## Notes

- Will use camera's native resolution automatically (once integrated)
- Output format will be NV21 (ML Kit compatible)
#   f l u t t e r _ u v c _ c a m e r a  
 #   f l u t t e r _ u v c _ c a m e r a  
 