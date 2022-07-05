
import 'dart:typed_data';

export 'package:secure_enclave/src/model/access_control.dart';


import 'package:secure_enclave/src/model/access_control.dart';
import 'package:secure_enclave/src/model/method_result.dart';

import 'src/secure_enclave_platform_interface.dart';

class SecureEnclave implements SecureEnclaveBehaviour{

  static const defaultRequiredAuthForAccessControlOption = [AccessControlOption.userPresence, AccessControlOption.privateKeyUsage];

  static const defaulAccessControlOption = [AccessControlOption.privateKeyUsage];

  @override
  Future<MethodResult<String?>> decrypt({required Uint8List message, required  AccessControl accessControl}) {
    return SecureEnclavePlatform.instance.decrypt(
      message: message,
      accessControl: accessControl,
    );
  }

  @override
  Future<MethodResult<Uint8List?>> encrypt({ required  String message, required AccessControl accessControl}) {
    return SecureEnclavePlatform.instance.encrypt(
      accessControl: accessControl,
      message: message,
    );
  }

  @override
  Future<MethodResult<Uint8List?>> encryptWithPublicKey({required  String message, String? publicKeyString}){
    return SecureEnclavePlatform.instance.encryptWithPublicKey(
        message: message,
        publicKeyString: publicKeyString);
  }

  @override
  Future<MethodResult<String?>> getPublicKey({ required AccessControl accessControl}) {
    return SecureEnclavePlatform.instance.getPublicKey(
      accessControl: accessControl
    );
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
