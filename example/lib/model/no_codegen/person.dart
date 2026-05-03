import 'package:go_router_url_params/go_router_url_params.dart';

enum PersonKeys { age, name, person, isActive, label }

class Person extends UrlParamsData {
  const Person({this.name, this.age = 0, this.status});
  final String? name;
  final int age;
  final PersonStatus? status;

  factory Person.fromJson(Map<String, dynamic> json) => Person(
    name: json['name'],
    age: int.tryParse(json['age']) ?? 0,
    status: json['status'] != null
        ? PersonStatus.fromJson(json['status'] as Map<String, dynamic>)
        : null,
  );

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'status': status?.toJson(),
  };
}

class PersonStatus extends UrlParamsData {
  const PersonStatus({this.isActive = true, this.label});
  final bool isActive;
  final String? label;

  factory PersonStatus.fromJson(Map<String, dynamic> json) => PersonStatus(
    isActive: bool.tryParse(json['isActive']) ?? true,
    label: json['label'] as String?,
  );

  @override
  Map<String, dynamic> toJson() => {'isActive': isActive, 'label': label};
}
