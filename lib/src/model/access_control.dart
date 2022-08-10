import 'package:json_annotation/json_annotation.dart';
import 'package:secure_enclave/secure_enclave.dart';

part 'access_control.g.dart';

@JsonSerializable()
class AccessControl{
  final List<AccessControlOption> options;
  final String tag;

  AccessControl._({ required this.options, required this.tag});

  factory AccessControl({ required List<AccessControlOption> options, required String tag}){
    if(!options.contains(AccessControlOption.privateKeyUsage)){
      options.add(AccessControlOption.privateKeyUsage);
    }
    return AccessControl._(options: options, tag: tag);
  }

  factory AccessControl.fromJson(Map<String, dynamic> json) => _$AccessControlFromJson(json);

  Map<String, dynamic> toJson() => _$AccessControlToJson(this);
}

@JsonSerializable()
class AppPasswordAccessControl extends AccessControl{
  final String password;

  AppPasswordAccessControl._({required this.password, required String tag, required List<AccessControlOption> options}): super._(options: options, tag: tag);

  factory AppPasswordAccessControl({required String password, required String tag, required List<AccessControlOption> options}){
    List<AccessControlOption> temp = List.from(options);
    
    if(!temp.contains(AccessControlOption.applicationPassword)){
      temp.add(AccessControlOption.applicationPassword);
    }
    if(!temp.contains(AccessControlOption.privateKeyUsage)){
      temp.add(AccessControlOption.privateKeyUsage);
    }
    print(temp);
    return AppPasswordAccessControl._(password: password, tag: tag, options: temp);
  }

  factory AppPasswordAccessControl.fromJson(Map<String, dynamic> json) => _$AppPasswordAccessControlFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AppPasswordAccessControlToJson(this);
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

  @JsonValue("applicationPassword")
  applicationPassword,
}