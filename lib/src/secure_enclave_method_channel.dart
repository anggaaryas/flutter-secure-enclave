import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:secure_enclave/src/model/method_result.dart';

import 'model/access_control.dart';
import 'secure_enclave_platform_interface.dart';

/// An implementation of [SecureEnclavePlatform] that uses method channels.
class MethodChannelSecureEnclave extends SecureEnclavePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('secure_enclave');

  @override
  Future<MethodResult<bool>> createKey(
      {required AccessControl accessControl}) async {
    final result = await methodChannel.invokeMethod<dynamic>('createKey', {
      "accessControl": accessControl.toJson(),
    });

    return MethodResult.fromMap(
      map: Map<String, dynamic>.from(result),
      decoder: (rawData) {
        return rawData as bool? ?? false;
      },
    );
  }

  @override
  Future<MethodResult<bool>> removeKey(String tag) async {
    final result = await methodChannel.invokeMethod<dynamic>('removeKey', {
      "tag": tag,
    });

    return MethodResult.fromMap(
      map: Map<String, dynamic>.from(result),
      decoder: (rawData) {
        return rawData as bool? ?? false;
      },
    );
  }

  @override
  Future<MethodResult<String?>> getPublicKey(
      {required String tag, String? password}) async {
    final result = await methodChannel.invokeMethod<dynamic>(
      'getPublicKey',
      {
        "tag": tag,
        "password": password,
      },
    );

    return MethodResult.fromMap(
      map: Map<String, dynamic>.from(result),
      decoder: (rawData) {
        return rawData as String?;
      },
    );
  }

  @override
  Future<MethodResult<Uint8List?>> encrypt(
      {required String message, required String tag, String? password}) async {
    final result = await methodChannel.invokeMethod<dynamic>(
      'encrypt',
      {
        "message": message,
        "tag": tag,
        "password": password,
      },
    );

    return MethodResult.fromMap(
      map: Map<String, dynamic>.from(result),
      decoder: (rawData) {
        return rawData as Uint8List?;
      },
    );
  }

  @override
  Future<MethodResult<String?>> decrypt(
      {required Uint8List message,
      required String tag,
      String? password}) async {
    final result = await methodChannel.invokeMethod<dynamic>(
      'decrypt',
      {"message": message, "tag": tag, "password": password},
    );

    return MethodResult.fromMap(
      map: Map<String, dynamic>.from(result),
      decoder: (rawData) {
        return rawData as String?;
      },
    );
  }

  @override
  Future<MethodResult<bool?>> getStatusSecKey(
      {required String tag, String? password}) async {
    final result = await methodChannel.invokeMethod<dynamic>(
      'getStatusSecKey',
      {
        "tag": tag,
        "password": password,
      },
    );

    return MethodResult.fromMap(
      map: Map<String, dynamic>.from(result),
      decoder: (rawData) {
        return rawData as bool?;
      },
    );
  }
}
