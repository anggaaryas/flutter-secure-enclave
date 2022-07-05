import 'package:json_annotation/json_annotation.dart';

part 'access_control.g.dart';

@JsonSerializable()
class AccessControl{
  final List<AccessControlOption> options;
  final String tag;

  AccessControl({ required this.options, required this.tag});

  factory AccessControl.fromJson(Map<String, dynamic> json) => _$AccessControlFromJson(json);

  Map<String, dynamic> toJson() => _$AccessControlToJson(this);
}

enum AccessControlOption {

  @JsonValue("devicePasscode")
  devicePasscode,

  @JsonValue("biometryAny")
  biometryAny,

  @JsonValue("biometryCurrentSet")
  biometryCurrentSet,

  @JsonValue("userPresence")
  userPresence,

  @JsonValue("watch")
  watch,

  @JsonValue("privateKeyUsage")
  privateKeyUsage,
}