import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_url_params/go_router_url_params.dart';
import 'package:go_router_url_params/src/serialization_utils.dart';
import 'package:go_router_url_params/src/url_params_model.dart';

extension UrlParamsExtension on BuildContext {
  void setUrlParamsFromMap({
    Map<String, List<String>> queryParams = const {},
    Map<String, String> pathParams = const {},
  }) {
    final router = GoRouter.of(this);
    final newQueryParameters = {
      ...router.state.uri.queryParametersAll,
      ...queryParams,
    };
    final newPathParameters = {...router.state.pathParameters, ...pathParams};

    router.go(
      router.state.uri
          .replace(
            path: formatPath(router.state.fullPath ?? '', newPathParameters),
            query: newQueryParameters.isNotEmpty
                ? formatToQueryString(newQueryParameters)
                : null,
          )
          .toString(),
    );
  }

  /// Sets the [params] object in the url, rebuilding the UI wherever needed,
  /// which means wherever [watchUrlParams] is used with the same [T] type.
  ///
  /// ---
  /// Warning: Don't name any path parameter with the same key than a query parameter.
  /// If some path param has the same name than a query param, and the function recieves
  /// a value for this name, it can't guess where to put it. In this case, the value
  /// will be used for the path param, and the query param will always be empty.
  ///
  /// If you really need to do that, you can still use the lower level
  /// [setUrlParamsFromMap] in combinaison with [watchQueryParamFromKey] and [watchPathParamFromKey]
  void setUrlParams<T extends UrlParamsData>(T params) {
    final key = UrlParamsScope.prefixKeysOf(this)[T];
    final flattenedParams = flattenParams(params.toMap(), prefix: key);

    final pathParamsKeys = GoRouter.of(this).state.pathParameters.keys;
    final pathParams = Map.fromEntries(
      flattenedParams.entries
          .where((entry) => pathParamsKeys.contains(entry.key))
          .map((entry) {
            return MapEntry(entry.key, entry.value.toString());
          }),
    );
    final queryParams = Map.fromEntries(
      flattenedQueryParamsToListOfStrings(
        flattenedParams.entries.where(
          // query params must not have the same keys as path params
          (entry) => !pathParamsKeys.contains(entry.key),
        ),
      ),
    );

    setUrlParamsFromMap(queryParams: queryParams, pathParams: pathParams);
  }

  /// Reads typed query param and rebuilds only when this specific
  /// query parameter changes.
  /// Requires a [UrlParamsScope] ancestor to trigger a rebuild when the value changes.
  ///
  /// Example:
  /// ```dart
  /// final age = context.watchQueryParamFromKey('age');
  /// ```
  /// Returns `null` if no query param is found for the given [key],
  /// if no [UrlParamsScope] ancestor is found or if the function
  /// fails to parse the value from String to [T].
  ///
  /// Repeated query keys (`?tag=a&tag=b`) are exposed by GoRouter as a list of
  /// values. Read them with a `List<...>` type to get every value; reading a
  /// scalar type keeps the last value.
  ///
  /// If [parseFromString] is provided it is applied to every value:
  /// - reading a `List<...>` returns the parsed values,
  /// - reading a scalar returns the parsed last value.
  ///
  /// If [parseFromString] is not provided, only the following types
  /// are supported by default:
  /// String, int, double, bool, DateTime, or List of these types.
  ///
  /// Returns `null` if no value is found for the given [key], if no
  /// [UrlParamsScope] ancestor is found, or if the value(s) cannot be parsed
  /// to [T].
  T? watchQueryParamFromKey<T>(
    String key, {
    Object? Function(String)? parseFromString,
  }) {
    final model = InheritedModel.inheritFrom<UrlParamsModel>(
      this,
      aspect: QueryKeyAspect(key),
    );
    assert(
      model != null,
      'watchQueryParamFromKey<$T>() requires a UrlParamsScope ancestor with a '
      'registered UrlParamBuilder<$T>.',
    );
    if (model == null) {
      return null;
    }
    final values = model.queryParams[key];
    if (values == null || values.isEmpty) {
      return null;
    }
    if (parseFromString != null) {
      final parsed = [for (final value in values) parseFromString(value)];
      if (parsed is T) {
        return parsed as T;
      }
      final last = parsed.last;
      return last is T ? last : null;
    }
    return tryParseQuery<T>(values);
  }

  /// Reads typed path params and rebuilds only when this specific
  /// path parameter changes.
  /// Requires a [UrlParamsScope] ancestor to trigger a rebuild when the value changes.
  ///
  /// Example:
  /// ```dart
  /// final name = context.watchPathParamFromKey('name');
  /// ```
  /// Returns `null` if no path param is found for the given [key],
  /// if no [UrlParamsScope] ancestor is found, or if the function
  /// fails to parse the value from String to [T].
  ///
  /// If [parseFromString] is provided, it will be used to parse the value from String to [T].
  /// If not, only the following types are supported by default:
  /// String, int, double, bool, DateTime, or List of these types.
  T? watchPathParamFromKey<T>(
    String key, {
    T? Function(String)? parseFromString,
  }) {
    final model = InheritedModel.inheritFrom<UrlParamsModel>(
      this,
      aspect: PathKeyAspect(key),
    );
    assert(
      model != null,
      'watchPathParamFromKey<$T>() requires a UrlParamsScope ancestor with a '
      'registered UrlParamBuilder<$T>.',
    );
    if (model == null) {
      return null;
    }
    final value = model.pathParams[key];
    if (value == null) {
      return null;
    }
    return parseFromString != null
        ? parseFromString(value)
        : tryParse<T>(value);
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
    final model = InheritedModel.inheritFrom<UrlParamsModel>(
      this,
      aspect: TypeAspect(T),
    );
    assert(
      model != null,
      'watchUrlParams<$T>() requires a UrlParamsScope ancestor with a '
      'registered UrlParamBuilder<$T>.',
    );
    return model?.parse<T>();
  }

  Uri get uri => GoRouter.of(this).state.uri;
}
