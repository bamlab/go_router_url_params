import 'package:dart_mappable/dart_mappable.dart';
import 'package:go_router_url_watcher/go_router_url_watcher.dart';

part 'person.mapper.dart';

@MappableClass()
class Person with PersonMappable, UrlParamsData {
  const Person({this.name, this.age = 0, PersonStatus? status})
    : status = status ?? const PersonStatus();
  final String? name;
  final int age;
  final PersonStatus status;
}

@MappableClass()
class PersonStatus with PersonStatusMappable, UrlParamsData {
  const PersonStatus({this.isActive = true, this.labels = const []});
  final bool isActive;
  final List<String> labels;
}
