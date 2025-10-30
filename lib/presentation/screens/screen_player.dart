import '../../aaho_exports.dart';
import '../widgets/advanced_video_player.dart';

class ScreenPlayer extends StatelessWidget {
  final String videoUrl;

  const ScreenPlayer({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return AdvancedVideoPlayer(videoUrl: videoUrl ?? '');
  }
}
