import '../../aaho_exports.dart';
import '../widgets/advanced_video_player.dart';

class ScreenPlayer extends StatefulWidget {
  const ScreenPlayer({super.key});

  @override
  State<ScreenPlayer> createState() => _ScreenPlayerState();
}

class _ScreenPlayerState extends State<ScreenPlayer> {
  @override
  Widget build(BuildContext context) {
    return AdvancedVideoPlayer(fileId: '12SpM1M3m1ZhZ6PwInv4Hhy9aIHJMiiuP');
  }
}
