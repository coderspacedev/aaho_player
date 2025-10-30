import 'package:aaho_player/extensions/app_router_navigation.dart';
import 'package:aaho_player/models/home_object.dart';
import 'package:aaho_player/navigation/routes.dart';

import '../../aaho_exports.dart';
import '../../data/json_parser.dart';

class ScreenDashboard extends StatefulWidget {
  const ScreenDashboard({super.key});

  @override
  State<ScreenDashboard> createState() => _ScreenDashboardState();
}

class _ScreenDashboardState extends State<ScreenDashboard> {
  late Future<List<HomeObject>> _moviesFuture;

  @override
  void initState() {
    super.initState();
    _moviesFuture = JsonParser().loadMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: CoderBar(title: 'Aaho'),
      body: FutureBuilder<List<HomeObject>>(
        future: _moviesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: SizedBox(
                width: context.scale(24),
                height: context.scale(24),
                child: CircularProgressIndicator(
                  color: AppTheme.colors.accent,
                  strokeWidth: context.scale(4),
                ),
              ),
            );
          }

          final categories = snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: context.scale(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(categories.length, (index) {
                final homeCategory = categories[index];
                return _buildCategory(context, homeCategory);
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategory(BuildContext context, HomeObject category) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.scale(12)),
            child: Text(
              category.categoryTitle ?? '',
              style: context.bodyBoldExtraLarge,
            ),
          ),
          SizedBox(height: context.scale(12)),
          SizedBox(
            height: context.screenWidth * 0.44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: category.items?.length ?? 0,
              padding: EdgeInsets.symmetric(horizontal: context.scale(12)),
              separatorBuilder: (_, __) => SizedBox(width: context.scale(12)),
              itemBuilder: (context, index) {
                final movie = category.items?[index];
                return GestureDetector(
                  onTap: () {
                    context.navigateToObject(AppRoutes.metadata, {
                      'source': movie,
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(context.scale(12)),
                        child: Container(
                          width: context.screenWidth * 0.25,
                          height: context.screenWidth * 0.35,
                          color: AppTheme.colors.card,
                          child: Image.network(
                            (movie?.thumbnail == null)
                                ? movie?.thumbnailUrl ?? ''
                                : '${movie?.thumbnailParentUrl}${movie?.thumbnail}',
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: context.scale(2),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: AppTheme.colors.card,
                              child: Icon(
                                Icons.broken_image,
                                color: AppTheme.colors.cardText,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: context.scale(8)),
                      SizedBox(
                        width: context.screenWidth * 0.25,
                        child: Text(
                          movie?.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.caption,
                        ),
                      ),
                      Text(
                        movie?.type ?? '',
                        style: context.caption.copyWith(
                          color: AppTheme.colors.accent,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
