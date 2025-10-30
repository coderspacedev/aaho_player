import 'package:aaho_player/extensions/video_metadata_helper.dart';

import '../../aaho_exports.dart';
import '../../models/video_metadata.dart';
import '../widgets/advanced_video_player.dart';

class ScreenPlayer extends StatelessWidget {
  final VideoMetadata metadata;

  const ScreenPlayer({super.key, required this.metadata});

  @override
  Widget build(BuildContext context) {
    return AdvancedVideoPlayer(videoUrl: /*metadata.videoUrl??*/'https://archive.org/download/s-01-jamnapaar-720p-by-aaho/EP.1.2.3.4.5.Jamnapaar.S01.720p%20by%20Aaho.mkv');
  }
}
