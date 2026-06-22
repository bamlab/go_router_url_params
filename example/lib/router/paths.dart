import 'package:example/main.dart';
import 'package:equatable/equatable.dart';
import 'package:example/pages/tab_view_demo/flavor.dart';

class Path with EquatableMixin {
  const Path(this.path, this.location, this.name);

  final String path;
  final String location;
  final String name;

  @override
  List<Object?> get props => [path, location, name];
}

Path get home => Path('/', '/', 'home');
Path counter(Person person, {Uri? currentUri}) => Path(
  '/counter/:name',
  '/counter/${person.name}${person.toQueryParamsString(keysToIgnore: ["name"], currentUri: currentUri)}',
  'counter',
);

Path tabViewDemo(Flavor flavor) => Path(
  '/tabViewDemo/:${Flavor.urlParamName}',
  '/tabViewDemo/${flavor.name}',
  'tabViewDemo',
);
