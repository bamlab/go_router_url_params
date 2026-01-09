import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router_url_params/go_router_url_params.dart';

part 'person.freezed.dart';
part 'person.g.dart';

enum PersonKeys { age, name, person, isActive, label }

@freezed
abstract class Person extends UrlParamsData with _$Person {
  const Person._() : super();
  const factory Person({
    required String name,
    @JsonKey(fromJson: _parseAgeFromString) @Default(0) int age,
    @JsonKey(readValue: _readStatusFromString, toJson: _writeStatusToJson)
    PersonStatus? status,
  }) = _Person;

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
}

@freezed
abstract class PersonStatus extends UrlParamsData with _$PersonStatus {
  const PersonStatus._() : super();
  const factory PersonStatus({
    @JsonKey(fromJson: _parseIsActiveFromString) @Default(true) bool isActive,
    @Default('Active') String label,
  }) = _PersonStatus;

  factory PersonStatus.fromJson(Map<String, dynamic> json) =>
      _$PersonStatusFromJson(json);
}

int _parseAgeFromString(String value) => int.tryParse(value) ?? 0;

bool _parseIsActiveFromString(String value) => bool.tryParse(value) ?? true;

Map<String, dynamic>? _readStatusFromString(
  Map<dynamic, dynamic> json,
  String key,
) => json as Map<String, dynamic>;

Map<String, dynamic> _writeStatusToJson(PersonStatus? status) =>
    status?.toJson() ?? {};
