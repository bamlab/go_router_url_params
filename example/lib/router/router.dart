import 'package:example/main.dart';
import 'package:example/pages/tab_view_demo/flavor.dart';
import 'package:example/pages/tab_view_demo/tab_view_demo_page.dart';
import 'package:example/router/paths.dart';
import 'package:go_router/go_router.dart';
import 'package:example/pages/home_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: home.path,
      name: home.name,
      builder: (context, state) => HomePage(),
      routes: [
        GoRoute(
          path: counter(Person(name: ':name')).path,
          name: counter(Person(name: ':name')).name,
          builder: (context, state) => CounterPage(),
        ),
        GoRoute(
          path: '/tabViewDemo/:${Flavor.pathParamName}',
          name: tabViewDemo(Flavor.defaultFlavor).name,
          builder: (context, state) => TabViewDemoPage(),
        ),
      ],
    ),
  ],
);
