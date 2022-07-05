import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:secure_enclave/src/model/access_control.dart';
import 'package:secure_enclave/src/model/method_result.dart';

import 'secure_enclave_method_channel.dart';

abstract class SecureEnclavePlatform extends PlatformInterface implements SecureEnclaveBehaviour {
  /// Constructs a SecureEnclavePlatform.
  SecureEnclavePlatform() : super(token: _token);

  static final Object _token = Object();

  static SecureEnclavePlatform _instance = MethodChannelSecureEnclave();

  /// The default instance of [SecureEnclavePlatform] to use.
  ///
  /// Defaults to [MethodChannelSecureEnclave].
  static SecureEnclavePlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SecureEnclavePlatform] when
  /// they register themselves.
  static set instance(SecureEnclavePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
}


abstract class SecureEnclaveBehaviour {
  Future<MethodResult<Uint8List?>> encrypt({required  String message, required AccessControl accessControl});
  Future<MethodResult<Uint8List?>> encryptWithPublicKey({required  String message, required String? publicKeyString});
  Future<MethodResult<String?>> decrypt({required Uint8List message, required  AccessControl accessControl});
  Future<MethodResult<String?>> getPublicKey({required AccessControl accessControl});
  Future<MethodResult<bool>> removeKey(String tag);

  Future<MethodResult<dynamic>> cobaError();
}
