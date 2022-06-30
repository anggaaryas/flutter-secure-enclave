
import 'dart:typed_data';

import 'secure_enclave_platform_interface.dart';

class SecureEnclave implements SecureEnclaveBehaviour{
  Future<String?> getPlatformVersion() {
    return SecureEnclavePlatform.instance.getPlatformVersion();
  }

  @override
  Future<String?> decrypt(String tag, Uint8List message, bool isRequiresBiometric) {
    return SecureEnclavePlatform.instance.decrypt(tag, message, isRequiresBiometric);
  }

  @override
  Future<Uint8List?> encrypt(String tag, String message, bool isRequiresBiometric) {
    return SecureEnclavePlatform.instance.encrypt(tag, message, isRequiresBiometric);
  }

  @override
  Future<String?> getPublicKey(String tag, bool isRequiresBiometric) {
    return SecureEnclavePlatform.instance.getPublicKey(tag, isRequiresBiometric);
  }
}
