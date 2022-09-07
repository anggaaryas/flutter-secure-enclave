library secure_enclave;

import 'dart:typed_data';

import 'package:secure_enclave/secure_enclave_base.dart';
import 'package:secure_enclave/src/models/access_control_model.dart';
import 'package:secure_enclave/src/models/result_model.dart';

import 'src/platform/secure_encalve_swift.dart';

export 'src/constants/access_control_option.dart';
export 'src/models/access_control_model.dart';
export 'src/models/result_model.dart';
export 'src/models/error_model.dart';

class SecureEnclave implements SecureEnclaveBase {
  @override
  Future<ResultModel<String?>> decrypt(
      {required Uint8List message, required String tag, String? password}) {
    return SecureEnclavePlatform.instance.decrypt(
      message: message,
      tag: tag,
      password: password,
    );
  }

  @override
  Future<ResultModel<Uint8List?>> encrypt(
      {required String message, required String tag, String? password}) {
    return SecureEnclavePlatform.instance.encrypt(
      message: message,
      tag: tag,
      password: password,
    );
  }

  @override
  Future<ResultModel<Uint8List?>> encryptWithPublicKey(
      {required String message, required String publicKey}) {
    return SecureEnclavePlatform.instance.encryptWithPublicKey(
      message: message,
      publicKey: publicKey,
    );
  }

  @override
  Future<ResultModel<bool>> generateKeyPair(
      {required AccessControlModel accessControl}) {
    return SecureEnclavePlatform.instance
        .generateKeyPair(accessControl: accessControl);
  }

  @override
  Future<ResultModel<String?>> getPublicKey(
      {required String tag, String? password}) {
    return SecureEnclavePlatform.instance.getPublicKey(
      tag: tag,
      password: password,
    );
  }

  @override
  Future<ResultModel<bool>> removeKey(String tag) {
    return SecureEnclavePlatform.instance.removeKey(tag);
  }

  @override
  Future<ResultModel<String?>> sign(
      {required Uint8List message, required String tag, String? password}) {
    return SecureEnclavePlatform.instance.sign(
      message: message,
      tag: tag,
      password: password,
    );
  }

  @override
  Future<ResultModel<bool?>> verify(
      {required String plainText,
      required String signature,
      required String tag,
      String? password}) {
    return SecureEnclavePlatform.instance.verify(
      plainText: plainText,
      signature: signature,
      tag: tag,
      password: password,
    );
  }

  @override
  Future<ResultModel<bool?>> isKeyCreated(
      {required String tag, String? password}) {
    return SecureEnclavePlatform.instance.isKeyCreated(
      tag: tag,
      password: password,
    );
  }
}
