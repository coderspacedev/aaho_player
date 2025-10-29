import 'dart:async';
import 'dart:math' as math;

import 'package:aaho_player/aaho_exports.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class AdvancedVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const AdvancedVideoPlayer({super.key, required this.videoUrl});

  @override
  State<AdvancedVideoPlayer> createState() => _AdvancedVideoPlayerState();
}

class _AdvancedVideoPlayerState extends State<AdvancedVideoPlayer> {
  late VideoPlayerController _controller;
  VoidCallback? _playerListener;

  bool _showControls = true;
  bool _isFullscreen = false;
  Timer? _hideTimer;

  double _volume = 1.0;
  double _brightness =
      1.0; // 0.0 to 1.0, actual system control requires a package like hardware_brightness
  bool _isDragging = false;
  bool _isBrightnessDrag = false;
  Offset _dragStartPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _startHideTimer();
    _showControls = true;
    _startHideTimer(0);
  }

  Future<void> _initializePlayer() async {
    // final videoUrl = 'https://www.googleapis.com/drive/v3/files/${widget.fileId}?alt=media&key=AIzaSyBkFT8hgzdDb0Nd7RHDRk9IMUWypfJTifE';
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _controller.initialize();
    await _controller.setVolume(_volume);
    await _controller.play();
    // Add listener for real-time updates (position, playback state, etc.)
    _playerListener = () {
      if (mounted) {
        setState(() {});
      }
    };
    _controller.addListener(_playerListener!);

    setState(() {});
  }

  void _startHideTimer([int? seconds]) {
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(seconds: seconds ?? 3), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _showAndHideControls() {
    setState(() => _showControls = true);
    _startHideTimer();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    if (_isFullscreen) {
      // Fullscreen: lock to landscape
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      // Exit fullscreen: allow portrait (or all if preferred)
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    final screenSize = MediaQuery.of(context).size;
    final x = details.localPosition.dx;

    _showAndHideControls();

    if (x < screenSize.width / 3) {
      // Left side: seek backward
      final position = _controller.value.position;
      final newPosition = position - const Duration(seconds: 10);
      _controller.seekTo(
        newPosition > Duration.zero ? newPosition : Duration.zero,
      );
    } else if (x > 2 * screenSize.width / 3) {
      // Right side: seek forward
      final position = _controller.value.position;
      final duration = _controller.value.duration;
      final newPosition = position + const Duration(seconds: 10);
      _controller.seekTo(newPosition < duration ? newPosition : duration);
    } else {
      // Center: play/pause
      setState(() {
        _controller.value.isPlaying ? _controller.pause() : _controller.play();
      });
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
    final halfDimension = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height / 2
        : MediaQuery.of(context).size.width / 2;
    final position = orientation == Orientation.portrait
        ? details.globalPosition.dy
        : details.globalPosition.dx;
    _isBrightnessDrag = position < halfDimension;
    setState(() {
      _isDragging = true;
      _showControls = true;
    });
    _startHideTimer(5); // Longer timer during drag
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    final delta =
        details.delta.dy /
        MediaQuery.of(
          context,
        ).size.height; // Normalize, but since vertical, use dy
    setState(() {
      if (_isBrightnessDrag) {
        _brightness = (_brightness - delta).clamp(0.0, 1.0);
        // TODO: Implement system brightness control, e.g., using hardware_brightness package:
        // await HardwareBrightness.setBrightness(_brightness);
      } else {
        _volume = (_volume - delta).clamp(0.0, 1.0);
        _controller.setVolume(_volume);
      }
      _isDragging = true;
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    setState(() => _isDragging = false);
    _startHideTimer();
  }

  double _getOverlayLeft() {
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = _getOrientation();
    final startX = _dragStartPosition.dx;
    if (orientation == Orientation.portrait) {
      return _isBrightnessDrag ? 20.0 : screenWidth - 100.0;
    } else {
      // In landscape, left for brightness, right for volume
      return _isBrightnessDrag ? 20.0 : screenWidth - 100.0;
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.removeListener(_playerListener!);
    _controller.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = _getOrientation();
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller.value.isInitialized
          ? Stack(
              children: [
                GestureDetector(
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
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),
                ),

                // Top bar (former AppBar)
                if (_showControls)
                  IgnorePointer(
                    ignoring: false,
                    child: _buildTopBar(context, orientation),
                  ),
                // Centered play/pause button and seek buttons
                if (_showControls && orientation == Orientation.portrait)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            _showAndHideControls();
                            final position = _controller.value.position;
                            final newPosition =
                                position - const Duration(seconds: 10);
                            _controller.seekTo(
                              newPosition > Duration.zero
                                  ? newPosition
                                  : Duration.zero,
                            );
                          },
                          icon: const Icon(
                            Icons.replay_10,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.1,
                        ),
                        GestureDetector(
                          onTap: () {
                            _showAndHideControls();
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.5),
                            ),
                            child: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.1,
                        ),
                        IconButton(
                          onPressed: () {
                            _showAndHideControls();
                            final position = _controller.value.position;
                            final duration = _controller.value.duration;
                            final newPosition =
                                position + const Duration(seconds: 10);
                            _controller.seekTo(
                              newPosition < duration ? newPosition : duration,
                            );
                          },
                          icon: const Icon(
                            Icons.forward_10,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Drag overlay (visual feedback for volume/brightness)
                if (_showControls && _isDragging)
                  Positioned(
                    left: _getOverlayLeft(),
                    top: math.max(_dragStartPosition.dy - 40, 0),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isBrightnessDrag
                                ? Icons.brightness_medium
                                : Icons.volume_up,
                            color: Colors.white,
                            size: 24,
                          ),
                          Text(
                            '${(_isBrightnessDrag ? _brightness : _volume) * 100.round()}%',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Bottom controls overlay
                if (_showControls)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                      padding: EdgeInsets.all(
                        orientation == Orientation.portrait ? 20.0 : 12.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: VideoProgressIndicator(
                              _controller,
                              allowScrubbing: true,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          SizedBox(
                            height: orientation == Orientation.portrait
                                ? 10.0
                                : 6.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_controller.value.position),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const Spacer(),
                              Text(
                                _formatDuration(_controller.value.duration),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            )
          : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  Widget _buildTopBar(BuildContext context, Orientation orientation) {
    return Container(
      height: orientation == Orientation.portrait ? 56.0 : 40.0,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: orientation == Orientation.portrait ? 16.0 : 8.0,
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
            if (orientation == Orientation.portrait)
              const Text('Video Player', style: TextStyle(color: Colors.white)),
            IconButton(
              icon: Icon(
                _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                color: Colors.white,
                size: 24,
              ),
              onPressed: _toggleFullscreen,
            ),
          ],
        ),
      ),
    );
  }
}
