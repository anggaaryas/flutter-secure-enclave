class ErrorHandling{
  int code;
  String desc;

  ErrorHandling(this.code, this.desc);

  factory ErrorHandling.fromMap(Map<String, dynamic> map){
    return ErrorHandling(map["code"], map["desc"]);
  }
}