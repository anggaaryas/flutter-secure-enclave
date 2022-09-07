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
  /// decryption with secure enclave key pair
  @override
  Future<ResultModel<String?>> decrypt(
      {required Uint8List message, required String tag, String? password}) {
    return SecureEnclavePlatform.instance.decrypt(
      message: message,
      tag: tag,
      password: password,
    );
  }

  /// encryption with secure enclave key pair
  @override
  Future<ResultModel<Uint8List?>> encrypt(
      {required String message, required String tag, String? password}) {
    return SecureEnclavePlatform.instance.encrypt(
      message: message,
      tag: tag,
      password: password,
    );
  }

  /// encryption with external public key
  @override
  Future<ResultModel<Uint8List?>> encryptWithPublicKey(
      {required String message, required String publicKey}) {
    return SecureEnclavePlatform.instance.encryptWithPublicKey(
      message: message,
      publicKey: publicKey,
    );
  }

  /// Generetes a new private/public key pair
  @override
  Future<ResultModel<bool>> generateKeyPair(
      {required AccessControlModel accessControl}) {
    return SecureEnclavePlatform.instance
        .generateKeyPair(accessControl: accessControl);
  }

  /// get public key representation, this method will return Base64 encode
  /// you can share this public key to others device for sending encrypted data
  /// to your device
  @override
  Future<ResultModel<String?>> getPublicKey(
      {required String tag, String? password}) {
    return SecureEnclavePlatform.instance.getPublicKey(
      tag: tag,
      password: password,
    );
  }

  /// remove key pair
  @override
  Future<ResultModel<bool>> removeKey(String tag) {
    return SecureEnclavePlatform.instance.removeKey(tag);
  }

  /// generate signature from data
  @override
  Future<ResultModel<String?>> sign(
      {required Uint8List message, required String tag, String? password}) {
    return SecureEnclavePlatform.instance.sign(
      message: message,
      tag: tag,
      password: password,
    );
  }

  /// verify signature
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

  /// check status is tag available or not
  @override
  Future<ResultModel<bool?>> isKeyCreated(
      {required String tag, String? password}) {
    return SecureEnclavePlatform.instance.isKeyCreated(
      tag: tag,
      password: password,
    );
  }
}
