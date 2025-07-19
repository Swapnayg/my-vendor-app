class ReviewImage {
  final int id;
  final int reviewId;
  final String url;

  ReviewImage({required this.id, required this.reviewId, required this.url});

  factory ReviewImage.fromJson(Map<String, dynamic> json) {
    return ReviewImage(
      id: json['id'],
      reviewId: json['reviewId'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'reviewId': reviewId, 'url': url};
}
