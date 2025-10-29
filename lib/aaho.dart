
import 'aaho_exports.dart';
import 'navigation/app_router.dart';
import 'navigation/routes.dart';

var routerDelegate = AppRouterDelegate(routes: appRoutes);
var routeInformationParser = AppRouteInformationParser(appRoutes);

class Aaho extends StatelessWidget {
  const Aaho({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Aaho',
      debugShowCheckedModeBanner: true,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppTheme.colors.background,
        canvasColor: AppTheme.colors.background,
        cardColor: AppTheme.colors.card,
        primaryColor: AppTheme.colors.primary,
        useMaterial3: true,
        appBarTheme: AppBarTheme(backgroundColor: AppTheme.colors.background, foregroundColor: AppTheme.colors.text, centerTitle: false),
      ),
      themeMode: ThemeMode.light,
      routerDelegate: routerDelegate,
      routeInformationParser: routeInformationParser,
    );
  }
}
