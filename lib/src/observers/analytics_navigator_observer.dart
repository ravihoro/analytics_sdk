import 'package:analytics_sdk/analytics_sdk.dart';
import 'package:flutter/material.dart';

class AnalyticsNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _track(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _track(newRoute);
    }
  }

  void _track(Route<dynamic> route) {
    final name = route.settings.name;

    if (name == null || name.isEmpty) return;

    Analytics.screen(name);
  }
}

/// For using this
// GoRouter(
//   observers: [AnalyticsNavigatorObserver()],
//   // ...
// )
