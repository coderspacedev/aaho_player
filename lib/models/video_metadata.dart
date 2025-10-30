class VideoMetadata {
  final String identifier;
  final String title;
  final String description;
  final String creator;
  final String server;
  final String dir;
  final List<FileItem> files;

  VideoMetadata({
    required this.identifier,
    required this.title,
    required this.description,
    required this.creator,
    required this.server,
    required this.dir,
    required this.files,
  });

  factory VideoMetadata.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] ?? {};
    final filesList = (json['files'] as List?) ?? [];

    final filteredFiles = filesList
        .where((f) {
      final name = f['name']?.toString().toLowerCase() ?? '';
      return name.endsWith('.mkv') ||name.endsWith('.mp4') || name.endsWith('.jpg');
    })
        .map((f) => FileItem.fromJson(f, json['server'], json['dir']))
        .toList();

    return VideoMetadata(
      identifier: metadata['identifier'] ?? '',
      title: metadata['title'] ?? '',
      description: metadata['description'] ?? '',
      creator: metadata['creator'] ?? '',
      server: json['server'] ?? '',
      dir: json['dir'] ?? '',
      files: filteredFiles,
    );
  }
}

class FileItem {
  final String name;
  final String format;
  final String size;
  final String? length;
  final String? width;
  final String? height;
  final String url;

  FileItem({
    required this.name,
    required this.format,
    required this.size,
    this.length,
    this.width,
    this.height,
    required this.url,
  });

  factory FileItem.fromJson(Map<String, dynamic> json, String server, String dir) {
    final name = json['name'] ?? '';
    final url = 'https://$server$dir/$name';
    return FileItem(
      name: name,
      format: json['format'] ?? '',
      size: json['size'] ?? '0',
      length: json['length']?.toString(),
      width: json['width']?.toString(),
      height: json['height']?.toString(),
      url: url,
    );
  }
}
