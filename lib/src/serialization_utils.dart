String formatPath(String fullPath, Map<String, String> pathParameters) {
  var result = fullPath;
  for (final entry in pathParameters.entries) {
    result = result.replaceAll(':${entry.key}', entry.value);
  }
  return result;
}

/// A nested map becomes a non nested map without any information loss.
/// null values are not kept
/// example:
/// ```dart
/// {
///   "name": "Rico",
///   "age": 25,
///   "status": {
///     "isActive": true,
///     "jobs":[
///       "developper",
///       "super-hero"
///     ],
///     "labels": [
///       {"label":"label1"},
///       {"label":"label2"}
///     ],
///     "weaknesses": null
///   }
/// }
/// ```
///
/// becomes :
/// ```dart
/// {
///   "name": "Rico",
///   "age": 25,
///   "status.isActive": true,
///   "status.jobs[0]": "developper",
///   "status.jobs[1]": "super-hero",
///   "status.labels[0].label": "label1",
///   "status.labels[1].label": "label2"
/// }
/// ```
Map<String, dynamic> flattenParams(
  Map<String, dynamic> params, {
  String? prefix,
}) {
  final entries = params.entries;
  final result = <String, dynamic>{};
  for (final entry in entries) {
    final value = entry.value;
    if (value is Map<String, dynamic>) {
      final flattenedValue = flattenParams(value, prefix: entry.key);
      result.addAll(flattenedValue.maybePrefixed(prefix));
    } else if (value is List) {
      for (final (index, element) in value.indexed) {
        final flattened = flattenParams({"${entry.key}[$index]": element});
        result.addAll(flattened.maybePrefixed(prefix));
      }
    } else {
      final value = entry.value;
      if (value != null) {
        result[entry.key.maybePrefixed(prefix)] = value;
      }
    }
  }
  return result;
}

extension _MaybePrefixString on String {
  String maybePrefixed(String? prefix) {
    if (prefix == null) return this;
    return "$prefix.$this";
  }
}

extension _MaybePrefixMap on Map<String, dynamic> {
  Map<String, dynamic> maybePrefixed(String? prefix) {
    if (prefix == null) return this;
    return Map.fromEntries(
      entries.map((subEntry) {
        final newSubKey = subEntry.key.maybePrefixed(prefix);
        return MapEntry(newSubKey, subEntry.value);
      }),
    );
  }
}

/// Rearranges a map flattened by [flattenParams] into
/// a map of lists of strings, coherent with the way GoRouter
/// handles query params with its .queryParametersAll property.
///
/// Example:
/// ```dart
/// {
///   "example": "good",
///   "bar[0]": 1,
///   "bar[1]": 26,
///   "foo[0].example2": "true",
///   "foo[0].example3[0]": "42"
/// }
/// ```
///
/// becomes
///
/// ```dart
///
/// {
///   "example": ["good"],
///   "bar": ["1","26"],
///   "foo[0].example2": ["true"]
///   "foo[0].example3[0]": ["42"]
/// }
Iterable<MapEntry<String, List<String>>> flattenedQueryParamsToListOfStrings(
  Iterable<MapEntry<String, dynamic>> entries,
) {
  final trailingIndexRegex = RegExp(r'(?<!\..*)\[\d+\]$');
  final grouped = <String, List<String>>{};
  for (final entry in entries) {
    if (entry.value == null) continue;
    final key = entry.key.replaceFirst(trailingIndexRegex, '');
    grouped.putIfAbsent(key, () => <String>[]).add(entry.value.toString());
  }
  return grouped.entries;
}

/// Transforms a flatterned map (obtained from the pathParameters / queryParametersAll)
/// of the router or from [flattenParams] and [flattenedQueryParamsToListOfStrings])
/// to a map that can be used to construct an object with its typical fromMap/fromJson method.
///
/// Inverse function of the product of [flattenParams] and [flattenedQueryParamsToListOfStrings].
///
/// Example:
/// ```dart
/// {
///   "name": "Rico",
///   "age": 25,
///   "status.isActive": true,
///   "status.jobs": ["developper", "super-hero"],
///   "status.labels[0].label": "label1",
///   "status.labels[1].label": "label2"
/// }
/// ```
///
/// becomes :
///
/// ```dart
/// {
///   "name": "Rico",
///   "age": 25,
///   "status": {
///     "isActive": true,
///     "jobs":[
///       "developper",
///       "super-hero"
///     ],
///     "labels": [
///       {"label":"label1"},
///       {"label":"label2"}
///     ],
///   }
/// }
/// ```
///
Map<String, dynamic> unFlattenParams(Map<String, dynamic> flattenedMap) {
  final result = <String, dynamic>{};
  for (final entry in flattenedMap.entries) {
    final tokens = _parseKeyPath(entry.key);
    if (tokens.isEmpty) continue;
    _assignAtPath(result, tokens, entry.value);
  }
  return result;
}

/// A token in a flattened key path: either a [String] (map key) or an
/// [int] (list index).
List<Object> _parseKeyPath(String key) {
  final tokens = <Object>[];
  final indexRegex = RegExp(r'\[(\d+)\]');
  for (final segment in key.split('.')) {
    if (segment.isEmpty) continue;
    final firstBracket = segment.indexOf('[');
    final name = firstBracket == -1
        ? segment
        : segment.substring(0, firstBracket);
    if (name.isNotEmpty) tokens.add(name);
    if (firstBracket == -1) continue;
    for (final match in indexRegex.allMatches(segment, firstBracket)) {
      final index = tryParse<int>(match.group(1));
      if (index != null) tokens.add(index);
    }
  }
  return tokens;
}

void _assignAtPath(
  Map<String, dynamic> root,
  List<Object> path,
  dynamic value,
) {
  dynamic container = root;
  for (var i = 0; i < path.length; i++) {
    final token = path[i];
    final isLast = i == path.length - 1;
    final nextIsIndex = !isLast && path[i + 1] is int;
    if (token is String) {
      final map = container as Map<String, dynamic>;
      if (isLast) {
        map[token] = value;
      } else {
        final existing = map[token];
        if (existing == null) {
          container = nextIsIndex ? <dynamic>[] : <String, dynamic>{};
          map[token] = container;
        } else {
          container = existing;
        }
      }
    } else if (token is int) {
      final list = container as List;
      while (list.length <= token) {
        list.add(null);
      }
      if (isLast) {
        list[token] = value;
      } else {
        final existing = list[token];
        if (existing == null) {
          final created = nextIsIndex ? <dynamic>[] : <String, dynamic>{};
          list[token] = created;
          container = created;
        } else {
          container = existing;
        }
      }
    }
  }
}

/// Function used to parse a string to a typed value.
/// Used to transform a map like this:
/// ```dart
/// {
///   "example": "good",
///   "bar": ["1","26"],
///   "foo[0].example2": "true"
/// }
/// ```
/// into this:
///
/// ```dart
/// {
///   "example": "good",
///   "bar": [1,26],
///   "foo[0].example2": true
/// }
/// ```
///
/// Currently, only the following types are supported:
/// String, int, double, bool, DateTime, or List of these types.
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
  if (T == (List<String>) || T.toString() == 'List<String>?') {
    return value.toString().split(',') as T;
  }
  if (T == (List<int>) || T.toString() == 'List<int>?') {
    return value.toString().split(',').map(int.tryParse).toList() as T;
  }
  if (T == (List<double>) || T.toString() == 'List<double>?') {
    return value.toString().split(',').map(double.tryParse).toList() as T;
  }
  if (T == (List<bool>) || T.toString() == 'List<bool>?') {
    return value.toString().split(',').map(bool.tryParse).toList() as T;
  }
  if (T == (List<DateTime>) || T.toString() == 'List<DateTime>?') {
    return value.toString().split(',').map(DateTime.tryParse).toList() as T;
  }

  return null;
}
