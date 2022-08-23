class ErrorModel {
  int code;
  String desc;

  ErrorModel(this.code, this.desc);

  factory ErrorModel.fromMap(Map<String, dynamic> map) {
    return ErrorModel(map["code"], map["desc"]);
  }
}
