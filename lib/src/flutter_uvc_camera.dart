import 'dart:async';
import 'package:flutter/services.dart';
import 'models/camera_frame.dart';
import 'models/uvc_camera_info.dart';

/// Flutter plugin for USB Video Class (UVC) camera support
class FlutterUvcCamera {
  static const MethodChannel _channel = MethodChannel('flutter_uvc_camera');
  static StreamController<CameraFrame>? _frameController;
  static bool _isInitialized = false;

  /// Initialize the UVC camera plugin
  /// 
  /// Returns true if UVC cameras are available
  static Future<bool> initialize() async {
    try {
      final result = await _channel.invokeMethod<bool>('initialize');
      _isInitialized = result ?? false;
      return _isInitialized;
    } catch (e) {
      print('FlutterUvcCamera: Initialize error - $e');
      return false;
    }
  }

  /// Get list of available UVC cameras
  /// 
  /// Returns list of [UvcCameraInfo] for detected cameras
  static Future<List<UvcCameraInfo>> getAvailableCameras() async {
    try {
      final result = await _channel.invokeMethod<List>('getAvailableCameras');
      if (result == null) return [];
      
      return result
          .map((camera) => UvcCameraInfo.fromMap(camera as Map))
          .toList();
    } catch (e) {
      print('FlutterUvcCamera: Get cameras error - $e');
      return [];
    }
  }

  /// Start camera preview and frame streaming
  /// 
  /// Uses camera's native resolution and outputs NV21 format
  /// 
  /// Returns true if preview started successfully
  static Future<bool> startPreview() async {
    try {
      final result = await _channel.invokeMethod<bool>('startPreview');
      return result ?? false;
    } catch (e) {
      print('FlutterUvcCamera: Start preview error - $e');
      return false;
    }
  }

  /// Stop camera preview and frame streaming
  static Future<void> stopPreview() async {
    try {
      await _channel.invokeMethod('stopPreview');
    } catch (e) {
      print('FlutterUvcCamera: Stop preview error - $e');
    }
  }

  /// Get stream of camera frames
  /// 
  /// Returns [Stream<CameraFrame>] that emits frames as they arrive
  static Stream<CameraFrame> getFrameStream() {
    _frameController ??= StreamController<CameraFrame>.broadcast(
      onListen: () {
        _channel.setMethodCallHandler((call) async {
          if (call.method == 'onFrameAvailable') {
            try {
              final data = call.arguments as Map;
              final frame = CameraFrame(
                bytes: data['bytes'] as Uint8List,
                width: data['width'] as int,
                height: data['height'] as int,
                format: data['format'] as String,
                timestamp: data['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
              );
              _frameController?.add(frame);
            } catch (e) {
              print('FlutterUvcCamera: Frame parse error - $e');
            }
          }
        });
      },
      onCancel: () {
        stopPreview();
      },
    );
    
    return _frameController!.stream;
  }

  /// Dispose the plugin and clean up resources
  static Future<void> dispose() async {
    await stopPreview();
    await _frameController?.close();
    _frameController = null;
    _isInitialized = false;
  }

  /// Check if plugin is initialized
  static bool get isInitialized => _isInitialized;
}
