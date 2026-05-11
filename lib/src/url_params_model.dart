import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router_url_params/src/public/url_params_data.dart';
import 'package:go_router_url_params/src/serialization_utils.dart';

class QueryKeyAspect {
  const QueryKeyAspect(this.key);
  final String key;

  @override
  bool operator ==(Object other) => other is QueryKeyAspect && other.key == key;

  @override
  int get hashCode => Object.hash(QueryKeyAspect, key);
}

class PathKeyAspect {
  const PathKeyAspect(this.key);
  final String key;

  @override
  bool operator ==(Object other) => other is PathKeyAspect && other.key == key;

  @override
  int get hashCode => Object.hash(PathKeyAspect, key);
}

/// Aspect that identifies a typed URL params consumer by its [Type].
///
/// The actual builder lives on the [UrlParamsModel] (registered once on
/// the [UrlParamsScope]), so the aspect only needs to carry the [Type] to
/// look it up during dispatch.
class TypeAspect {
  const TypeAspect(this.type);

  final Type type;

  @override
  bool operator ==(Object other) => other is TypeAspect && other.type == type;

  @override
  int get hashCode => type.hashCode;
}

class UrlParamsModel extends InheritedModel<Object> {
  const UrlParamsModel({
    super.key,
    required this.pathParams,
    required this.queryParams,
    required this.builders,
    required this.parseCache,
    required this.flatCache,
    required super.child,
  });

  final Map<String, String> pathParams;
  final Map<String, String> queryParams;
  final Map<Type, UrlParamsDataBuilder> builders;
  final Map<Type, UrlParamsData?> parseCache;

  /// Flattened `toJson()` for each parsed type, populated alongside
  /// [parseCache]. Used by [updateShouldNotifyDependent] to detect changes
  /// without calling `toJson()` per dependent.
  final Map<Type, Map<String, dynamic>?> flatCache;

  T? parse<T extends UrlParamsData>() => _cachedParseForType(T) as T?;

  UrlParamsData? _cachedParseForType(Type type) {
    if (parseCache.containsKey(type)) {
      return parseCache[type];
    }
    final builder = builders[type];
    UrlParamsData? result;
    if (builder != null) {
      try {
        result = builder(unFlattenParams({...queryParams, ...pathParams}));
      } catch (_) {
        result = null;
      }
    }
    parseCache[type] = result;
    flatCache[type] = result == null ? null : flattenParams(result.toMap());
    return result;
  }

  /// Returns the flattened `toJson()` representation of the parsed value
  /// for [type], computing and caching it (and the parsed instance) on
  /// first access. Returns `null` if no builder is registered for [type]
  /// or if the builder threw.
  Map<String, dynamic>? _flatFor(Type type) {
    _cachedParseForType(type);
    return flatCache[type];
  }

  @override
  bool updateShouldNotify(UrlParamsModel oldWidget) {
    return !mapEquals(pathParams, oldWidget.pathParams) ||
        !mapEquals(queryParams, oldWidget.queryParams);
  }

  @override
  bool updateShouldNotifyDependent(
    UrlParamsModel oldWidget,
    Set<Object> aspects,
  ) {
    for (final aspect in aspects) {
      if (aspect is QueryKeyAspect) {
        if (queryParams[aspect.key] != oldWidget.queryParams[aspect.key]) {
          return true;
        }
      } else if (aspect is PathKeyAspect) {
        if (pathParams[aspect.key] != oldWidget.pathParams[aspect.key]) {
          return true;
        }
      } else if (aspect is TypeAspect) {
        if (!mapEquals(
          oldWidget._flatFor(aspect.type),
          _flatFor(aspect.type),
        )) {
          return true;
        }
      }
    }
    return false;
  }
}
