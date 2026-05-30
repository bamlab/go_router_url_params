import 'package:go_router_url_params/src/serialization_utils.dart';

typedef UrlParamsDataBuilder<T extends UrlParamsData> =
    T Function(Map<String, dynamic> params);

mixin UrlParamsData {
  Map<String, dynamic> toMap();

  /// Helper method to convert the object to a query params string.
  /// Use it to easily add query params to your path in the router.
  ///
  /// Sometimes, you don't want all the keys to be included in the query params.
  /// For example, the UrlParamsData object may have a key for a path parameter
  /// that don't need to be included in the query params.
  /// You can use the [keysToIgnore] parameter to ignore only specific keys.
  /// You can also use the [keysToInclude] parameter to include only specific keys.
  ///
  /// Using [keysToInclude] can be more declarative, but it's more verbose.
  /// Using both might be a bit confusing.
  ///
  /// The keys passed to [keysToIgnore] or [keysToInclude] are the keys of the object,
  /// obtained from the object's [toMap] method.
  ///
  /// Example:
  /// ```dart
  /// context.go('/counter/${person.name}${person.toQueryParamsString(keysToIgnore: ["name"])}'),
  /// ```
  ///
  ///---
  ///
  /// If you pass a [currentUri], only the missing query params will be added to the url.
  /// This is useful when you want to be able to navigate from page B back to page A,
  /// and then to page B again, while keeping the state of page B all along the way.
  /// You can use the [BuildContext.uri] extension from this package.
  ///
  /// Example:
  /// ```dart
  /// context.go('/counter/${person.name}${person.toQueryParamsString(currentUrl: context.uri)}'),
  /// ```
  String toQueryParamsString({
    List<String>? keysToIgnore,
    List<String>? keysToInclude,
    Uri? currentUri,
  }) {
    final flattened = flattenParams(toMap());
    final entriesToKeep = flattened.entries.where((entry) {
      if (currentUri != null &&
          currentUri.queryParametersAll[entry.key] != null) {
        return false;
      }
      if (keysToIgnore != null && keysToIgnore.contains(entry.key)) {
        return false;
      }
      if (keysToInclude != null && !keysToInclude.contains(entry.key)) {
        return false;
      }
      return true;
    });
    final queryParamsString = entriesToKeep
        .map((entry) {
          final value = entry.value;
          final key = entry.key;
          if (value is List) {
            return value.map((element) => '$key=$element').toList().join('&');
          }
          return '$key=$value';
        })
        .join('&');
    if (currentUri != null && currentUri.queryParametersAll.isNotEmpty) {
      if (queryParamsString.isNotEmpty) {
        return '?${currentUri.query}&$queryParamsString';
      } else {
        return '?${currentUri.query}';
      }
    }
    return '?$queryParamsString';
  }

  /// Helper method to adapt the default parsing behavior of freezed /
  /// json_serializable to work with urls, which only support strings.
  /// Use it for non-string parameters, like this:
  /// ```dart
  /// @JsonKey(readValue: UrlParamsData.tryParse)
  /// final int age;
  /// ```
  /// See example/lib/model/freezed/person.dart and
  /// example/lib/model/json_serializable/person.dart for more detailed usage.
  static Object? tryParse(Map<dynamic, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;

    //TODO(louis): support enums
    return int.tryParse(value) ??
        double.tryParse(value) ??
        bool.tryParse(value) ??
        value.toString();
  }

  /// Helper method to read objects from strings in freezed / json_serializable
  /// serialization. This is needed because urls only support strings, and json_serializable
  /// expects typed maps.
  /// Use it for parameters that are themselves serializable objects, like this:
  /// ```dart
  /// @JsonKey(
  ///   readValue: UrlParamsData.readObjectFromString,
  ///   toJson: UrlParamsData.writeObjectToJson,
  /// )
  /// final PersonStatus? status;
  /// ```
  /// See example/lib/model/freezed/person.dart and
  /// example/lib/model/json_serializable/person.dart for more detailed usage.
  static Map<String, dynamic>? readObjectFromString(
    Map<dynamic, dynamic> json,
    String key,
  ) => json as Map<String, dynamic>;

  /// Helper method to write objects to strings in freezed / json_serializable
  /// serialization. This is needed because urls only support strings, and json_serializable
  /// expects typed maps.
  /// Use it for parameters that are themselves serializable objects, like this:
  /// ```dart
  /// @JsonKey(
  ///   readValue: UrlParamsData.readObjectFromString,
  ///   toJson: UrlParamsData.writeObjectToJson,
  /// )
  /// final PersonStatus? status;
  /// ```
  /// See example/lib/model/freezed/person.dart and
  /// example/lib/model/json_serializable/person.dart for more detailed usage.
  static Map<String, dynamic> writeObjectToJson<T extends UrlParamsData?>(
    T status,
  ) => status?.toMap() ?? {};
}
