import 'package:flutter/material.dart';
import 'package:go_router_url_watcher/go_router_url_watcher.dart';

enum Flavor {
  strawberries,
  chocolate,
  vanilla;

  static String get pathParamName => 'flavor';
  static Flavor get defaultFlavor => Flavor.strawberries;

  /// How to get a Flavor from any String
  static Flavor? parseFromString(String value) {
    try {
      return Flavor.values.byName(value);
    } catch (e) {
      // I really mean ANY String.
      // Always be careful with people messing with the url
      return null;
    }
  }

  static Flavor? watchFromUrl(BuildContext context) {
    return context.watchPathParamFromKey<Flavor>(
      Flavor.pathParamName,
      parseFromString: Flavor.parseFromString,
    );
  }

  static void setInUrl(BuildContext context, Flavor flavor) {
    context.setUrlParamsFromMap(
      pathParams: {Flavor.pathParamName: flavor.name},
    );
  }
}
