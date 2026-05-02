export 'model/url_params_data.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_url_params/model/url_params_data.dart';

extension UrlParamsUtils on BuildContext {
  void setUrlParamsFromMap({
    Map<String, dynamic> queryParams = const {},
    Map<String, dynamic> pathParams = const {},
  }) {
    final router = GoRouter.of(this);
    // Intentionally non-subscribing: callers mutate the URL from callbacks
    // and must not rebuild on every URL change as a side effect.
    final newQueryParameters = {
      ...router.state.uri.queryParameters,
      ...Map.fromEntries(
        queryParams.entries
            .map((entry) => MapEntry(entry.key, entry.value?.toString()))
            .where((entry) => entry.value != null)
            .toList(),
      ),
    };
    final newPathParameters = {
      ...router.state.pathParameters,
      ...pathParams.map((key, value) => MapEntry(key, value.toString())),
    };
    GoRouter.of(this).go(
      router.state.uri
          .replace(
            path: _formatPath(router.state.fullPath ?? '', newPathParameters),
            queryParameters: newQueryParameters,
          )
          .toString(),
    );
  }

  void setUrlParams(UrlParamsData params) {
    final flattenedParams = _flattenParams(params.toJson());

    final pathParamsKeys = GoRouter.of(this).state.pathParameters.keys;
    final pathParams = Map.fromEntries(
      flattenedParams.entries.where(
        (entry) => pathParamsKeys.contains(entry.key),
      ),
    );
    final queryParams = Map.fromEntries(
      flattenedParams.entries.where(
        // query params must not have the same keys as path params
        (entry) => !pathParamsKeys.contains(entry.key),
      ),
    );

    setUrlParamsFromMap(queryParams: queryParams, pathParams: pathParams);
  }

  T? watchQueryParamFromKey<T>(String key) {
    final model = InheritedModel.inheritFrom<_UrlParamsModel>(
      this,
      aspect: _QueryKeyAspect(key),
    );
    if (model != null) {
      return _tryParse<T>(model.queryParams[key]);
    }
    // fall back to the router's state, no caching for serialization/deserialization
    return _tryParse<T>(GoRouter.of(this).state.uri.queryParameters[key]);
  }

  T? watchPathParamFromKey<T>(String key) {
    final model = InheritedModel.inheritFrom<_UrlParamsModel>(
      this,
      aspect: _PathKeyAspect(key),
    );
    if (model != null) {
      return _tryParse<T>(model.pathParams[key]);
    }
    // fall back to the router's state, no caching for serialization/deserialization
    return _tryParse<T>(GoRouter.of(this).state.pathParameters[key]);
  }

  /// Reads typed URL params and rebuilds only when the parsed [T] changes.
  ///
  /// Example:
  /// ```dart
  /// final person = context.watchUrlParams<Person>();
  /// ```
  ///
  /// Requires a [UrlParamsScope] ancestor that registered a
  /// [UrlParamBuilder] for [T]. The parsed result is cached per [T] for
  /// the lifetime of a URL, so the registered builder runs at most once
  /// per URL change regardless of how many widgets read the same [T].
  ///
  /// Returns `null` if no scope is found or if no builder is registered
  /// for [T].
  T? watchUrlParams<T extends UrlParamsData>() {
    final model = InheritedModel.inheritFrom<_UrlParamsModel>(
      this,
      aspect: _TypeAspect(T),
    );
    assert(
      model != null,
      'watchUrlParams<$T>() requires a UrlParamsScope ancestor with a '
      'registered UrlParamBuilder<$T>.',
    );
    return model?.parse<T>();
  }
}

/// Typed registration entry used by [UrlParamsScope.builders].
///
/// One [UrlParamBuilder] per concrete [UrlParamsData] subclass tells the
/// scope how to deserialize that type from the URL.
class UrlParamBuilder<T extends UrlParamsData> {
  const UrlParamBuilder(this.builder);

  final UrlParamsDataBuilder<T> builder;

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
///   routerConfig: router,
///   builder: (context, child) => UrlParamsScope(
///     router: router,
///     builders: const [
///       UrlParamBuilder(Person.fromJson),
///       UrlParamBuilder(PersonStatus.fromJson),
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

  @override
  State<UrlParamsScope> createState() => _UrlParamsScopeState();
}

class _UrlParamsScopeState extends State<UrlParamsScope> {
  @override
  Widget build(BuildContext context) {
    // The parent Router rebuilds and re-invokes MaterialApp.router's builder
    // on every URL change, which causes this build() to re-run. So we read
    // params freshly here without subscribing to the router ourselves.
    Map<String, String> pathParams = const {};
    Map<String, String> queryParams = const {};
    try {
      pathParams = widget.router.state.pathParameters;
      queryParams = widget.router.state.uri.queryParameters;
    } catch (_) {
      // Route not yet matched on the very first frame.
    }
    final builders = <Type, UrlParamsDataBuilder>{
      for (final entry in widget.builders) entry.type: entry.builder,
    };
    return _UrlParamsModel(
      pathParams: pathParams,
      queryParams: queryParams,
      builders: builders,
      parseCache: <Type, UrlParamsData?>{},
      child: widget.child,
    );
  }
}

class _QueryKeyAspect {
  const _QueryKeyAspect(this.key);
  final String key;

  @override
  bool operator ==(Object other) =>
      other is _QueryKeyAspect && other.key == key;

  @override
  int get hashCode => Object.hash(_QueryKeyAspect, key);
}

class _PathKeyAspect {
  const _PathKeyAspect(this.key);
  final String key;

  @override
  bool operator ==(Object other) => other is _PathKeyAspect && other.key == key;

  @override
  int get hashCode => Object.hash(_PathKeyAspect, key);
}

/// Aspect that identifies a typed URL params consumer by its [Type].
///
/// The actual builder lives on the [_UrlParamsModel] (registered once on
/// the [UrlParamsScope]), so the aspect only needs to carry the [Type] to
/// look it up during dispatch.
class _TypeAspect {
  const _TypeAspect(this.type);

  final Type type;

  @override
  bool operator ==(Object other) => other is _TypeAspect && other.type == type;

  @override
  int get hashCode => type.hashCode;
}

class _UrlParamsModel extends InheritedModel<Object> {
  const _UrlParamsModel({
    required this.pathParams,
    required this.queryParams,
    required this.builders,
    required this.parseCache,
    required super.child,
  });

  final Map<String, String> pathParams;
  final Map<String, String> queryParams;
  final Map<Type, UrlParamsDataBuilder> builders;
  final Map<Type, UrlParamsData?> parseCache;

  T? parse<T extends UrlParamsData>() => _parseForType(T) as T?;

  UrlParamsData? _parseForType(Type type) {
    if (parseCache.containsKey(type)) {
      return parseCache[type];
    }
    final builder = builders[type];
    UrlParamsData? result;
    if (builder != null) {
      try {
        result = builder({...queryParams, ...pathParams});
      } catch (_) {
        result = null;
      }
    }
    parseCache[type] = result;
    return result;
  }

  @override
  bool updateShouldNotify(_UrlParamsModel oldWidget) {
    return !mapEquals(pathParams, oldWidget.pathParams) ||
        !mapEquals(queryParams, oldWidget.queryParams);
  }

  @override
  bool updateShouldNotifyDependent(
    _UrlParamsModel oldWidget,
    Set<Object> aspects,
  ) {
    for (final aspect in aspects) {
      if (aspect is _QueryKeyAspect) {
        if (queryParams[aspect.key] != oldWidget.queryParams[aspect.key]) {
          return true;
        }
      } else if (aspect is _PathKeyAspect) {
        if (pathParams[aspect.key] != oldWidget.pathParams[aspect.key]) {
          return true;
        }
      } else if (aspect is _TypeAspect) {
        if (oldWidget._parseForType(aspect.type) !=
            _parseForType(aspect.type)) {
          return true;
        }
      }
    }
    return false;
  }
}

String _formatPath(String fullPath, Map<String, String> pathParameters) {
  var result = fullPath;
  for (final entry in pathParameters.entries) {
    result = result.replaceAll(':${entry.key}', entry.value);
  }
  return result;
}

Map<String, String> _flattenParams(Map<String, dynamic> params) {
  final entries = params.entries;
  final result = <String, String>{};
  for (final entry in entries) {
    if (entry.value is Map<String, dynamic>) {
      result.addAll(_flattenParams(entry.value as Map<String, dynamic>));
    } else {
      final value = entry.value?.toString();
      if (value != null) {
        result.putIfAbsent(entry.key, () => value.toString());
      }
    }
  }
  return result;
}

T? _tryParse<T>(String? value) {
  if (value == null) {
    return null;
  }
  if (T == String || T.toString() == 'String?') {
    return value as T;
  }
  if (T == int || T.toString() == 'int?') {
    return int.tryParse(value) as T;
  }
  if (T == double || T.toString() == 'double?') {
    return double.tryParse(value) as T;
  }
  if (T == bool || T.toString() == 'bool?') {
    return bool.tryParse(value) as T;
  }
  return null;
}
