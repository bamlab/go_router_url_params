export 'model/url_params_data.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_url_params/model/url_params_data.dart';

extension UrlParamsUtils on BuildContext {
  void setUrlParamsFromMap({
    Map<String, dynamic> queryParams = const {},
    Map<String, dynamic> pathParams = const {},
  }) {
    final newQueryParameters = {
      ...GoRouter.of(this).state.uri.queryParameters,
      ...Map.fromEntries(
        queryParams.entries
            .map((entry) => MapEntry(entry.key, entry.value?.toString()))
            .where((entry) => entry.value != null)
            .toList(),
      ),
    };
    final newPathParameters = {
      ...GoRouter.of(this).state.pathParameters,
      ...pathParams.map((key, value) => MapEntry(key, value.toString())),
    };
    GoRouter.of(this).go(
      GoRouter.of(this).state.uri
          .replace(
            path: _formatPath(
              GoRouter.of(this).state.fullPath ?? '',
              newPathParameters,
            ),
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
    final queryParams = GoRouter.of(this).state.uri.queryParameters;
    return _tryParse<T>(queryParams[key]);
  }

  T? watchPathParamFromKey<T>(String key) {
    final pathParams = GoRouter.of(this).state.pathParameters;
    return _tryParse<T>(pathParams[key]);
  }

  T? watchUrlParams<T extends UrlParamsData>(UrlParamsDataBuilder<T> builder) {
    final pathParams = GoRouter.of(this).state.pathParameters;
    final queryParams = GoRouter.of(this).state.uri.queryParameters;
    try {
      return builder({...queryParams, ...pathParams});
    } catch (e) {
      return null;
    }
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
      result.putIfAbsent(entry.key, () => entry.value.toString());
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
