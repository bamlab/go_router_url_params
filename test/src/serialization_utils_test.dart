import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_url_params/src/serialization_utils.dart';

void main() {
  test('flatten maps', () async {
    final nestedMap = {
      "name": "Rico",
      "age": 25,
      "status": {
        "isActive": true,
        "jobs": ["developper", "super-hero"],
        "labels": [
          {"label": "label1"},
          {"label": "label2"},
        ],
        "weaknesses": null,
      },
    };

    final flattenedMap = flattenParams(nestedMap);
    expect(flattenedMap, {
      "name": "Rico",
      "age": 25,
      "status.isActive": true,
      "status.jobs[0]": "developper",
      "status.jobs[1]": "super-hero",
      "status.labels[0].label": "label1",
      "status.labels[1].label": "label2",
    });
  });

  test('flattenedQueryParamsToListOfStrings', () async {
    final entries = [
      MapEntry('example', 'good'),
      MapEntry('bar[0]', 1),
      MapEntry('bar[1]', 26),
      MapEntry('foo[0].example2', 'true'),
    ];
    final result = flattenedQueryParamsToListOfStrings(entries);
    expect(
      Map.fromEntries(result),
      Map.fromEntries([
        MapEntry('example', ['good']),
        MapEntry('bar', ['1', '26']),
        MapEntry('foo[0].example2', ['true']),
      ]),
    );
  });
}
