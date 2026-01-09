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
    @Default(0) int age,
    PersonStatus? status,
  }) = _Person;

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
}

@freezed
abstract class PersonStatus extends UrlParamsData with _$PersonStatus {
  const PersonStatus._() : super();
  const factory PersonStatus({
    @Default(true) bool isActive,
    @Default('Active') String label,
  }) = _PersonStatus;

  factory PersonStatus.fromJson(Map<String, dynamic> json) =>
      _$PersonStatusFromJson(json);
}
