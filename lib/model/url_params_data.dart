typedef UrlParamsDataBuilder<T extends UrlParamsData> =
    T? Function(Map<String, String> params);

abstract class UrlParamsData {
  const UrlParamsData();
  Map<String, dynamic> toJson();
}
