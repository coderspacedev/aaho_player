import '../presentation/screens/screen_player.dart';
import 'app_router.dart';

class AppRoutes {
  static const String player = '/';
  // static const String player = '/player';
}

final appRoutes = <RouteConfig>[
  RouteConfig(name: AppRoutes.player, pattern: AppRoutes.player, builder: (c, p) => const ScreenPlayer()),
];
