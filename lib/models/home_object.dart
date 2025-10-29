class HomeObject {
  String? id;
  String? categoryTitle;
  List<VideoObject>? items;

  HomeObject({
    this.id,
    this.categoryTitle,
    this.items,
  });

  HomeObject copyWith({
    String? id,
    String? categoryTitle,
    List<VideoObject>? items,
  }) {
    return HomeObject(
      id: id ?? this.id,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      items: items ?? this.items,
    );
  }

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

  VideoObject({
    this.identifier,
    this.title,
    this.type,
  });

  VideoObject copyWith({
    String? identifier,
    String? title,
    String? type,
  }) {
    return VideoObject(
      identifier: identifier ?? this.identifier,
      title: title ?? this.title,
      type: type ?? this.type,
    );
  }

  factory VideoObject.fromJson(Map<String, dynamic> json) {
    return VideoObject(
      identifier: json['identifier'],
      title: json['title'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() => {
    'identifier': identifier,
    'title': title,
    'type': type,
  };

  String get thumbnailUrl =>
      "https://archive.org/download/$identifier/__ia_thumb.jpg";
}
