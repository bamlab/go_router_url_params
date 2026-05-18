import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_url_params/go_router_url_params.dart';

// =====================================================================
// Test models with instrumentation counters
// =====================================================================

int personParseCount = 0;
int personToJsonCount = 0;
int personStatusParseCount = 0;
int personStatusToJsonCount = 0;

void resetCounters() {
  personParseCount = 0;
  personToJsonCount = 0;
  personStatusParseCount = 0;
  personStatusToJsonCount = 0;
}

class Person with UrlParamsData {
  Person({required this.name, this.age = 0});

  final String name;
  final int age;

  @override
  Map<String, dynamic> toMap() {
    personToJsonCount++;
    return {'name': name, 'age': age};
  }

  static Person? fromMap(Map<String, dynamic> p) {
    personParseCount++;
    final name = p['name'];
    if (name == null) return null;
    return Person(name: name, age: int.tryParse(p['age'] ?? '') ?? 0);
  }
}

class PersonStatus with UrlParamsData {
  PersonStatus({this.isActive = true, this.label = 'Active'});

  final bool isActive;
  final String label;

  @override
  Map<String, dynamic> toMap() {
    personStatusToJsonCount++;
    return {'isActive': isActive, 'label': label};
  }

  static PersonStatus? fromMap(Map<String, dynamic> p) {
    personStatusParseCount++;
    return PersonStatus(
      isActive: bool.tryParse(p['isActive'] ?? '') ?? true,
      label: p['label'] ?? 'Active',
    );
  }
}

class Throws with UrlParamsData {
  @override
  Map<String, dynamic> toMap() => const {};

  static Throws? fromMap(Map<String, dynamic> p) {
    throw StateError('boom');
  }
}

// =====================================================================
// Probe: counts how many times a given test widget builds
// =====================================================================

class Probe extends StatefulWidget {
  const Probe({required this.id, required this.builder, super.key});

  final String id;
  final Widget Function(BuildContext) builder;

  @override
  State<Probe> createState() => ProbeState();
}

class ProbeState extends State<Probe> {
  static final Map<String, int> builds = {};

  @override
  Widget build(BuildContext context) {
    builds[widget.id] = (builds[widget.id] ?? 0) + 1;
    return widget.builder(context);
  }
}

// =====================================================================
// Test harness
// =====================================================================

Future<GoRouter> pumpApp(
  WidgetTester tester, {
  required Widget child,
  List<UrlParamBuilder> builders = const [],
  String initialLocation = '/',
  List<RouteBase> extraRoutes = const [],
}) async {
  late final GoRouter router;
  router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) => child,
        routes: [
          GoRoute(path: '/', builder: (_, _) => child),
          ...extraRoutes,
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    MaterialApp.router(
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      builder: (context, child) =>
          UrlParamsScope(router: router, builders: builders, child: child!),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

// =====================================================================
// Tests
// =====================================================================

void main() {
  setUp(() {
    resetCounters();
    ProbeState.builds.clear();
  });

  group('watchUrlParams - reading', () {
    testWidgets('returns parsed value when params match', (tester) async {
      Person? read;
      await pumpApp(
        tester,
        builders: [UrlParamBuilder<Person>(Person.fromMap)],
        initialLocation: '/?name=Alice&age=30',
        child: Builder(
          builder: (context) {
            read = context.watchUrlParams<Person>();
            return const SizedBox.shrink();
          },
        ),
      );
      expect(read, isNotNull);
      expect(read?.name, 'Alice');
      expect(read?.age, 30);
    });

    testWidgets('returns null when builder returns null', (tester) async {
      Person? read;
      await pumpApp(
        tester,
        builders: [UrlParamBuilder<Person>(Person.fromMap)],
        // No `name` → Person.fromMap returns null.
        initialLocation: '/?age=30',
        child: Builder(
          builder: (context) {
            read = context.watchUrlParams<Person>();
            return const SizedBox.shrink();
          },
        ),
      );
      expect(read, isNull);
    });

    testWidgets('returns null without crashing when builder throws', (
      tester,
    ) async {
      Throws? read;
      await pumpApp(
        tester,
        builders: [UrlParamBuilder<Throws>(Throws.fromMap)],
        child: Builder(
          builder: (context) {
            read = context.watchUrlParams<Throws>();
            return const SizedBox.shrink();
          },
        ),
      );
      expect(read, isNull);
    });
  });

  group('watchUrlParams - rebuild consumers', () {
    testWidgets('rebuilds when its slice changes', (tester) async {
      final router = await pumpApp(
        tester,
        builders: [UrlParamBuilder<Person>(Person.fromMap)],
        initialLocation: '/?name=Alice&age=30',
        child: Probe(
          id: 'p',
          builder: (context) {
            final p = context.watchUrlParams<Person>();
            return Text(
              '${p?.name}/${p?.age}',
              textDirection: TextDirection.ltr,
            );
          },
        ),
      );
      // Baseline taken after the scope has fully settled (its initial
      // route sync may have triggered a rebuild already).
      final initial = ProbeState.builds['p']!;

      router.go('/?name=Alice&age=31');
      await tester.pumpAndSettle();
      expect(ProbeState.builds['p'], initial + 1);
    });

    testWidgets('does NOT rebuild when an unrelated query key changes', (
      tester,
    ) async {
      final router = await pumpApp(
        tester,
        builders: [UrlParamBuilder<Person>(Person.fromMap)],
        initialLocation: '/?name=Alice&age=30',
        child: Probe(
          id: 'p',
          builder: (context) {
            final p = context.watchUrlParams<Person>();
            return Text(
              '${p?.name}/${p?.age}',
              textDirection: TextDirection.ltr,
            );
          },
        ),
      );
      final initial = ProbeState.builds['p']!;

      // `theme` is not part of Person; the parsed Person is unchanged.
      router.go('/?name=Alice&age=30&theme=dark');
      await tester.pumpAndSettle();
      expect(ProbeState.builds['p'], initial);
    });

    testWidgets('isolates rebuilds across consumers of different types', (
      tester,
    ) async {
      final router = await pumpApp(
        tester,
        builders: [
          UrlParamBuilder<Person>(Person.fromMap),
          UrlParamBuilder<PersonStatus>(PersonStatus.fromMap),
        ],
        initialLocation: '/?name=Alice&isActive=false',
        child: Column(
          children: [
            Probe(
              id: 'person',
              builder: (c) {
                c.watchUrlParams<Person>();
                return const SizedBox.shrink();
              },
            ),
            Probe(
              id: 'status',
              builder: (c) {
                c.watchUrlParams<PersonStatus>();
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      );
      final personInitial = ProbeState.builds['person']!;
      final statusInitial = ProbeState.builds['status']!;

      // Change only the Person slice.
      router.go('/?name=Bob&isActive=false');
      await tester.pumpAndSettle();
      expect(ProbeState.builds['person'], personInitial + 1);
      expect(ProbeState.builds['status'], statusInitial);

      // Change only the PersonStatus slice.
      router.go('/?name=Bob&isActive=true');
      await tester.pumpAndSettle();
      expect(ProbeState.builds['person'], personInitial + 1);
      expect(ProbeState.builds['status'], statusInitial + 1);
    });
  });

  group('watchUrlParams - caching', () {
    testWidgets('parse runs once across N consumers per URL change', (
      tester,
    ) async {
      final router = await pumpApp(
        tester,
        builders: [UrlParamBuilder<Person>(Person.fromMap)],
        initialLocation: '/?name=Alice&age=30',
        child: Column(
          children: List.generate(
            4,
            (i) => Probe(
              id: 'p$i',
              builder: (c) {
                c.watchUrlParams<Person>();
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      // Reset after the initial mount has settled to isolate the cost
      // of a single URL change.
      personParseCount = 0;
      final initial0 = ProbeState.builds['p1']!;
      final initial1 = ProbeState.builds['p1']!;
      final initial2 = ProbeState.builds['p1']!;
      final initial3 = ProbeState.builds['p1']!;

      router.go('/?name=Bob&age=30');
      await tester.pumpAndSettle();
      // Four consumers but only one parse for the new model.
      expect(ProbeState.builds['p0'], initial0 + 1);
      expect(ProbeState.builds['p1'], initial1 + 1);
      expect(ProbeState.builds['p2'], initial2 + 1);
      expect(ProbeState.builds['p3'], initial3 + 1);
      expect(personParseCount, 1);
    });

    testWidgets(
      'toJson runs at most once per type per URL change despite N consumers',
      (tester) async {
        final router = await pumpApp(
          tester,
          builders: [UrlParamBuilder<Person>(Person.fromMap)],
          initialLocation: '/?name=Alice&age=30',
          child: Column(
            children: List.generate(
              4,
              (i) => Probe(
                id: 'p$i',
                builder: (c) {
                  c.watchUrlParams<Person>();
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
        // Initial frame populates cache + flat cache (1 toJson).
        expect(personToJsonCount, 1);

        personToJsonCount = 0;
        final initial0 = ProbeState.builds['p0']!;
        final initial1 = ProbeState.builds['p1']!;
        final initial2 = ProbeState.builds['p2']!;
        final initial3 = ProbeState.builds['p3']!;

        // URL change → dispatch fires for each of the 4 dependents.
        // The new model parses once and runs toJson once; the old model
        // hits the cache populated last frame (no toJson).
        router.go('/?name=Bob&age=31');
        await tester.pumpAndSettle();
        expect(ProbeState.builds['p0'], initial0 + 1);
        expect(ProbeState.builds['p1'], initial1 + 1);
        expect(ProbeState.builds['p2'], initial2 + 1);
        expect(ProbeState.builds['p3'], initial3 + 1);
        expect(personToJsonCount, 1);
      },
    );

    testWidgets(
      'irrelevant URL change does NOT trigger any toJson on old or new',
      (tester) async {
        final router = await pumpApp(
          tester,
          builders: [UrlParamBuilder<Person>(Person.fromMap)],
          initialLocation: '/?name=Alice&age=30',
          child: Probe(
            id: 'p',
            builder: (c) {
              c.watchUrlParams<Person>();
              return const SizedBox.shrink();
            },
          ),
        );
        // Initial frame: 1 toJson during the build's parse.
        expect(personToJsonCount, 1);

        personToJsonCount = 0;
        personParseCount = 0;

        router.go('/?name=Alice&age=30&theme=dark');
        await tester.pumpAndSettle();

        // The new model still parses once (during dispatch's _flatFor on
        // the new model), but since the dependent does not rebuild, no
        // additional parse is triggered by a consumer.
        expect(personParseCount, 1);
        // toJson runs once on the new model (to fill flat cache); old
        // model is a cache hit.
        expect(personToJsonCount, 1);
      },
    );
  });

  group('watchQueryParamFromKey', () {
    testWidgets('reads typed values', (tester) async {
      String? readName;
      int? readAge;
      bool? readActive;
      double? readScore;
      await pumpApp(
        tester,
        initialLocation: '/?name=Alice&age=30&active=true&score=4.2',
        child: Builder(
          builder: (context) {
            readName = context.watchQueryParamFromKey<String>('name');
            readAge = context.watchQueryParamFromKey<int>('age');
            readActive = context.watchQueryParamFromKey<bool>('active');
            readScore = context.watchQueryParamFromKey<double>('score');
            return const SizedBox.shrink();
          },
        ),
      );
      expect(readName, 'Alice');
      expect(readAge, 30);
      expect(readActive, true);
      expect(readScore, 4.2);
    });

    testWidgets('only rebuilds when its own key changes', (tester) async {
      final router = await pumpApp(
        tester,
        initialLocation: '/?a=1&b=2',
        child: Column(
          children: [
            Probe(
              id: 'a',
              builder: (c) {
                c.watchQueryParamFromKey<String>('a');
                return const SizedBox.shrink();
              },
            ),
            Probe(
              id: 'b',
              builder: (c) {
                c.watchQueryParamFromKey<String>('b');
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      );
      final aInitial = ProbeState.builds['a']!;
      final bInitial = ProbeState.builds['b']!;

      router.go('/?a=11&b=2');
      await tester.pumpAndSettle();
      expect(ProbeState.builds['a'], aInitial + 1);
      expect(ProbeState.builds['b'], bInitial);

      router.go('/?a=11&b=22');
      await tester.pumpAndSettle();
      expect(ProbeState.builds['a'], aInitial + 1);
      expect(ProbeState.builds['b'], bInitial + 1);
    });

    testWidgets('returns null when key is absent', (tester) async {
      String? read;
      await pumpApp(
        tester,
        initialLocation: '/',
        child: Builder(
          builder: (context) {
            read = context.watchQueryParamFromKey<String>('missing');
            return const SizedBox.shrink();
          },
        ),
      );
      expect(read, isNull);
    });
  });

  group('watchPathParamFromKey', () {
    testWidgets('reads typed value from a path parameter', (tester) async {
      int? readId;
      await pumpApp(
        tester,
        initialLocation: '/users/42',
        extraRoutes: [
          GoRoute(
            path: '/users/:id',
            builder: (_, _) => Builder(
              builder: (context) {
                readId = context.watchPathParamFromKey<int>('id');
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
        child: const SizedBox.shrink(),
      );
      expect(readId, 42);
    });
  });

  group('setUrlParams', () {
    testWidgets('updates the URL via toJson and triggers consumer rebuild', (
      tester,
    ) async {
      Person? observed;
      final router = await pumpApp(
        tester,
        builders: [UrlParamBuilder<Person>(Person.fromMap)],
        initialLocation: '/?name=Alice&age=30',
        child: Probe(
          id: 'probe',
          builder: (context) {
            observed = context.watchUrlParams<Person>();
            return MaterialButton(
              onPressed: () {
                context.setUrlParams(Person(name: 'Bob', age: 5));
              },
              child: Text('Set URL Params'),
            );
          },
        ),
      );
      final initial = ProbeState.builds['probe']!;
      expect(observed?.name, 'Alice');
      await tester.tap(find.text('Set URL Params'));
      await tester.pumpAndSettle();

      expect(ProbeState.builds['probe'], initial + 1);
      expect(observed?.name, 'Bob');
      expect(observed?.age, 5);
      expect(router.state.uri.queryParameters['name'], 'Bob');
      expect(router.state.uri.queryParameters['age'], '5');
    });
  });

  group('edge cases', () {
    testWidgets('first frame: scope handles empty params without crashing', (
      tester,
    ) async {
      // No initialLocation params at all.
      Person? read;
      await pumpApp(
        tester,
        builders: [UrlParamBuilder<Person>(Person.fromMap)],
        initialLocation: '/',
        child: Builder(
          builder: (context) {
            read = context.watchUrlParams<Person>();
            return const SizedBox.shrink();
          },
        ),
      );
      // No `name` in URL → Person.fromMap returns null.
      expect(read, isNull);
    });

    testWidgets('missing scope triggers an assertion in debug', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              context.watchUrlParams<Person>();
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(tester.takeException(), isA<AssertionError>());
    });

    testWidgets('cache is reset across URL changes (no stale results)', (
      tester,
    ) async {
      Person? observed;
      final router = await pumpApp(
        tester,
        builders: [UrlParamBuilder<Person>(Person.fromMap)],
        initialLocation: '/?name=Alice&age=1',
        child: Builder(
          builder: (context) {
            observed = context.watchUrlParams<Person>();
            return const SizedBox.shrink();
          },
        ),
      );
      expect(observed?.age, 1);

      router.go('/?name=Alice&age=2');
      await tester.pumpAndSettle();
      expect(observed?.age, 2);

      router.go('/?name=Alice&age=3');
      await tester.pumpAndSettle();
      expect(observed?.age, 3);
    });

    testWidgets('caching still works whe builder is not a tear off', (
      tester,
    ) async {
      Person? observed;
      final router = await pumpApp(
        tester,
        builders: [UrlParamBuilder<Person>((p) => Person.fromMap(p))],
        initialLocation: '/?name=Alice&age=30',
        child: Column(
          children: List.generate(
            4,
            (i) => Probe(
              id: 'probe$i',
              builder: (context) {
                observed = context.watchUrlParams<Person>();
                return MaterialButton(
                  onPressed: () {
                    context.setUrlParams(Person(name: 'Bob', age: 5));
                  },
                  child: Text('Set URL Params $i'),
                );
              },
            ),
          ),
        ),
      );
      personParseCount = 0;
      final initial0 = ProbeState.builds['probe0']!;
      final initial1 = ProbeState.builds['probe1']!;
      final initial2 = ProbeState.builds['probe2']!;
      final initial3 = ProbeState.builds['probe3']!;
      expect(observed?.name, 'Alice');
      await tester.tap(find.text('Set URL Params 0'));
      await tester.pumpAndSettle();

      expect(ProbeState.builds['probe0'], initial0 + 1);
      expect(ProbeState.builds['probe1'], initial1 + 1);
      expect(ProbeState.builds['probe2'], initial2 + 1);
      expect(ProbeState.builds['probe3'], initial3 + 1);
      expect(personParseCount, 1);
      expect(observed?.name, 'Bob');
      expect(observed?.age, 5);
      expect(router.state.uri.queryParameters['name'], 'Bob');
      expect(router.state.uri.queryParameters['age'], '5');
    });
  });
}
