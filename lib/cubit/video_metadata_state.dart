import 'package:aaho_player/models/video_metadata.dart';
import 'package:equatable/equatable.dart';

sealed class VideoMetadataState extends Equatable {
  const VideoMetadataState();

  @override
  List<Object?> get props => [];
}

class VideoMetadataLoading extends VideoMetadataState {}

class VideoMetadataLoaded extends VideoMetadataState {
  final VideoMetadata? videoMetadata;

  const VideoMetadataLoaded(this.videoMetadata);

  @override
  List<Object?> get props => [videoMetadata];
}

class VideoMetadataEmpty extends VideoMetadataState {}

class VideoMetadataError extends VideoMetadataState {
  final String message;

  const VideoMetadataError(this.message);

  @override
  List<Object?> get props => [message];
}