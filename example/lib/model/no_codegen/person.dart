import 'package:go_router_url_params/go_router_url_params.dart';

enum PersonKeys { age, name, person, isActive, label }

class Person with UrlParamsData {
  const Person({this.name, this.age = 0, PersonStatus? status})
    : status = status ?? const PersonStatus();
  final String? name;
  final int age;
  final PersonStatus status;

  factory Person.fromMap(Map<String, dynamic> json) => Person(
    name: json['name'],
    age: int.tryParse(json['age']) ?? 0,
    status: json['status'] != null
        ? PersonStatus.fromMap(json['status'] as Map<String, dynamic>)
        : null,
  );

  @override
  Map<String, dynamic> toMap() => {
    'name': name,
    'age': age,
    'status': status.toMap(),
  };
}

class PersonStatus with UrlParamsData {
  const PersonStatus({this.isActive = true, this.label});
  final bool isActive;
  final String? label;

  factory PersonStatus.fromMap(Map<String, dynamic> json) => PersonStatus(
    isActive: bool.tryParse(json['isActive']) ?? true,
    label: json['label'] as String?,
  );

  @override
  Map<String, dynamic> toMap() => {'isActive': isActive, 'label': label};
}
