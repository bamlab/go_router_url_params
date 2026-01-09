import 'package:example/model/person.dart';
import 'package:example/router/paths.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_url_params/go_router_url_params.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController nameController = TextEditingController(
    text: "Rico",
  );
  @override
  Widget build(BuildContext context) {
    final status = context.watchUrlParams(PersonStatus.fromMap);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          GoRouter.of(context).state.uri.toString(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: .min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'Your Name'),
                      controller: nameController,
                    ),
                  ),
                  SizedBox(width: 8),
                  StatusSwitch(),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(
                  counter(
                    Person(name: nameController.text, status: status),
                  ).location,
                ),
                child: const Text('Go to Counter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusSwitch extends StatelessWidget {
  const StatusSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.watchUrlParams(PersonStatus.fromMap);
    if (status == null) return const SizedBox.shrink();

    return Switch(
      value: status.isActive,
      onChanged: (value) {
        context.setUrlParams(status.copyWith(isActive: value));
      },
    );
  }
}
