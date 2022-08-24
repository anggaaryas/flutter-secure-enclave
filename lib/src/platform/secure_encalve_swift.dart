import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../secure_enclave_base.dart';
import '../models/access_control_model.dart';
import '../models/result_model.dart';

class SecureEnclaveSwift extends SecureEnclaveBase {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('secure_enclave');

  @override
  Future<ResultModel<bool>> generateKeyPair(
      {required AccessControlModel accessControl}) async {
    final result = await methodChannel.invokeMethod<dynamic>(
      'generateKeyPair',
      {
        "accessControl": accessControl.toJson(),
      },
    );

    return ResultModel.fromMap(
      map: Map<String, dynamic>.from(result),
      decoder: (rawData) {
        return rawData as bool? ?? false;
      },
    );
  }

  @override
  Future<ResultModel<bool>> removeKey(String tag) async {
    final result = await methodChannel.invokeMethod<dynamic>(
      'removeKey',
      {
        "tag": tag,
      },
    );

    return ResultModel.fromMap(
      map: Map<String, dynamic>.from(result),
      decoder: (rawData) {
        return rawData as bool? ?? false;
      },
    );
  }

  @override
  Future<ResultModel<String?>> getPublicKey(
      {required String tag, String? password}) async {
    final result = await methodChannel.invokeMethod<dynamic>(
      'getPublicKey',
      {
        "tag": tag,
        "password": password ?? '',
      },
    );

    return ResultModel.fromMap(
      map: Map<String, dynamic>.from(result),
      decoder: (rawData) {
        return rawData as String?;
      },
    );
  }

  @override
  Future<ResultModel<Uint8List?>> encrypt(
      {required String message, required String tag, String? password}) async {
    final result = await methodChannel.invokeMethod<dynamic>(
      'encrypt',
      {
        "message": message,
        "tag": tag,
        "password": password ?? '',
      },
    );

    return ResultModel.fromMap(
      map: Map<String, dynamic>.from(result),
      decoder: (rawData) {
        return rawData as Uint8List?;
      },
    );
  }

  @override
  Future<ResultModel<String?>> decrypt(
      {required Uint8List message,
      required String tag,
      String? password}) async {
    final result = await methodChannel.invokeMethod<dynamic>(
      'decrypt',
      {
        "message": message,
        "tag": tag,
        "password": password ?? '',
      },
    );

    return ResultModel.fromMap(
      map: Map<String, dynamic>.from(result),
      decoder: (rawData) {
        return rawData as String?;
      },
    );
  }

  @override
  Future<ResultModel<bool?>> getStatusSecKey(
      {required String tag, String? password}) async {
    final result = await methodChannel.invokeMethod<dynamic>(
      'getStatusSecKey',
      {
        "tag": tag,
        "password": password ?? '',
      },
    );

    return ResultModel.fromMap(
      map: Map<String, dynamic>.from(result),
      decoder: (rawData) {
        return rawData as bool?;
      },
    );
  }
}
