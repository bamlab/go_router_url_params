typedef UrlParamsDataBuilder<T extends UrlParamsData> =
    T? Function(Map<String, dynamic> params);

mixin UrlParamsData {
  Map<String, dynamic> toMap();

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
