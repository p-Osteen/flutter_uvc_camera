package com.flutter_uvc_camera

import android.content.Context
import android.graphics.SurfaceTexture
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.serenegiant.usb.USBMonitor
import com.serenegiant.usb.UVCCamera
import java.nio.ByteBuffer

class FlutterUvcCameraPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val mainHandler = Handler(Looper.getMainLooper())
    private var usbManager: UsbManager? = null
    private var usbMonitor: USBMonitor? = null
    private var uvcCamera: UVCCamera? = null
    private var surfaceTexture: SurfaceTexture? = null
    private var isStreaming = false
    private var pendingStartResult: MethodChannel.Result? = null

    companion object {
        private const val TAG = "FlutterUvcCamera"
        private const val CHANNEL_NAME = "flutter_uvc_camera"

        init {
            try {
                System.loadLibrary("uvcfilm") // adjust to your built native lib name if different
            } catch (_: UnsatisfiedLinkError) { }
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
        usbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
        Log.d(TAG, "Plugin attached to engine")
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                // Just check for camera presence without requesting permissions
                val hasCamera = findUvcCamera() != null
                Log.d(TAG, "Initialize: UVC camera ${if (hasCamera) "found" else "not found"}")
                result.success(hasCamera)
            }
            "getAvailableCameras" -> {
                val cameras = getAvailableCameras()
                Log.d(TAG, "Found ${cameras.size} UVC camera(s)")
                result.success(cameras)
            }
            "startPreview" -> {
                startPreview(result)
            }
            "stopPreview" -> {
                stopPreview(result)
            }
            else -> result.notImplemented()
        }
    }

    private fun findUvcCamera(): UsbDevice? {
        val deviceList = usbManager?.deviceList ?: return null
        return deviceList.values.find { device ->
            // Only match devices with actual video interfaces (class 14)
            // Don't match class 239 (Miscellaneous) unless it has video interfaces
            device.deviceClass == 14 || hasVideoInterface(device)
        }
    }

    private fun hasVideoInterface(device: UsbDevice): Boolean {
        for (i in 0 until device.interfaceCount) {
            val intf = device.getInterface(i)
            if (intf.interfaceClass == 14) {
                return true
            }
        }
        return false
    }

    private fun getAvailableCameras(): List<Map<String, Any>> {
        val deviceList = usbManager?.deviceList ?: return emptyList()
        val cameras = mutableListOf<Map<String, Any>>()
        deviceList.values.forEach { device ->
            // Only include devices with video interfaces
            if (device.deviceClass == 14 || hasVideoInterface(device)) {
                cameras.add(
                    mapOf(
                        "deviceName" to (device.productName ?: "Unknown UVC Camera"),
                        "vendorId" to device.vendorId,
                        "productId" to device.productId,
                        "devicePath" to device.deviceName
                    )
                )
            }
        }
        return cameras
    }

    private val usbDeviceConnectListener = object : USBMonitor.OnDeviceConnectListener {
        override fun onAttach(device: UsbDevice) {
            Log.d(TAG, "USB device attached: ${device.deviceName}")
        }
        override fun onDettach(device: UsbDevice) {
            Log.d(TAG, "USB device detached: ${device.deviceName}")
            if (uvcCamera != null) {
                stopInternal()
            }
        }
        override fun onConnect(device: UsbDevice, ctrlBlock: USBMonitor.UsbControlBlock?, createNew: Boolean) {
            try {
                if (ctrlBlock == null) {
                    pendingStartResult?.let {
                        it.error("NO_CONTROL_BLOCK", "UsbControlBlock is null", null)
                        pendingStartResult = null
                    }
                    return
                }
                uvcCamera = UVCCamera().apply {
                    open(ctrlBlock)
                }
                val width = 640
                val height = 480
                try {
                    uvcCamera?.setPreviewSize(width, height, UVCCamera.DEFAULT_PREVIEW_MODE)
                    Log.d(TAG, "Preview size set: ${width}x${height}")
                } catch (e: Exception) {
                    Log.w(TAG, "setPreviewSize failed, trying without specifying mode", e)
                    uvcCamera?.setPreviewSize(width, height, 0)
                }
                
                // Store dimensions for frame callback
                val frameWidth = width
                val frameHeight = height
                
                Log.d(TAG, "Setting up frame callback for ${frameWidth}x${frameHeight}")
                uvcCamera?.setFrameCallback({ frame: ByteBuffer ->
                    Log.d(TAG, "Frame callback triggered: ${frame.remaining()} bytes")
                    val bytes = ByteArray(frame.remaining())
                    frame.get(bytes)
                    sendFrameToFlutter(bytes, frameWidth, frameHeight)
                }, UVCCamera.PIXEL_FORMAT_NV21)
                Log.d(TAG, "Frame callback registered")
                
                // Create dummy SurfaceTexture to enable preview
                surfaceTexture = SurfaceTexture(10)
                surfaceTexture?.setDefaultBufferSize(width, height)
                uvcCamera?.setPreviewTexture(surfaceTexture)
                Log.d(TAG, "SurfaceTexture set")
                
                try {
                    Log.d(TAG, "Calling startPreview()")
                    uvcCamera?.startPreview()
                    isStreaming = true
                    Log.d(TAG, "startPreview() completed successfully")
                    pendingStartResult?.success(true)
                    pendingStartResult = null
                } catch (e: Exception) {
                    Log.e(TAG, "startPreview failed", e)
                    pendingStartResult?.error("START_FAILED", e.message, null)
                    pendingStartResult = null
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error onConnect", e)
                pendingStartResult?.error("CONNECT_ERROR", e.message, null)
                pendingStartResult = null
            }
        }
        override fun onDisconnect(device: UsbDevice, ctrlBlock: USBMonitor.UsbControlBlock?) {
            Log.d(TAG, "USB device disconnected: ${device.deviceName}")
            stopInternal()
        }
        override fun onCancel(device: UsbDevice) {
            Log.d(TAG, "USB permission cancelled: ${device.deviceName}")
            pendingStartResult?.error("PERMISSION_CANCELLED", "Permission cancelled", null)
            pendingStartResult = null
        }
    }

    private fun startPreview(result: MethodChannel.Result) {
        if (isStreaming) {
            result.success(false)
            return
        }
        
        // Initialize USBMonitor when actually starting preview
        if (usbMonitor == null) {
            Log.d(TAG, "Initializing USBMonitor for preview")
            try {
                usbMonitor = USBMonitor(context, usbDeviceConnectListener)
                usbMonitor?.register()
            } catch (e: SecurityException) {
                Log.e(TAG, "SecurityException during USBMonitor initialization", e)
                result.error("PERMISSION_ERROR", "USB permission error: ${e.message}", null)
                return
            } catch (e: Exception) {
                Log.e(TAG, "Exception during USBMonitor initialization", e)
                result.error("INIT_ERROR", "Failed to initialize USB: ${e.message}", null)
                return
            }
        }
        
        val device = findUvcCamera()
        if (device == null) {
            result.error("NO_CAMERA", "No UVC camera found", null)
            return
        }
        val hasPermission = usbManager?.hasPermission(device) ?: false
        if (hasPermission) {
            try {
                val ctrlBlock = usbMonitor?.openDevice(device)
                if (ctrlBlock != null) {
                    usbDeviceConnectListener.onConnect(device, ctrlBlock, true)
                    result.success(true)
                    return
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed to open device", e)
            }
        }
        pendingStartResult = result
        try {
            usbMonitor?.requestPermission(device)
        } catch (e: Exception) {
            pendingStartResult = null
            result.error("PERMISSION_REQUEST_FAILED", e.message, null)
        }
    }

    private fun stopPreview(result: MethodChannel.Result) {
        if (!isStreaming) {
            result.success(null)
            return
        }
        try {
            stopInternal()
            result.success(null)
        } catch (e: Exception) {
            result.error("STOP_PREVIEW_ERROR", e.message, null)
        }
    }

    private fun stopInternal() {
        try {
            uvcCamera?.stopPreview()
        } catch (_: Exception) { }
        try {
            uvcCamera?.close()
        } catch (_: Exception) { }
        try {
            surfaceTexture?.release()
        } catch (_: Exception) { }
        surfaceTexture = null
        uvcCamera = null
        isStreaming = false
    }
    
    private fun cleanupResources() {
        Log.d(TAG, "Cleaning up resources")
        stopInternal()
        try {
            usbMonitor?.unregister()
            usbMonitor?.destroy()
        } catch (e: Exception) {
            Log.w(TAG, "Error during cleanup: ${e.message}")
        }
        usbMonitor = null
        pendingStartResult = null
    }

    private fun sendFrameToFlutter(data: ByteArray, width: Int, height: Int) {
        Handler(Looper.getMainLooper()).post {
            val frameData = mapOf(
                "bytes" to data,
                "width" to width,
                "height" to height,
                "format" to "NV21",
                "timestamp" to System.currentTimeMillis()
            )
            Log.d(TAG, "Sending frame: ${width}x${height}, ${data.size} bytes")
            channel.invokeMethod("onFrameAvailable", frameData)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        cleanupResources()
        Log.d(TAG, "Plugin detached from engine")
    }
}
