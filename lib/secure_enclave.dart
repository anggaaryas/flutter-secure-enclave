
import 'dart:typed_data';

import 'package:secure_enclave/src/model/method_result.dart';

import 'src/secure_enclave_platform_interface.dart';

class SecureEnclave implements SecureEnclaveBehaviour{
  @override
  Future<MethodResult<String?>> decrypt(String tag, Uint8List message, bool isRequiresBiometric) {
    return SecureEnclavePlatform.instance.decrypt(tag, message, isRequiresBiometric);
  }

  @override
  Future<MethodResult<Uint8List?>> encrypt(String tag, String message, bool isRequiresBiometric) {
    return SecureEnclavePlatform.instance.encrypt(tag, message, isRequiresBiometric);
  }

  @override
  Future<MethodResult<String?>> getPublicKey(String tag, bool isRequiresBiometric) {
    return SecureEnclavePlatform.instance.getPublicKey(tag, isRequiresBiometric);
  }

  @override
  Future<MethodResult<bool>> removeKey(String tag) {
    return SecureEnclavePlatform.instance.removeKey(tag);
  }

  @override
  Future<MethodResult> cobaError() {
    return SecureEnclavePlatform.instance.cobaError();
  }
}
