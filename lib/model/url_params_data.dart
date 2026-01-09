typedef UrlParamsDataBuilder<T extends UrlParamsData> =
    T? Function(Map<String, String> params);

abstract class UrlParamsData {
  const UrlParamsData();
  Map<String, dynamic> toJson();
}

Map<String, dynamic>? readObjectFromString(
  Map<dynamic, dynamic> json,
  String key,
) => json as Map<String, dynamic>;

Map<String, dynamic> writeObjectToJson<T extends UrlParamsData>(T? status) =>
    status?.toJson() ?? {};
