import 'dart:typed_data';

/// Represents a single frame from the UVC camera
class CameraFrame {
  /// Raw frame bytes (typically NV21 or YUV420 format)
  final Uint8List bytes;
  
  /// Frame width in pixels
  final int width;
  
  /// Frame height in pixels
  final int height;
  
  /// Frame format (e.g., 'nv21', 'yuv420', 'mjpeg')
  final String format;
  
  /// Frame timestamp in milliseconds
  final int timestamp;

  const CameraFrame({
    required this.bytes,
    required this.width,
    required this.height,
    required this.format,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'CameraFrame(${width}x$height, format: $format, size: ${bytes.length} bytes, timestamp: $timestamp)';
  }
}
