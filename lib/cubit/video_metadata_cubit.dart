import 'package:aaho_player/cubit/video_metadata_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/api_service.dart';

class VideoMetadataCubit extends Cubit<VideoMetadataState> {
  VideoMetadataCubit() : super(VideoMetadataLoading());

  Future<void> fetchVideoMetadata(String identifier) async {
    emit(VideoMetadataLoading());
    try {
      final result = await ApiService().fetchMetadata(identifier);
      if (result == null) {
        emit(VideoMetadataEmpty());
      } else {
        emit(VideoMetadataLoaded(result));
      }
    } catch (e) {
      emit(VideoMetadataError(e.toString()));
    }
  }
}