import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation_state_provider.dart';

class NavigationObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _updateNavigationState(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _updateNavigationState(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _updateNavigationState(newRoute);
    }
  }

  void _updateNavigationState(Route<dynamic> route) {
    final context = route.navigator?.context;
    if (context != null) {
      final navigationProvider = Provider.of<NavigationStateProvider>(
        context,
        listen: false,
      );

      final routeName = route.settings.name;
      final isOnMainMap = routeName == '/' || routeName == null;
      
      navigationProvider.setOnMainMap(isOnMainMap);
    }
  }
}
