import 'dart:typed_data';

import 'src/models/access_control_model.dart';
import 'src/models/result_model.dart';

abstract class SecureEnclaveBase {
  Future<ResultModel<bool>> generateKeyPair({
    required AccessControlModel accessControl,
  });

  Future<ResultModel<bool>> removeKey(String tag);

  Future<ResultModel<String?>> getPublicKey({
    required String tag,
    String? password,
  });

  Future<ResultModel<bool?>> isKeyCreated({
    required String tag,
    String? password,
  });

  Future<ResultModel<Uint8List?>> encrypt({
    required String message,
    required String tag,
    String? password,
  });

  Future<ResultModel<Uint8List?>> encryptWithPublicKey({
    required String message,
    required String publicKey,
  });

  Future<ResultModel<String?>> decrypt({
    required Uint8List message,
    required String tag,
    String? password,
  });

  Future<ResultModel<String?>> sign({
    required Uint8List message,
    required String tag,
    String? password,
  });

  Future<ResultModel<bool?>> verify({
    required String plainText,
    required String signature,
    required String tag,
    String? password,
  });
}

//
