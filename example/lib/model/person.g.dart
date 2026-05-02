// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Person _$PersonFromJson(Map<String, dynamic> json) => _Person(
  name: json['name'] as String,
  age: (UrlParamsData.tryParse(json, 'age') as num?)?.toInt() ?? 0,
  status: readObjectFromString(json, 'status') == null
      ? null
      : PersonStatus.fromJson(
          readObjectFromString(json, 'status') as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$PersonToJson(_Person instance) => <String, dynamic>{
  'name': instance.name,
  'age': instance.age,
  'status': writeObjectToJson(instance.status),
};

_PersonStatus _$PersonStatusFromJson(Map<String, dynamic> json) =>
    _PersonStatus(
      isActive: UrlParamsData.tryParse(json, 'isActive') as bool? ?? true,
      label: json['label'] as String? ?? 'Active',
    );

Map<String, dynamic> _$PersonStatusToJson(_PersonStatus instance) =>
    <String, dynamic>{'isActive': instance.isActive, 'label': instance.label};
