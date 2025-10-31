import 'package:aaho_player/cubit/video_metadata_cubit.dart';
import 'package:aaho_player/cubit/video_metadata_state.dart';
import 'package:aaho_player/extensions/app_router_navigation.dart';
import 'package:aaho_player/extensions/video_metadata_helper.dart';
import 'package:aaho_player/models/home_object.dart';
import 'package:aaho_player/models/video_metadata.dart';
import 'package:aaho_player/presentation/widgets/coderx_annotated_region.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aaho_exports.dart';
import '../../navigation/routes.dart';

class ScreenMetadata extends StatelessWidget {
  final VideoObject videoObject;

  const ScreenMetadata({super.key, required this.videoObject});

  @override
  Widget build(BuildContext context) {
    return CoderXAnnotatedRegion(
      theme: StatusBarTheme.light,
      child: BlocProvider(
        create: (context) => VideoMetadataCubit()..fetchVideoMetadata(videoObject.identifier ?? ''),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: AppTheme.colors.primary,
          body: BlocBuilder<VideoMetadataCubit, VideoMetadataState>(
            builder: (context, state) {
              if (state is VideoMetadataLoading) {
                return Center(
                  child: SizedBox(
                    width: context.scale(24),
                    height: context.scale(24),
                    child: CircularProgressIndicator(color: AppTheme.colors.accent, strokeWidth: context.scale(4)),
                  ),
                );
              } else if (state is VideoMetadataLoaded) {
                final metadata = state.videoMetadata;
                final isSeries = (videoObject.type?.toLowerCase() == 'series');
                final seasons = videoObject.seasons ?? [];
                return Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 9 / 12,
                      child: CoderContainer(
                        decoration: BoxDecoration(color: AppTheme.colors.card, borderRadius: BorderRadius.circular(context.scale(0))),
                        child: Image.network(
                          (videoObject.thumbnail == null)
                              ? metadata?.thumbnailUrl ?? ''
                              : '${videoObject.thumbnailParentUrl}${videoObject.thumbnail}',
                          width: context.screenWidth,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(child: CircularProgressIndicator(strokeWidth: context.scale(2)));
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: AppTheme.colors.card,
                            child: Icon(Icons.broken_image, color: AppTheme.colors.cardText),
                          ),
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      padding: EdgeInsets.only(top: context.paddingTop + context.screenHeight * 0.44 + context.scale(16)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                        ),
                        padding: EdgeInsets.only(top: context.scale(16), left: context.scale(16), right: context.scale(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              videoObject.title ?? metadata?.title ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.baseTextStyle(20, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: context.scale(4)),
                            CoderContainer(
                              padding: EdgeInsets.symmetric(vertical: context.scale(4), horizontal: context.scale(8)),
                              radius: context.scale(4),
                              color: AppTheme.colors.accent,
                              child: Text(
                                videoObject.type ?? '',
                                style: context.baseTextStyle(12, fontWeight: FontWeight.w600, color: AppTheme.colors.accentText),
                              ),
                            ),
                            SizedBox(height: context.scale(8)),
                            if (metadata?.description.isNotEmpty ?? false)
                              Text(
                                metadata?.description ?? '',
                                style: context.caption.copyWith(color: AppTheme.colors.text.withAlpha(127), height: 1.5),
                              ),
                            SizedBox(height: context.scale(16)),

                            if (!isSeries)
                              Center(
                                child: CoderButton(
                                  text: 'Play'.toUpperCase(),
                                  width: context.screenWidth * 0.8,
                                  radius: context.scale(24),
                                  style: context.bodyBoldLarge.copyWith(color: AppTheme.colors.accentText),
                                  icon: Icon(Icons.play_arrow_rounded, size: context.scale(28), color: AppTheme.colors.accentText),
                                  onPressed: () {
                                    final mkvFiles = (metadata?.files ?? []).where((f) => f.name.toLowerCase().endsWith('.mkv')).toList();
                                    if (mkvFiles.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No video files found')));
                                      return;
                                    }

                                    final file = mkvFiles.first;
                                    final url = "https://archive.org/download/${videoObject.identifier}/${Uri.encodeComponent(file.name)}";

                                    context.navigateToObject(AppRoutes.player, {'videoUrl': url});
                                  },
                                ),
                              ),

                            if (isSeries && seasons.isNotEmpty) ...[
                              SizedBox(height: context.scale(12)),
                              Text("Episodes", style: context.baseTextStyle(16, fontWeight: FontWeight.w600)),
                              SizedBox(height: context.scale(4)),
                              for (final season in seasons) ...[
                                Text(
                                  season.seasonTitle ?? 'Season ${season.seasonNumber}',
                                  style: context.bodyBoldSmall.copyWith(color: AppTheme.colors.accent),
                                ),
                                SizedBox(height: context.scale(12)),
                                _buildEpisodes(context, season, metadata),
                                SizedBox(height: context.scale(12)),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black, Colors.black45, Colors.transparent, Colors.transparent, Colors.transparent, Colors.transparent],
                        ),
                      ),
                      child: CoderBar(
                        title: '',
                        isBack: true,
                        backgroundColor: Colors.transparent,
                        iconColor: Colors.white,
                        actions: [
                          Padding(
                            padding: EdgeInsets.only(right: context.scale(12)),
                            child: CoderButton(
                              text: 'Preview',
                              height: context.scale(24),
                              style: context.bodyBoldSmall.copyWith(color: Colors.white),
                              paddingH: context.scale(12),
                              backgroundColor: Colors.black38,
                              icon: Icon(Icons.remove_red_eye_rounded, color: Colors.white, size: context.scale(12)),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  _buildEpisodes(BuildContext context, SeasonObject season, VideoMetadata? metadata) {
    return Column(
      children: [
        for (int index = 0; index < (season.episodes?.length ?? 0); index++) ...[
          InkWell(
            onTap: () {
              final mkvFiles = (metadata?.files ?? []).where((f) => f.name.toLowerCase().endsWith('.mkv')).toList();
              if (mkvFiles.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No video files found')));
                return;
              }

              final file = index < mkvFiles.length ? mkvFiles[index] : mkvFiles.last;
              final url = "https://archive.org/download/${videoObject.identifier}/${Uri.encodeComponent(file.name)}";

              context.navigateToObject(AppRoutes.player, {'videoUrl': url});
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: context.scale(6)),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(context.scale(6)),
                    child: Image.network(
                      metadata?.thumbnailUrl ?? '',
                      width: context.scale(60),
                      height: context.scale(40),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: context.scale(60),
                        height: context.scale(40),
                        color: AppTheme.colors.card,
                        child: Icon(Icons.broken_image, color: AppTheme.colors.cardText, size: context.scale(16)),
                      ),
                    ),
                  ),
                  SizedBox(width: context.scale(8)),
                  Expanded(
                    child: Text(season.episodes![index].title ?? 'Episode ${index + 1}', style: context.bodyLarge, overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(width: context.scale(8)),
                  Icon(Icons.play_circle_outline, color: AppTheme.colors.accent),
                ],
              ),
            ),
          ),
          if (index != (season.episodes!.length - 1))
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.scale(4)),
              child: Divider(color: AppTheme.colors.cardText.withAlpha(50), thickness: 0.6, height: context.scale(8)),
            ),
        ],
      ],
    );
  }
}
