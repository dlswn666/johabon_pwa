class BannerModel {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final String linkType; // 'notice', 'qna', 'share', 'company', 'external'
  final String linkId;
  final String? externalUrl;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.linkType,
    required this.linkId,
    this.externalUrl,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      imageUrl: json['imageUrl'],
      title: json['title'],
      description: json['description'],
      linkType: json['linkType'],
      linkId: json['linkId'],
      externalUrl: json['externalUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'linkType': linkType,
      'linkId': linkId,
      'externalUrl': externalUrl,
    };
  }
} 