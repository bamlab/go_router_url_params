typedef UrlParamsDataBuilder<T extends UrlParamsData> =
    T? Function(Map<String, String> params);

abstract class UrlParamsData {
  Map<String, dynamic> toMap();
}
