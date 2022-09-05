import 'error_model.dart';

class ResultModel<T> {
  final ErrorModel? error;
  final dynamic _rawData;
  final T Function(dynamic rawData) decoder;

  ResultModel(this.error, this._rawData, this.decoder);

  factory ResultModel.fromMap(
      {required Map<String, dynamic>? map,
      required T Function(dynamic rawData) decoder}) {
    return ResultModel(
        map?['error'] == null
            ? null
            : ErrorModel.fromMap(Map<String, dynamic>.from(map!['error'])),
        map?['data'],
        decoder);
  }

  T get value => decoder(_rawData);
}
