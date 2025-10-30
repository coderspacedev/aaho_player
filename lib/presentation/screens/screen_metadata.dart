import 'package:aaho_player/cubit/video_metadata_cubit.dart';
import 'package:aaho_player/cubit/video_metadata_state.dart';
import 'package:aaho_player/extensions/app_router_navigation.dart';
import 'package:aaho_player/extensions/video_metadata_helper.dart';
import 'package:aaho_player/models/home_object.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aaho_exports.dart';
import '../../navigation/routes.dart';

class ScreenMetadata extends StatelessWidget {
  final VideoObject videoObject;

  const ScreenMetadata({super.key, required this.videoObject});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoMetadataCubit()..fetchVideoMetadata(videoObject.identifier ?? ''),
      child: Scaffold(
        appBar: CoderBar(title: 'Aaho', isBack: true),
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

              return Padding(
                padding: EdgeInsets.all(context.scale(16)),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CoderContainer(
                          decoration: BoxDecoration(color: AppTheme.colors.card, borderRadius: BorderRadius.circular(context.scale(12))),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(context.scale(12)),
                                child: Image.network(
                                  metadata?.thumbnailUrl ?? '',
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
                              Positioned(
                                right: context.scale(8),
                                bottom: context.scale(8),
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
                      ),

                      SizedBox(height: context.scale(12)),
                      Text(metadata?.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.headline5),
                      Text(videoObject.type ?? '', style: context.bodyMedium.copyWith(color: AppTheme.colors.accent)),
                      if (metadata?.description.isNotEmpty ?? false)
                        Text(metadata?.description ?? '', style: context.bodySmall.copyWith(color: AppTheme.colors.text.withAlpha(127))),
                      SizedBox(height: context.scale(12)),

                      if (!isSeries)
                        CoderButton(
                          text: 'Play',
                          width: double.infinity,
                          radius: context.scale(24),
                          style: context.bodyBoldLarge.copyWith(color: AppTheme.colors.accentText),
                          icon: Icon(Icons.play_arrow_rounded, size: context.scale(24), color: AppTheme.colors.accentText),
                          onPressed: () {
                            final videoUrl = metadata?.videoUrl;
                            if (videoUrl != null) {
                              context.navigateToObject(AppRoutes.player, {'videoUrl': videoUrl});
                            }
                          },
                        ),

                      if (isSeries && seasons.isNotEmpty) ...[
                        SizedBox(height: context.scale(12)),
                        Text("Episodes", style: context.headline5),
                        SizedBox(height: context.scale(8)),

                        for (final season in seasons) ...[
                          Text(
                            season.seasonTitle ?? 'Season ${season.seasonNumber}',
                            style: context.bodyBoldMedium.copyWith(color: AppTheme.colors.accent),
                          ),
                          SizedBox(height: context.scale(8)),

                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: season.episodes?.length ?? 0,
                            separatorBuilder: (_, __) => Padding(
                              padding: EdgeInsets.symmetric(vertical: context.scale(4)),
                              child: Divider(
                                color: AppTheme.colors.cardText.withAlpha(50),
                                thickness: 0.6,
                                height: context.scale(8),
                              ),
                            ),
                            itemBuilder: (context, index) {
                              final episode = season.episodes![index];
                              final mkvFiles = (metadata?.files ?? []).where((f) => f.name.toLowerCase().endsWith('.mkv')).toList();

                              return InkWell(
                                onTap: () {
                                  if (mkvFiles.isEmpty) {
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    final snackBar = SnackBar(content: Text('No video files found'), backgroundColor: Colors.black54);
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Container(
                                              width: context.scale(60),
                                              height: context.scale(40),
                                              alignment: Alignment.center,
                                              child: SizedBox(
                                                width: context.scale(16),
                                                height: context.scale(16),
                                                child: CircularProgressIndicator(strokeWidth: context.scale(2)),
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      SizedBox(width: context.scale(8)),
                                      Expanded(
                                        child: Text(
                                          episode.title ?? 'Episode ${index + 1}',
                                          style: context.bodyLarge,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      SizedBox(width: context.scale(8)),
                                      Icon(Icons.play_circle_outline, color: AppTheme.colors.accent),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: context.scale(12)),
                        ],
                      ],
                    ],
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
