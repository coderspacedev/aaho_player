import 'package:aaho_player/models/home_object.dart';
import 'package:aaho_player/models/video_metadata.dart';

import '../presentation/screens/screen_dashboard.dart';
import '../presentation/screens/screen_metadata.dart';
import '../presentation/screens/screen_player.dart';
import 'app_router.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String metadata = '/metadata';
  static const String player = '/player';
}

final appRoutes = <RouteConfig>[
  RouteConfig(
    name: AppRoutes.dashboard,
    pattern: AppRoutes.dashboard,
    builder: (c, p) => const ScreenDashboard(),
  ),
  RouteConfig(
    name: AppRoutes.metadata,
    pattern: AppRoutes.metadata,
    builder: (context, params) {
      return ScreenMetadata(videoObject: params['source'] as VideoObject);
    },
  ),
  RouteConfig(
    name: AppRoutes.player,
    pattern: AppRoutes.player,
    builder: (context, params) {
      return ScreenPlayer(videoUrl:params['videoUrl'] as String);
    },
  ),
];
