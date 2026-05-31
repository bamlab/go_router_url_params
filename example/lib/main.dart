import 'package:example/pages/counter_page.dart';
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

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final person = context.watchUrlParams<Person>();
    if (person == null) return NobodyFoundInUrl();

    final greeting = person.status.isActive ? 'Hello' : 'Goodbye';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.uri.toString(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text('$greeting, ${person.name}!'),
            SizedBox(height: 8),
            const Text('You have pushed the button this many times:'),
            Text(
              person.age.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.setUrlParams(person.copyWith(age: person.age + 1));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
