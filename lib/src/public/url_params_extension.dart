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
    // Intentionally non-subscribing: callers mutate the URL from callbacks
    // and must not rebuild on every URL change as a side effect.
    final newQueryParameters = {
      ...router.state.uri.queryParametersAll,
      ...queryParams,
    };
    final newPathParameters = {...router.state.pathParameters, ...pathParams};
    router.go(
      router.state.uri
          .replace(
            path: formatPath(router.state.fullPath ?? '', newPathParameters),
            queryParameters: newQueryParameters,
          )
          .toString(),
    );
  }

  /// Warning: Don't name any path parameter with the same key than a query parameter.
  /// If some path param has the same name than a query param, and the function recieves
  /// a value for this name, it can't guess where to put it. In this case, the value
  /// will be used for the path param, and the query param will always be empty.
  ///
  /// If you really need to do that, you can still use the lower level
  /// [setUrlParamsFromMap] in combinaison with [watchQueryParamFromKey] and [watchPathParamFromKey]
  ///
  /// ---
  ///
  /// Sets the [params] object in the url, rebuilding the UI wherever needed,
  /// which means wherever [watchUrlParams] is used.
  void setUrlParams(UrlParamsData params) {
    final flattenedParams = flattenParams(params.toMap());

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
  ///
  /// Example:
  /// ```dart
  /// final age = context.watchQueryParamFromKey('age'); // age is int or null
  /// ```
  /// Returns `null` if no query param is found or if the function
  /// fails to parse the value from String to [T].
  ///
  /// Currently, only the following types are supported:
  /// String, int, double, bool, DateTime, or List of these types.
  T? watchQueryParamFromKey<T>(String key) {
    final model = InheritedModel.inheritFrom<UrlParamsModel>(
      this,
      aspect: QueryKeyAspect(key),
    );
    if (model != null) {
      return tryParse<T>(model.queryParams[key]);
    }
    // fall back to the router's state
    return tryParse<T>(GoRouter.of(this).state.uri.queryParameters[key]);
  }

  /// Reads typed path params and rebuilds only when this specific
  /// path parameter changes.
  ///
  /// Example:
  /// ```dart
  /// final name = context.watchPathParamFromKey('name');
  /// ```
  /// Returns `null` if no path param is found or if the function
  /// fails to parse the value from String to [T].
  ///
  /// Currently, only the following types are supported:
  /// String, int, double, bool, DateTime, or List of these types.
  T? watchPathParamFromKey<T>(String key) {
    final model = InheritedModel.inheritFrom<UrlParamsModel>(
      this,
      aspect: PathKeyAspect(key),
    );
    if (model != null) {
      return tryParse<T>(model.pathParams[key]);
    }
    // fall back to the router's state
    return tryParse<T>(GoRouter.of(this).state.pathParameters[key]);
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
}
