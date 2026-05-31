// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Person _$PersonFromJson(Map<String, dynamic> json) => Person(
  name: json['name'] as String?,
  age: (UrlParamsData.tryParse(json, 'age') as num?)?.toInt() ?? 0,
  status: json['status'] == null
      ? null
      : PersonStatus.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PersonToJson(Person instance) => <String, dynamic>{
  'name': instance.name,
  'age': instance.age,
  'status': instance.status,
};

PersonStatus _$PersonStatusFromJson(Map<String, dynamic> json) => PersonStatus(
  isActive: UrlParamsData.tryParse(json, 'isActive') as bool? ?? true,
  label: json['label'] as String?,
);

Map<String, dynamic> _$PersonStatusToJson(PersonStatus instance) =>
    <String, dynamic>{'isActive': instance.isActive, 'label': instance.label};
