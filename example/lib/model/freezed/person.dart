import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router_url_params/go_router_url_params.dart';

part 'person.freezed.dart';
part 'person.g.dart';

enum PersonKeys { age, name, person, isActive, label }

@freezed
abstract class Person with _$Person, UrlParamsData {
  const Person._() : super();
  const factory Person({
    required String name,
    @JsonKey(readValue: UrlParamsData.tryParse) @Default(0) int age,
    @JsonKey(
      readValue: UrlParamsData.readObjectFromString,
      toJson: UrlParamsData.writeObjectToJson,
    )
    PersonStatus? status,
  }) = _Person;

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
  @override
  Map<String, dynamic> toMap() => toJson();
}

@freezed
abstract class PersonStatus with _$PersonStatus, UrlParamsData {
  const PersonStatus._() : super();
  const factory PersonStatus({
    @JsonKey(readValue: UrlParamsData.tryParse) @Default(true) bool isActive,
    @Default('Active') String label,
  }) = _PersonStatus;

  factory PersonStatus.fromJson(Map<String, dynamic> json) =>
      _$PersonStatusFromJson(json);
  @override
  Map<String, dynamic> toMap() => toJson();
}
