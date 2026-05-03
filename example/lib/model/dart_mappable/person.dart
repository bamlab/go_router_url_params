import 'package:dart_mappable/dart_mappable.dart';
import 'package:go_router_url_params/go_router_url_params.dart';

part 'person.mapper.dart';

enum PersonKeys { age, name, person, isActive, label }

@MappableClass()
class Person extends UrlParamsData with PersonMappable {
  const Person({this.name, this.age = 0, this.status});
  final String? name;
  final int age;
  final PersonStatus? status;
}

@MappableClass()
class PersonStatus extends UrlParamsData with PersonStatusMappable {
  const PersonStatus({this.isActive = true, this.label});
  final bool isActive;
  final String? label;
}
