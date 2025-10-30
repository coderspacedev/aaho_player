class HomeObject {
  String? id;
  String? categoryTitle;
  List<VideoObject>? items;

  HomeObject({
    this.id,
    this.categoryTitle,
    this.items,
  });

  factory HomeObject.fromJson(Map<String, dynamic> json) {
    return HomeObject(
      id: json['id'],
      categoryTitle: json['category_title'],
      items: (json['items'] as List?)
          ?.map((e) => VideoObject.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category_title': categoryTitle,
    'items': items?.map((e) => e.toJson()).toList(),
  };
}

class VideoObject {
  String? identifier;
  String? title;
  String? type;
  List<SeasonObject>? seasons;

  VideoObject({
    this.identifier,
    this.title,
    this.type,
    this.seasons,
  });

  factory VideoObject.fromJson(Map<String, dynamic> json) {
    return VideoObject(
      identifier: json['identifier'],
      title: json['title'],
      type: json['type'],
      seasons: (json['seasons'] as List?)
          ?.map((e) => SeasonObject.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'identifier': identifier,
    'title': title,
    'type': type,
    'seasons': seasons?.map((e) => e.toJson()).toList(),
  };

  String get thumbnailUrl =>
      "https://archive.org/download/$identifier/__ia_thumb.jpg";
  String? get videoUrl {
    if (type?.toLowerCase() == "movie" && identifier != null && title != null) {
      return "https://archive.org/download/$identifier/${title?.replaceAll(' ', '%20')}.mkv";
    }
    return null;
  }
}

class SeasonObject {
  int? seasonNumber;
  String? seasonTitle;
  List<EpisodeObject>? episodes;

  SeasonObject({
    this.seasonNumber,
    this.seasonTitle,
    this.episodes,
  });

  factory SeasonObject.fromJson(Map<String, dynamic> json) {
    return SeasonObject(
      seasonNumber: json['season_number'],
      seasonTitle: json['season_title'],
      episodes: (json['episodes'] as List?)
          ?.map((e) => EpisodeObject.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'season_number': seasonNumber,
    'season_title': seasonTitle,
    'episodes': episodes?.map((e) => e.toJson()).toList(),
  };
}

class EpisodeObject {
  int? episodeNumber;
  String? title;
  String? identifier;

  EpisodeObject({
    this.episodeNumber,
    this.title,
    this.identifier,
  });

  factory EpisodeObject.fromJson(Map<String, dynamic> json) {
    return EpisodeObject(
      episodeNumber: json['episode_number'],
      title: json['title'],
      identifier: json['identifier'],
    );
  }

  Map<String, dynamic> toJson() => {
    'episode_number': episodeNumber,
    'title': title,
    'identifier': identifier,
  };

  String get videoUrl =>
      "https://archive.org/download/$identifier/${title?.replaceAll(' ', '%20')}.mkv";
}
