typedef UrlParamsDataBuilder<T extends UrlParamsData> =
    T? Function(Map<String, String> params);

abstract class UrlParamsData {
  const UrlParamsData();
  Map<String, dynamic> toMap();

  static Object? tryParse(Map<dynamic, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;

    //TODO(louis): support enums
    return int.tryParse(value) ??
        double.tryParse(value) ??
        bool.tryParse(value) ??
        value.toString();
  }
}

Map<String, dynamic>? readObjectFromString(
  Map<dynamic, dynamic> json,
  String key,
) => json as Map<String, dynamic>;

Map<String, dynamic> writeObjectToJson<T extends UrlParamsData?>(T status) =>
    status?.toMap() ?? {};
