import 'dart:async';
import 'dart:math' as math;

import 'package:aaho_player/aaho_exports.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class AdvancedVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const AdvancedVideoPlayer({super.key, required this.videoUrl});

  @override
  State<AdvancedVideoPlayer> createState() => _AdvancedVideoPlayerState();
}

class _AdvancedVideoPlayerState extends State<AdvancedVideoPlayer> {
  late final Player _player;
  late final VideoController _controller;
  bool _showControls = true;
  bool _isFullscreen = false;
  Timer? _hideTimer;
  bool _isDragging = false;
  bool _isBrightnessDrag = false;
  double _volume = 1.0;
  double _brightness = 1.0;
  Offset _dragStartPosition = Offset.zero;
  Duration _totalDuration = Duration.zero;
  bool _isBuffering = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _initializePlayer();
    _startHideTimer(0);
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _isBuffering = true;
      _isInitialized = false;
    });
    await _player.open(Media(widget.videoUrl));
    await _player.setVolume(_volume * 100);
    _player.stream.duration.listen((d) {
      if (mounted && d != Duration.zero) {
        setState(() {
          _totalDuration = d;
          _isInitialized = true;
          _isBuffering = false;
        });
      }
    });
    _player.stream.buffering.listen((isBuffering) {
      if (mounted) setState(() => _isBuffering = isBuffering);
    });
    await _player.play();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() {});
    });
  }

  void _startHideTimer([int? seconds]) {
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(seconds: seconds ?? 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _showAndHideControls() {
    setState(() => _showControls = true);
    _startHideTimer();
  }

  void _toggleFullscreen() async {
    print('_toggleFullscreen');
    setState(() => _isFullscreen = !_isFullscreen);

    if (_isFullscreen) {
      // Switch to landscape + hide system UI
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // Return to portrait + restore UI overlays
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      // Add a short delay before restoring overlays to ensure proper rebuild
      await Future.delayed(const Duration(milliseconds: 300));
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _handleDoubleTapDown(TapDownDetails details) async {
    final screenSize = MediaQuery.of(context).size;
    final x = details.localPosition.dx;
    _showAndHideControls();

    final pos = _player.state.position;
    final dur = _player.state.duration;

    if (x < screenSize.width / 3) {
      _player.seek(pos - const Duration(seconds: 10));
    } else if (x > 2 * screenSize.width / 3) {
      _player.seek(pos + const Duration(seconds: 10));
    } else {
      final playing = _player.state.playing;
      playing ? _player.pause() : _player.play();
    }
  }

  Orientation _getOrientation() {
    final size = MediaQuery.of(context).size;
    return size.width > size.height
        ? Orientation.landscape
        : Orientation.portrait;
  }

  void _handleVerticalDragStart(DragStartDetails details) {
    _dragStartPosition = details.globalPosition;
    final orientation = _getOrientation();
    final halfWidth = MediaQuery.of(context).size.width / 2;
    _isBrightnessDrag = details.globalPosition.dx < halfWidth;
    setState(() {
      _isDragging = true;
      _showControls = true;
    });
    _startHideTimer(5);
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) async {
    final delta = details.delta.dy / MediaQuery.of(context).size.height;
    if (_isBrightnessDrag) {
      setState(() => _brightness = (_brightness - delta).clamp(0.0, 1.0));
    } else {
      setState(() => _volume = (_volume - delta).clamp(0.0, 1.0));
      _player.setVolume((_volume * 100).clamp(0, 100));
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    setState(() => _isDragging = false);
    _startHideTimer();
  }

  double _getOverlayLeft() {
    final screenWidth = MediaQuery.of(context).size.width;
    return _isBrightnessDrag ? 20.0 : screenWidth - 100.0;
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _player.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = _getOrientation();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          IgnorePointer(
            ignoring: _showControls,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (_showControls) {
                  _startHideTimer();
                } else {
                  _showAndHideControls();
                }
              },
              onDoubleTapDown: _handleDoubleTapDown,
              onVerticalDragStart: _handleVerticalDragStart,
              onVerticalDragUpdate: _handleVerticalDragUpdate,
              onVerticalDragEnd: _handleVerticalDragEnd,
              child: Center(
                child: Video(
                  controller: _controller,
                  fit: BoxFit.contain,
                  controls: NoVideoControls,
                ),
              ),
            ),
          ),

          if (_isInitialized &&
              _showControls &&
              orientation == Orientation.portrait)
            _buildCenterControls(),
          if (_isInitialized && _showControls && _isDragging)
            Positioned(
              left: _getOverlayLeft(),
              top: math.max(_dragStartPosition.dy - 40, 0),
              child: _buildDragOverlay(),
            ),

          if (_isInitialized && _showControls) _buildBottomControls(),
          if (_isInitialized && _showControls)
            _buildTopBar(context, orientation),

          if (_isBuffering || !_isInitialized)
            const Center(
              child: SizedBox(
                width: 104,
                height: 104,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, Orientation orientation) {
    return Container(
      // height: orientation == Orientation.portrait ? 56 : 40,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: orientation == Orientation.portrait ? 16 : 8,
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            if (orientation == Orientation.portrait)
              Text(
                'Video Player',
                style: context.bodyBoldLarge.copyWith(color: Colors.white),
              ),
            IconButton(
              icon: Icon(
                _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                color: Colors.white,
              ),
              onPressed: _toggleFullscreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterControls() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _iconButton(Icons.replay_10, () async {
            final pos = await _player.state.position;
            _player.seek(pos - const Duration(seconds: 10));
          }),
          const SizedBox(width: 40),
          StreamBuilder<bool>(
            stream: _player.stream.playing,
            builder: (context, snapshot) {
              // fall back to current state if no event yet
              final playing = snapshot.data ?? _player.state.playing;
              return GestureDetector(
                onTap: () => playing ? _player.pause() : _player.play(),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  child: Icon(
                    playing ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 40),
          _iconButton(Icons.forward_10, () async {
            final pos = _player.state.position;
            _player.seek(pos + const Duration(seconds: 10));
          }),
        ],
      ),
    );
  }

  Widget _buildDragOverlay() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isBrightnessDrag ? Icons.brightness_medium : Icons.volume_up,
            color: Colors.white,
            size: 24,
          ),
          Text(
            '${((_isBrightnessDrag ? _brightness : _volume) * 100).round()}%',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: StreamBuilder<Duration>(
        stream: _player.stream.position,
        builder: (context, snapshot) {
          final duration = _totalDuration;
          final max = duration.inSeconds > 0
              ? duration.inSeconds.toDouble()
              : 1.0;
          final livePosition = snapshot.data ?? _player.state.position;
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withAlpha(175)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: livePosition.inSeconds.toDouble().clamp(0, max),
                  max: max,
                  onChanged: (v) {
                    _player.seek(Duration(seconds: v.toInt()));
                  },
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(livePosition),
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 32),
      onPressed: () {
        _showAndHideControls();
        onTap();
      },
    );
  }
}
