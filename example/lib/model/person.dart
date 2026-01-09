import 'package:go_router_url_params/go_router_url_params.dart';

enum PersonKeys { age, name, person, isActive, label }

class Person extends UrlParamsData {
  Person({required this.name, this.age = 0, this.status});
  final String name;
  final int age;
  final PersonStatus? status;
}

class PersonStatus extends UrlParamsData {
  PersonStatus({this.isActive = true, this.label = 'Active'});
  final bool isActive;
  final String label;
}
