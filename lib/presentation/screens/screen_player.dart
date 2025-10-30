import 'package:aaho_player/extensions/video_metadata_helper.dart';

import '../../aaho_exports.dart';
import '../../models/video_metadata.dart';
import '../widgets/advanced_video_player.dart';

class ScreenPlayer extends StatelessWidget {
  final String videoUrl;

  const ScreenPlayer({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return AdvancedVideoPlayer(videoUrl: videoUrl ?? '');
  }
}
