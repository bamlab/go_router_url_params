import 'package:go_router_url_watcher/go_router_url_watcher.dart';

enum _PersonKeys { age, name, status }

enum _PersonStatusKeys { isActive, label }

class Person with UrlParamsData {
  const Person({this.name, this.age = 0, PersonStatus? status})
    : status = status ?? const PersonStatus();
  final String? name;
  final int age;
  final PersonStatus status;

  factory Person.fromMap(Map<String, dynamic> json) => Person(
    name: json[_PersonKeys.name.name],
    age: int.tryParse(json[_PersonKeys.age.name]) ?? 0,
    status: json[_PersonKeys.status.name] != null
        ? PersonStatus.fromMap(
            json[_PersonKeys.status.name] as Map<String, dynamic>,
          )
        : null,
  );

  @override
  Map<String, dynamic> toMap() => {
    _PersonKeys.name.name: name,
    _PersonKeys.age.name: age,
    _PersonKeys.status.name: status.toMap(),
  };

  Person copyWith({String? name, int? age, PersonStatus? status}) => Person(
    name: name ?? this.name,
    age: age ?? this.age,
    status: status ?? this.status,
  );
}

class PersonStatus with UrlParamsData {
  const PersonStatus({this.isActive = true, this.label});
  final bool isActive;
  final String? label;

  factory PersonStatus.fromMap(Map<String, dynamic> json) => PersonStatus(
    isActive: bool.tryParse(json[_PersonStatusKeys.isActive.name]) ?? true,
    label: json[_PersonStatusKeys.label.name] as String?,
  );

  @override
  Map<String, dynamic> toMap() => {
    _PersonStatusKeys.isActive.name: isActive,
    _PersonStatusKeys.label.name: label,
  };
}
