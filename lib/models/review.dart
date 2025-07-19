import 'user.dart';
import 'review_image.dart';

class Review {
  final int id;
  final int productId;
  final int userId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  final User? user;
  final List<ReviewImage>? images;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.user,
    this.images,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      productId: json['productId'],
      userId: json['userId'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      images:
          json['images'] != null
              ? List<ReviewImage>.from(
                json['images'].map((img) => ReviewImage.fromJson(img)),
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'userId': userId,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
    'user': user?.toJson(),
    'images': images?.map((img) => img.toJson()).toList(),
  };
}
