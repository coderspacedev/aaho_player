import 'package:aaho_player/models/video_metadata.dart';
import 'package:coderspace_network/coderspace_network.dart';

import '../aaho_exports.dart';

class ApiService {
  static String baseUrl = 'https://archive.org';

  Future<VideoMetadata?> fetchMetadata(String identifier) async {
    final client = CoderClient(
      baseUrl: baseUrl,
      timeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    final result = await client.get<VideoMetadata>(
      '/metadata/$identifier',
      parser: (data) => VideoMetadata.fromJson(data),
    );
    if (result.isSuccess) {
      final data = result.data;
      return data;
    } else {
      debugPrint('❌ Failed: ${result.error}');
      return null;
    }
  }
}
