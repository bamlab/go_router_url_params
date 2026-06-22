import 'package:example/main.dart';
import 'package:example/pages/tab_view_demo/flavor.dart';

String get home => '/';

String counter(Person person, {Uri? currentUri}) =>
    '/counter/${person.name}${person.toQueryParamsString(keysToIgnore: ["name"], currentUri: currentUri)}';

String tabViewDemo(Flavor flavor) => '/tabViewDemo/${flavor.name}';
