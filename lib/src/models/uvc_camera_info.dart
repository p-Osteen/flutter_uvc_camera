/// Information about a detected UVC camera device
class UvcCameraInfo {
  /// Device name
  final String deviceName;
  
  /// Vendor ID
  final int vendorId;
  
  /// Product ID
  final int productId;
  
  /// Device path or identifier
  final String devicePath;

  const UvcCameraInfo({
    required this.deviceName,
    required this.vendorId,
    required this.productId,
    required this.devicePath,
  });

  @override
  String toString() {
    return 'UvcCameraInfo(name: $deviceName, vendorId: $vendorId, productId: $productId, path: $devicePath)';
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceName': deviceName,
      'vendorId': vendorId,
      'productId': productId,
      'devicePath': devicePath,
    };
  }

  factory UvcCameraInfo.fromMap(Map<dynamic, dynamic> map) {
    return UvcCameraInfo(
      deviceName: map['deviceName'] as String,
      vendorId: map['vendorId'] as int,
      productId: map['productId'] as int,
      devicePath: map['devicePath'] as String,
    );
  }
}
