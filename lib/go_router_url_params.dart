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
  /// final person = context.watchUrlParams(Person.fromJson);
  /// ```
  /// Uses the [T]'s serialization logic to parse the URL params.
  ///
  /// When a [UrlParamsScope] ancestor is present, the parsed result is cached
  /// per [T] for the lifetime of a URL, so the [builder] runs at most once
  /// per URL change regardless of how many widgets read the same [T] and
  /// regardless of whether [builder] is a tear-off or an inline closure.
  ///
  /// Without a [UrlParamsScope] ancestor the call still works but the
  /// deserialization logic is executed once per caller whenever the URL
  /// changes.
  T? watchUrlParams<T extends UrlParamsData>(UrlParamsDataBuilder<T> builder) {
    final model = InheritedModel.inheritFrom<_UrlParamsModel>(
      this,
      aspect: _BuilderAspect<T>(builder),
    );
    if (model != null) {
      return model.parse<T>(builder);
    }
    // fall back to the router's state, no caching for serialization/deserialization
    final router = GoRouter.of(this);
    try {
      return builder({
        ...router.state.uri.queryParameters,
        ...router.state.pathParameters,
      });
    } catch (_) {
      return null;
    }
  }
}

/// Caches parsed URL params and scopes rebuilds to consumers whose slice
/// of the URL actually changed.
///
/// Place once below `MaterialApp.router` via the `builder:` argument and pass
/// the same [GoRouter] instance you gave to `MaterialApp.router`:
///
/// ```dart
/// MaterialApp.router(
///   routerConfig: router,
///   builder: (context, child) => UrlParamsScope(
///     router: router,
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
  const UrlParamsScope({super.key, required this.router, required this.child});

  final GoRouter router;
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
    return _UrlParamsModel(
      pathParams: pathParams,
      queryParams: queryParams,
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

/// Aspect that identifies a typed URL params consumer.
///
/// Equality is based solely on [T], so two aspects produced from the same
/// type but different [builder] instances (e.g. an inline closure rebuilt
/// each frame) deduplicate correctly in the dependency set and share the
/// same cache slot. The [builder] is carried for use during dispatch when
/// the model needs to compute the parsed value against the old map.
class _BuilderAspect<T extends UrlParamsData> {
  _BuilderAspect(this.builder) : type = T;

  final Type type;
  final UrlParamsDataBuilder<T> builder;

  @override
  bool operator ==(Object other) =>
      other is _BuilderAspect && other.type == type;

  @override
  int get hashCode => type.hashCode;
}

class _UrlParamsModel extends InheritedModel<Object> {
  const _UrlParamsModel({
    required this.pathParams,
    required this.queryParams,
    required this.parseCache,
    required super.child,
  });

  final Map<String, String> pathParams;
  final Map<String, String> queryParams;
  final Map<Type, UrlParamsData?> parseCache;

  T? parse<T extends UrlParamsData>(UrlParamsDataBuilder<T> builder) {
    if (parseCache.containsKey(T)) {
      return parseCache[T] as T?;
    }
    T? result;
    try {
      result = builder({...queryParams, ...pathParams});
    } catch (_) {
      result = null;
    }
    parseCache[T] = result;
    return result;
  }

  UrlParamsData? _parseFromAspect(_BuilderAspect aspect) {
    if (parseCache.containsKey(aspect.type)) {
      return parseCache[aspect.type];
    }
    UrlParamsData? result;
    try {
      result = aspect.builder({...queryParams, ...pathParams});
    } catch (_) {
      result = null;
    }
    parseCache[aspect.type] = result;
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
      } else if (aspect is _BuilderAspect) {
        if (oldWidget._parseFromAspect(aspect) != _parseFromAspect(aspect)) {
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
