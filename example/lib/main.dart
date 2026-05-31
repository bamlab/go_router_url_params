import 'package:example/model/dart_mappable/person.dart';
import 'package:example/router/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router_url_params/go_router_url_params.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      builder: (context, child) => UrlParamsScope(
        router: router,
        builders: [
          UrlParamBuilder<Person>(PersonMapper.fromMap),
          UrlParamBuilder<PersonStatus>(
            PersonStatusMapper.fromMap,
            prefixKey: "status",
          ),
        ],
        child: child!,
      ),
    );
  }
}
