import 'package:example/model/person.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_url_params/go_router_url_params.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final person = context.watchUrlParams(Person.fromJson);
    if (person == null) return NoOne();

    final status = person.status ?? PersonStatus();
    final greeting = status.isActive ? 'Hello' : 'Goodbye';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: SelectableText(
          GoRouter.of(context).state.uri.toString(),
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

class NoOne extends StatelessWidget {
  const NoOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: SelectableText(
          GoRouter.of(context).state.uri.toString(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      body: const Center(child: Text('No one found')),
    );
  }
}
