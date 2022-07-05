import 'package:secure_enclave/src/model/base_data_result.dart';
import 'package:secure_enclave/src/model/error_handling.dart';

class MethodResult<T>{
  final ErrorHandling? error;
  final dynamic _rawData;
  final T Function(dynamic rawData) decoder;

  MethodResult(this.error, this._rawData, this.decoder);

  factory MethodResult.fromMap({required Map<String, dynamic>? map, required T Function(dynamic rawData) decoder}){
    return MethodResult(map?['error'] == null? null: ErrorHandling.fromMap(Map<String, dynamic>.from(map!['error'])), map?['data'], decoder);
  }

  T get value => decoder(_rawData);
}