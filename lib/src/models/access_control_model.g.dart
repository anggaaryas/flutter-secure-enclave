// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'access_control_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccessControlModel _$AccessControlModelFromJson(Map<String, dynamic> json) =>
    AccessControlModel(
      password: json['password'] as String?,
      tag: json['tag'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => $enumDecode(_$AccessControlOptionEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$AccessControlModelToJson(AccessControlModel instance) =>
    <String, dynamic>{
      'password': instance.password,
      'options':
          instance.options.map((e) => _$AccessControlOptionEnumMap[e]).toList(),
      'tag': instance.tag,
    };

const _$AccessControlOptionEnumMap = {
  AccessControlOption.devicePasscode: 'devicePasscode',
  AccessControlOption.biometryAny: 'biometryAny',
  AccessControlOption.biometryCurrentSet: 'biometryCurrentSet',
  AccessControlOption.userPresence: 'userPresence',
  AccessControlOption.watch: 'watch',
  AccessControlOption.privateKeyUsage: 'privateKeyUsage',
  AccessControlOption.applicationPassword: 'applicationPassword',
  AccessControlOption.or: 'or',
  AccessControlOption.and: 'and',
};
