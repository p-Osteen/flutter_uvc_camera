# flutter_uvc_camera_example

Example app demonstrating the usage of flutter_uvc_camera plugin.

## Features

- Detect UVC cameras
- Start/stop camera preview
- Display frame statistics (FPS, resolution, format)
- Real-time frame counter

## Running the Example

```bash
cd example
flutter run
```

## Testing

Connect a USB camera to your Android device/TV and launch the app. The camera should be automatically detected and you can start the preview to see frame statistics.

## Expected Output

When working correctly:
- Camera Status shows "Initialized: ✅ Yes"
- Available cameras listed with vendor/product IDs
- Start Preview button enables streaming
- Frame count and FPS update in real-time
