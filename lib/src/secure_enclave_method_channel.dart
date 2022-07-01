import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:secure_enclave/src/model/method_result.dart';

import 'secure_enclave_platform_interface.dart';

/// An implementation of [SecureEnclavePlatform] that uses method channels.
class MethodChannelSecureEnclave extends SecureEnclavePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('secure_enclave');

  @override
  Future<MethodResult<String?>> decrypt(String tag, Uint8List message, bool isRequiresBiometric) async {
    final result = await methodChannel.invokeMethod<dynamic>('decrypt', {
      "tag": tag,
      "message": message,
       "isRequiresBiometric": isRequiresBiometric
    });
    return MethodResult.fromMap(
      map: Map<String, dynamic>.from(result),
      decoder: (rawData){
        return rawData as String?;
      }
    );
  }

  @override
  Future<MethodResult<Uint8List?>> encrypt(String tag, String message, bool isRequiresBiometric) async {
    final result = await methodChannel.invokeMethod<dynamic>('encrypt', {
      "tag": tag,
      "message": message,
      "isRequiresBiometric": isRequiresBiometric
    });
    return MethodResult.fromMap(
        map: Map<String, dynamic>.from(result),
        decoder: (rawData){
          return rawData as Uint8List?;
        }
    );
  }

  @override
  Future<MethodResult<String?>> getPublicKey(String tag, bool isRequiresBiometric) async {
    final result = await methodChannel.invokeMethod<dynamic>('getPublicKeyString', {
      "tag": tag,
      "isRequiresBiometric": isRequiresBiometric
    });

    return MethodResult.fromMap(
        map: Map<String, dynamic>.from(result),
        decoder: (rawData){
          return rawData as String?;
        }
    );
  }

  @override
  Future<MethodResult<bool>> removeKey(String tag) async {
    final result = await methodChannel.invokeMethod<dynamic>('removeKey', {
      "tag": tag,
    });

    return MethodResult.fromMap(
        map: Map<String, dynamic>.from(result),
        decoder: (rawData){
          return rawData as bool? ?? false;
        }
    );
  }

  @override
  Future<MethodResult> cobaError() async {
    final result = await methodChannel.invokeMethod<dynamic>('cobaError');

    return MethodResult.fromMap(
        map: Map<String, dynamic>.from(result),
        decoder: (rawData){
          return true;
        }
    );
  }
}
