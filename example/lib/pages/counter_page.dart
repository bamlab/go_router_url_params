import 'package:flutter/material.dart';
import 'package:go_router_url_params/go_router_url_params.dart';

// The CounterPage widget is in the main.dart file to demonstrate the use of watchUrlParams
// and setUrlParams directly on pub.dev

class NobodyFoundInUrl extends StatelessWidget {
  const NobodyFoundInUrl({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: SelectableText(
          context.uri.toString(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      body: const Center(child: Text('Nobody found')),
    );
  }
}
