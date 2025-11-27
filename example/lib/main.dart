import 'package:flutter/material.dart';
import 'package:flutter_uvc_camera/flutter_uvc_camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UVC Camera Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const UvcCameraTestPage(),
    );
  }
}

class UvcCameraTestPage extends StatefulWidget {
  const UvcCameraTestPage({super.key});

  @override
  State<UvcCameraTestPage> createState() => _UvcCameraTestPageState();
}

class _UvcCameraTestPageState extends State<UvcCameraTestPage> {
  bool _isInitialized = false;
  bool _isStreaming = false;
  List<UvcCameraInfo> _cameras = [];
  CameraFrame? _latestFrame;
  int _frameCount = 0;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    setState(() => _isInitialized = false);
    
    final hasCamera = await FlutterUvcCamera.initialize();
    
    if (hasCamera) {
      final cameras = await FlutterUvcCamera.getAvailableCameras();
      setState(() {
        _isInitialized = true;
        _cameras = cameras;
      });
    } else {
      setState(() => _isInitialized = false);
    }
  }

  Future<void> _startPreview() async {
    final started = await FlutterUvcCamera.startPreview();

    if (started) {
      setState(() {
        _isStreaming = true;
        _frameCount = 0;
        _startTime = DateTime.now();
      });

      FlutterUvcCamera.getFrameStream().listen((frame) {
        setState(() {
          _latestFrame = frame;
          _frameCount++;
        });
      });
    }
  }

  Future<void> _stopPreview() async {
    await FlutterUvcCamera.stopPreview();
    setState(() {
      _isStreaming = false;
      _latestFrame = null;
    });
  }

  double get _fps {
    if (_startTime == null || _frameCount == 0) return 0.0;
    final elapsed = DateTime.now().difference(_startTime!).inMilliseconds;
    if (elapsed == 0) return 0.0;
    return (_frameCount * 1000) / elapsed;
  }

  @override
  void dispose() {
    FlutterUvcCamera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UVC Camera Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Initialization Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Camera Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Initialized: ${_isInitialized ? "✅ Yes" : "❌ No"}'),
                    Text('Cameras Found: ${_cameras.length}'),
                    if (_cameras.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('Available Cameras:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ..._cameras.map((cam) => Padding(
                            padding: const EdgeInsets.only(left: 16, top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('• ${cam.deviceName}'),
                                Text('  VID: ${cam.vendorId}, PID: ${cam.productId}',
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Streaming Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stream Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Streaming: ${_isStreaming ? "✅ Active" : "⏸️ Stopped"}'),
                    Text('Frames Received: $_frameCount'),
                    Text('FPS: ${_fps.toStringAsFixed(1)}'),
                    if (_latestFrame != null) ...[
                      const SizedBox(height: 8),
                      Text('Latest Frame:',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('  Size: ${_latestFrame!.width}x${_latestFrame!.height}'),
                      Text('  Format: ${_latestFrame!.format}'),
                      Text('  Bytes: ${_latestFrame!.bytes.length}'),
                      Text(
                          '  Timestamp: ${DateTime.fromMillisecondsSinceEpoch(_latestFrame!.timestamp).toString().split('.').first}'),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Controls
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isInitialized && !_isStreaming ? _startPreview : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Preview'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isStreaming ? _stopPreview : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Preview'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _initializeCamera,
              icon: const Icon(Icons.refresh),
              label: const Text('Re-initialize'),
            ),
          ],
        ),
      ),
    );
  }
}
