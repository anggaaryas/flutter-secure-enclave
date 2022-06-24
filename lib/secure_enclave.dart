
import 'dart:typed_data';

import 'secure_enclave_platform_interface.dart';

class SecureEnclave implements SecureEnclaveBehaviour{
  Future<String?> getPlatformVersion() {
    return SecureEnclavePlatform.instance.getPlatformVersion();
  }

  @override
  Future<String?> decrypt(String tag, Uint8List message) {
    return SecureEnclavePlatform.instance.decrypt(tag, message);
  }

  @override
  Future<Uint8List?> encrypt(String tag, String message) {
    return SecureEnclavePlatform.instance.encrypt(tag, message);
  }

  @override
  Future<String?> getPublicKey(String tag) {
    return SecureEnclavePlatform.instance.getPublicKey(tag);
  }
}
