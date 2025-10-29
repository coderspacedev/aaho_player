import '../models/video_metadata.dart';

extension VideoMetadataHelper on VideoMetadata {
  /// Returns the first .mp4 file URL (main video)
  String? get videoUrl {
    try {
      return files.firstWhere((f) => f.name.toLowerCase().endsWith('.mp4')).url;
    } catch (_) {
      return null;
    }
  }

  /// Returns the first .jpg file URL (thumbnail)
  String? get thumbnailUrl {
    try {
      return files.firstWhere((f) => f.name.toLowerCase().endsWith('.jpg')).url;
    } catch (_) {
      return null;
    }
  }

  /// Returns all thumbnails (.jpg files)
  List<String> get allThumbnails => files
      .where((f) => f.name.toLowerCase().endsWith('.jpg'))
      .map((f) => f.url)
      .toList();

  /// Returns all video files (.mp4)
  List<String> get allVideos => files
      .where((f) => f.name.toLowerCase().endsWith('.mp4'))
      .map((f) => f.url)
      .toList();
}
