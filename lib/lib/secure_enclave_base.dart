import 'dart:typed_data';

import 'src/models/access_control_model.dart';
import 'src/models/result_model.dart';

abstract class SecureEnclaveBase {
  Future<ResultModel<bool>> createKey({
    required AccessControlModel accessControl,
  });

  Future<ResultModel<bool>> removeKey(String tag);

  Future<ResultModel<String?>> getPublicKey({
    required String tag,
    String? password,
  });

  Future<ResultModel<bool?>> getStatusSecKey({
    required String tag,
    String? password,
  });

  Future<ResultModel<Uint8List?>> encrypt({
    required String message,
    required String tag,
    String? password,
  });

  Future<ResultModel<String?>> decrypt({
    required Uint8List message,
    required String tag,
    String? password,
  });
}
