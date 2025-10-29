import 'dart:async';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

typedef RouteWidgetBuilder = Widget Function(BuildContext context, Map<String, dynamic> params);

class RouteConfig {
  final String name;
  final String pattern;
  final RouteWidgetBuilder builder;
  final bool requiresAuth;

  const RouteConfig({required this.name, required this.pattern, required this.builder, this.requiresAuth = false});
}

class RouteMatch {
  final RouteConfig config;
  final Map<String, dynamic> params;

  RouteMatch(this.config, [this.params = const {}]);
}

Map<String, String>? matchPattern(String pattern, String path) {
  final pSegs = Uri.parse(pattern).pathSegments;
  final aSegs = Uri.parse(path).pathSegments;
  if (pSegs.length != aSegs.length) return null;
  final params = <String, String>{};
  for (var i = 0; i < pSegs.length; i++) {
    final ps = pSegs[i];
    final as = aSegs[i];
    if (ps.startsWith(':')) {
      params[ps.substring(1)] = Uri.decodeComponent(as);
    } else if (ps != as) {
      return null;
    }
  }
  return params;
}

class AppRouteInformationParser extends RouteInformationParser<List<RouteMatch>> {
  final List<RouteConfig> routes;

  AppRouteInformationParser(this.routes);

  @override
  Future<List<RouteMatch>> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = routeInformation.uri;
    final location = uri.toString();

    for (final r in routes) {
      final params = matchPattern(r.pattern, location);
      if (params != null) return [RouteMatch(r, params)];
    }

    final home = routes.firstWhere((r) => r.pattern == '/', orElse: () => routes.first);
    return [RouteMatch(home, {})];
  }

  @override
  RouteInformation? restoreRouteInformation(List<RouteMatch> configuration) {
    if (configuration.isEmpty) return RouteInformation(uri: Uri(path: '/'));
    final last = configuration.last;
    var loc = last.config.pattern;
    last.params.forEach((k, v) {
      if (v is String) {
        loc = loc.replaceFirst(':$k', Uri.encodeComponent(v));
      } else {
        loc = loc.replaceFirst(':$k', v.toString());
      }
    });
    return RouteInformation(uri: Uri.parse(loc));
  }
}

class AppRouterDelegate extends RouterDelegate<List<RouteMatch>> with ChangeNotifier, PopNavigatorRouterDelegateMixin<List<RouteMatch>> {
  final Map<RouteMatch, Completer<dynamic>> _resultCompleters = {};
  final List<RouteConfig> routes;
  @override
  final GlobalKey<NavigatorState> navigatorKey = globalNavigatorKey;

  final List<RouteMatch> _stack = [];

  AppRouterDelegate({required this.routes}) {
    final home = routes.firstWhere((r) => r.pattern == '/', orElse: () => routes.first);
    _stack.add(RouteMatch(home, {}));
  }

  List<Page> get _pages => List.unmodifiable(
    _stack.asMap().entries.map((entry) {
      final index = entry.key;
      final m = entry.value;
      final paramsKey = m.params.entries.map((e) => '${e.key}=${e.value}').join('&');
      final keyString = '${m.config.name}?$paramsKey#$index';
      return MaterialPage(
        key: ValueKey(keyString),
        name: m.config.pattern,
        child: Builder(builder: (context) => m.config.builder(context, m.params)),
      );
    }).toList(),
  );

  Future<T?> navigateTo<T>(String location) async {
    for (final r in routes) {
      final params = matchPattern(r.pattern, location);
      if (params != null) {
        final match = RouteMatch(r, params);
        _stack.add(match);
        final completer = Completer<T?>();
        _resultCompleters[match] = completer;
        notifyListeners();
        return completer.future;
      }
    }

    // Default to home if route not found
    final home = routes.firstWhere((r) => r.pattern == '/', orElse: () => routes.first);
    final match = RouteMatch(home, {});
    _stack.add(match);
    final completer = Completer<T?>();
    _resultCompleters[match] = completer;
    notifyListeners();
    return completer.future;
  }

  Future<T?> navigateToObject<T>(String routeName, Map<String, dynamic> params) async {
    final destination = routes.firstWhere((r) => r.pattern == routeName, orElse: () => routes.first);
    final match = RouteMatch(destination, params);
    _stack.add(match);
    final completer = Completer<T?>();
    _resultCompleters[match] = completer;
    notifyListeners();
    return completer.future;
  }

  Future<void> replaceWithObject(String location, Map<String, dynamic> params) async {
    if (_stack.isNotEmpty) {
      _stack.removeLast();
    }
    await navigateToObject(location, params);
  }

  Future<void> replaceWith(String location) async {
    if (_stack.isNotEmpty) {
      _stack.removeLast();
    }
    await navigateTo(location);
  }

  void pop<T extends Object?>([T? result]) {
    if (canPop()) {
      final popped = _stack.removeLast();
      final completer = _resultCompleters.remove(popped);
      completer?.complete(result);
      notifyListeners();
    }
  }

  bool canPop() => _stack.length > 1;

  @override
  Future<bool> popRoute() async {
    if (canPop()) {
      _stack.removeLast();
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: _pages,
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        if (_stack.isNotEmpty) _stack.removeLast();
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(List<RouteMatch> configuration) async {
    _stack
      ..clear()
      ..addAll(configuration);
    notifyListeners();
  }

  @override
  List<RouteMatch> get currentConfiguration => List.unmodifiable(_stack);
}