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
Map<String, dynamic> unFlattenParams(Map<String, dynamic> flattenedMap) =>
    flattenedMap.entries.fold<Map<String, dynamic>>(<String, dynamic>{}, (
      acc,
      entry,
    ) {
      final tokens = _parseKeyPath(entry.key);
      if (tokens.isEmpty) return acc;
      return _setAtPath(acc, tokens, entry.value) as Map<String, dynamic>;
    });

final _indexRegex = RegExp(r'\[(\d+)\]');

/// Parses a flattened key (e.g. `status.labels[0].label`) into an ordered list
/// of access tokens: a [String] for a map key, an [int] for a list index.
List<Object> _parseKeyPath(String key) => [
  for (final segment in key.split('.'))
    if (segment.isNotEmpty) ..._tokensInSegment(segment),
];

/// Extracts the optional name and any `[index]` parts from a single
/// dot-separated segment (e.g. `labels[0]` -> `['labels', 0]`).
List<Object> _tokensInSegment(String segment) {
  final firstBracket = segment.indexOf('[');
  if (firstBracket == -1) return [segment];
  final name = segment.substring(0, firstBracket);
  final indices = _indexRegex
      .allMatches(segment, firstBracket)
      .map((match) => int.tryParse(match.group(1) ?? ""))
      .whereType<int>();
  return [if (name.isNotEmpty) name, ...indices];
}

/// Returns a copy of [root] with [value] placed at [path]. Missing intermediate
/// containers are created on the fly: maps for [String] tokens, lists padded
/// with `null` up to the requested index for [int] tokens.
dynamic _setAtPath(dynamic root, List<Object> path, dynamic value) {
  if (path.isEmpty) return value;
  final [token, ...rest] = path;
  if (token is String) {
    final map = (root as Map<String, dynamic>?) ?? const <String, dynamic>{};
    return <String, dynamic>{
      ...map,
      token: _setAtPath(map[token], rest, value),
    };
  }
  if (token is int) {
    final list = (root as List?) ?? const <dynamic>[];
    final length = token >= list.length ? token + 1 : list.length;
    return List<dynamic>.generate(length, (i) {
      final existing = i < list.length ? list[i] : null;
      return i == token ? _setAtPath(existing, rest, value) : existing;
    });
  }
  throw StateError('Unsupported path token: ${token.runtimeType}');
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
T? tryParse<T>(String value) {
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
