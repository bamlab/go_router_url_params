import 'package:example/model/dart_mappable/person.dart';
import 'package:equatable/equatable.dart';

class Path with EquatableMixin {
  const Path(this.path, this.location, this.name);

  final String path;
  final String location;
  final String name;

  @override
  List<Object?> get props => [path, location, name];
}

Path get home => Path('/', '/', 'home');
Path counter(Person person) => Path(
  '/counter/${person.name}',
  '/counter/${person.name}'
      '?${PersonKeys.age.name}=${person.age}'
      '&${PersonKeys.isActive.name}=${person.status?.isActive}'
      '&${PersonKeys.label.name}=${person.status?.label}',
  'counter',
);
