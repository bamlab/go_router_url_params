import 'package:json_annotation/json_annotation.dart';
import 'package:go_router_url_params/go_router_url_params.dart';

part 'person.g.dart';

enum PersonKeys { age, name, person, isActive, label }

@JsonSerializable()
class Person extends UrlParamsData {
  const Person({this.name, this.age = 0, this.status});
  final String? name;
  @JsonKey(readValue: UrlParamsData.tryParse)
  final int age;
  final PersonStatus? status;

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PersonToJson(this);
}

@JsonSerializable()
class PersonStatus extends UrlParamsData {
  const PersonStatus({this.isActive = true, this.label});
  @JsonKey(readValue: UrlParamsData.tryParse)
  final bool isActive;
  final String? label;

  factory PersonStatus.fromJson(Map<String, dynamic> json) =>
      _$PersonStatusFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PersonStatusToJson(this);
}
