import 'package:example/main.dart';
import 'package:example/pages/tab_view_demo/flavor.dart';
import 'package:example/pages/tab_view_demo/tab_view_demo_page.dart';
import 'package:go_router/go_router.dart';
import 'package:example/pages/home_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => HomePage(),
      routes: [
        GoRoute(
          path: '/counter/:name',
          name: 'counter',
          builder: (context, state) => CounterPage(),
        ),
        GoRoute(
          path: '/tabViewDemo/:${Flavor.pathParamName}',
          name: 'tabViewDemo',
          builder: (context, state) => TabViewDemoPage(),
        ),
      ],
    ),
  ],
);
