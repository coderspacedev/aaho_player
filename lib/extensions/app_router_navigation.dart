import '../aaho_exports.dart';
import '../navigation/app_router.dart';

extension AppRouterNavigation on BuildContext {
  Future<T?> navigateTo<T>(String location) async {
    final router = Router.of(this).routerDelegate;
    if (router is AppRouterDelegate) {
      return router.navigateTo<T>(location);
    }
    return null;
  }

  /// Navigate with parameters and wait for a result
  Future<T?> navigateToObject<T>(String routeName, Map<String, dynamic> params) async {
    final router = Router.of(this).routerDelegate;
    if (router is AppRouterDelegate) {
      return router.navigateToObject<T>(routeName, params);
    }
    return null;
  }

  Future<void> replaceWithObject(String location, Map<String, dynamic> params) async {
    final router = Router.of(this).routerDelegate;
    if (router is AppRouterDelegate) {
      await router.replaceWithObject(location, params);
    }
  }

  Future<void> replaceWith(String location) async {
    final router = Router.of(this).routerDelegate;
    if (router is AppRouterDelegate) {
      await router.replaceWith(location);
    }
  }

  void back() {
    final router = Router.of(this).routerDelegate;
    if (router is AppRouterDelegate) {
      router.pop();
    }
  }

  void backWithResult<T>([T? result]) {
    final router = Router.of(this).routerDelegate;
    if (router is AppRouterDelegate) {
      router.pop(result);
    }
  }

  bool canPop() {
    final router = Router.of(this).routerDelegate;
    if (router is AppRouterDelegate) {
      return router.canPop();
    }
    return false;
  }
}