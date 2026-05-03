String formatPath(String fullPath, Map<String, String> pathParameters) {
  var result = fullPath;
  for (final entry in pathParameters.entries) {
    result = result.replaceAll(':${entry.key}', entry.value);
  }
  return result;
}

Map<String, String> flattenParams(Map<String, dynamic> params) {
  final entries = params.entries;
  final result = <String, String>{};
  for (final entry in entries) {
    if (entry.value is Map<String, dynamic>) {
      result.addAll(flattenParams(entry.value as Map<String, dynamic>));
    } else {
      final value = entry.value?.toString();
      if (value != null) {
        result.putIfAbsent(entry.key, () => value.toString());
      }
    }
  }
  return result;
}

T? tryParse<T>(String? value) {
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
  if (T == DateTime || T.toString() == 'DateTime?') {
    return DateTime.tryParse(value) as T;
  }

  return null;
}
