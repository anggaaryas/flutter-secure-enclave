import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'secure_enclave_platform_interface.dart';

/// An implementation of [SecureEnclavePlatform] that uses method channels.
class MethodChannelSecureEnclave extends SecureEnclavePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('secure_enclave');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> decrypt(String tag, Uint8List message, bool isRequiresBiometric) async {
    final decrypted = await methodChannel.invokeMethod<String>('decrypt', {
      "tag": tag,
      "message": message,
       "isRequiresBiometric": isRequiresBiometric
    });
    return decrypted;
  }

  @override
  Future<Uint8List?> encrypt(String tag, String message, bool isRequiresBiometric) async {
    final encrypted = await methodChannel.invokeMethod<Uint8List?>('encrypt', {
      "tag": tag,
      "message": message,
      "isRequiresBiometric": isRequiresBiometric
    });
    return encrypted;
  }

  @override
  Future<String?> getPublicKey(String tag, bool isRequiresBiometric) async {
    final key = await methodChannel.invokeMethod<String>('getPublicKeyString', {
      "tag": tag,
      "isRequiresBiometric": isRequiresBiometric
    });
    return key;
  }
}
