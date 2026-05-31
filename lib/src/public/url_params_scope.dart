import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_url_params/go_router_url_params.dart';
import 'package:go_router_url_params/src/url_params_model.dart';

/// Typed registration entry used by [UrlParamsScope.builders].
///
/// One [UrlParamBuilder] per concrete [UrlParamsData] subclass tells the
/// scope how to deserialize that type from the URL.
class UrlParamBuilder<T extends UrlParamsData> {
  const UrlParamBuilder(this.builder, {this.prefixKey});

  final UrlParamsDataBuilder<T> builder;

  /// By providing a [prefixKey], you can differentiate the URL params of different types,
  /// and avoid conflicts between them.
  /// If non null, the URL params will be prefixed with the given key.
  /// If null, the URL params will not be prefixed.
  ///
  /// Example:
  /// ```dart
  /// class Person with UrlParamsData {
  ///   final String name;
  ///   final int age;
  ///   [... constructor and fromMap ...]
  /// }
  /// class PersonStatus with UrlParamsData {
  ///   final bool isActive;
  ///   [... constructor and fromMap ...]
  /// }
  /// ```
  /// The following [UrlParamBuilder]s:
  /// ```dart
  /// [
  /// UrlParamBuilder<Person>(PersonMapper.fromMap),
  /// UrlParamBuilder<PersonStatus>(PersonStatusMapper.fromMap, prefixKey: "status"),
  /// ]
  /// ```
  /// Will generate the following URL params:
  /// ```dart
  /// "?age=25&name=John&status.isActive=true"
  /// ```
  final String? prefixKey;

  Type get type => T;
}

/// Caches parsed URL params and scopes rebuilds to consumers whose slice
/// of the URL actually changed.
///
/// Place once below `MaterialApp.router` via the `builder:` argument, pass
/// the same [GoRouter] instance you gave to `MaterialApp.router`, and
/// register one [UrlParamBuilder] per [UrlParamsData] subclass that any
/// widget will read with [UrlParamsUtils.watchUrlParams]:
///
/// ```dart
/// MaterialApp.router(
///   routerDelegate: router.routerDelegate,
///   routeInformationParser: router.routeInformationParser,
///   routeInformationProvider: router.routeInformationProvider,
///   builder: (context, child) => UrlParamsScope(
///     router: router,
///     builders: const [
///       UrlParamBuilder<Person>(Person.fromJson),
///       UrlParamBuilder<PersonStatus>(PersonStatus.fromJson),
///     ],
///     child: child ?? const SizedBox.shrink(),
///   ),
/// )
/// ```
///
/// The scope subscribes to [GoRouter.routeInformationProvider] and republishes
/// path/query parameters. Consumers using [UrlParamsUtils.watchUrlParams],
/// [UrlParamsUtils.watchQueryParamFromKey] or [UrlParamsUtils.watchPathParamFromKey]
/// only rebuild when the slice they read changed.
class UrlParamsScope extends StatefulWidget {
  const UrlParamsScope({
    super.key,
    required this.router,
    this.builders = const [],
    required this.child,
  });

  final GoRouter router;

  /// One entry per [UrlParamsData] subclass that widgets will read.
  /// Looked up by [Type] from [UrlParamsUtils.watchUrlParams].
  final List<UrlParamBuilder> builders;

  final Widget child;

  static Map<Type, String?> prefixKeysOf(BuildContext context) {
    return (context
                    .getElementForInheritedWidgetOfExactType<
                      _InheritedUrlParamsScope
                    >()
                    ?.widget
                as _InheritedUrlParamsScope?)
            ?.prefixKeys ??
        {};
  }

  @override
  State<UrlParamsScope> createState() => _UrlParamsScopeState();
}

class _UrlParamsScopeState extends State<UrlParamsScope> {
  Map<String, String> pathParams = const {};
  Map<String, List<String>> queryParams = const {};

  @override
  void initState() {
    super.initState();
    // Try to seed synchronously; this works once the routerDelegate has
    // matched the initial route.
    _readFromRouter();
    widget.router.routerDelegate.addListener(_syncFromRouter);
    // Safety net: if the initial route is matched after our first build
    // (the listener won't fire for the very first state), pull it via a
    // post-frame callback. No-op when initial state was already seeded.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncFromRouter();
    });
  }

  @override
  void didUpdateWidget(covariant UrlParamsScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.router != widget.router) {
      oldWidget.router.routerDelegate.removeListener(_syncFromRouter);
      widget.router.routerDelegate.addListener(_syncFromRouter);
      _readFromRouter();
    }
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_syncFromRouter);
    super.dispose();
  }

  /// Reads current router state into [pathParams]/[queryParams] without
  /// scheduling a rebuild. Safe to call before the first build.
  void _readFromRouter() {
    try {
      final config = widget.router.routerDelegate.currentConfiguration;
      pathParams = config.pathParameters;
      queryParams = config.uri.queryParametersAll;
    } catch (_) {
      // Route not yet matched.
    }
  }

  void _syncFromRouter() {
    try {
      if (mounted) setState(_readFromRouter);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedUrlParamsScope(
      prefixKeys: {for (final e in widget.builders) e.type: e.prefixKey},
      child: UrlParamsModel(
        pathParams: pathParams,
        queryParams: queryParams,
        builders: {for (final e in widget.builders) e.type: e.builder},
        prefixKeys: {for (final e in widget.builders) e.type: e.prefixKey},
        parseCache: <Type, UrlParamsData?>{},
        flatCache: <Type, Map<String, dynamic>?>{},
        child: widget.child,
      ),
    );
  }
}

class _InheritedUrlParamsScope extends InheritedWidget {
  const _InheritedUrlParamsScope({
    required super.child,
    required this.prefixKeys,
  });

  final Map<Type, String?> prefixKeys;

  @override
  bool updateShouldNotify(covariant _InheritedUrlParamsScope oldWidget) {
    return prefixKeys != oldWidget.prefixKeys;
  }
}
