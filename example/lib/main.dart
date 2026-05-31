import 'package:example/router/router.dart';
import 'package:flutter/material.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:go_router_url_params/go_router_url_params.dart';

part 'main.mapper.dart';

void main() {
  runApp(const MyApp());
}

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

class StatusSwitch extends StatelessWidget {
  const StatusSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    // This widget will only rebuild when a parameter of type PersonStatus changes
    // (isActive or labels, for example).
    // It will not rebuild when an other parameter of type Person changes
    // (the name or the age, for example).
    final status = context.watchUrlParams<PersonStatus>() ?? PersonStatus();

    return Switch(
      value: status.isActive,
      onChanged: (value) {
        context.setUrlParams(status.copyWith(isActive: value));
      },
    );
  }
}
