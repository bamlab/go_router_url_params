import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_url_params/go_router_url_params.dart';
import 'package:go_router_url_params/src/serialization_utils.dart';
import 'package:go_router_url_params/src/url_params_model.dart';

extension UrlParamsExtension on BuildContext {
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
            path: formatPath(router.state.fullPath ?? '', newPathParameters),
            queryParameters: newQueryParameters,
          )
          .toString(),
    );
  }

  void setUrlParams(UrlParamsData params) {
    final flattenedParams = flattenParams(params.toJson());

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
    final model = InheritedModel.inheritFrom<UrlParamsModel>(
      this,
      aspect: QueryKeyAspect(key),
    );
    if (model != null) {
      return tryParse<T>(model.queryParams[key]);
    }
    // fall back to the router's state, no caching for serialization/deserialization
    return tryParse<T>(GoRouter.of(this).state.uri.queryParameters[key]);
  }

  T? watchPathParamFromKey<T>(String key) {
    final model = InheritedModel.inheritFrom<UrlParamsModel>(
      this,
      aspect: PathKeyAspect(key),
    );
    if (model != null) {
      return tryParse<T>(model.pathParams[key]);
    }
    // fall back to the router's state, no caching for serialization/deserialization
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
