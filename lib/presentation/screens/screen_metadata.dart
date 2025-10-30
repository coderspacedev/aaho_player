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
              return Padding(
                padding: EdgeInsets.all(context.scale(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CoderContainer(
                        decoration: BoxDecoration(
                          color: AppTheme.colors.card,
                          borderRadius: BorderRadius.circular(context.scale(12)),
                        ),
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
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: context.scale(12)),
                    Text(videoObject.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.headline5),
                    Text(videoObject.type ?? '', style: context.bodyMedium.copyWith(color: AppTheme.colors.accent)),
                    Text(metadata?.description ?? '', style: context.bodySmall.copyWith(color: AppTheme.colors.text.withAlpha(127))),
                    SizedBox(height: context.scale(12)),
                    CoderButton(
                      text: 'Play',
                      width: double.infinity,
                      radius: context.scale(24),
                      style: context.bodyBoldLarge.copyWith(color: AppTheme.colors.accentText),
                      icon: Icon(Icons.play_arrow_rounded, size: context.scale(24), color: AppTheme.colors.accentText),
                      onPressed: () {
                        context.navigateToObject(AppRoutes.player, {'source': metadata});
                      },
                    )
                  ],
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
