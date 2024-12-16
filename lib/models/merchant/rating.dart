class Rating {
  final double averageRating;
  final int count;
  final List feedbacks;

  Rating({
    required this.averageRating,
    required this.count,
    required this.feedbacks,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    print(json);
    return Rating(
      averageRating: json['average_rating'].toDouble(),
      count: json['count'],
      feedbacks: json['feedbacks'],
    );
  }

  Map<String, dynamic> toJson() => {
        'average_rating': averageRating,
        'count': count,
        'feedbacks': feedbacks,
      };
}
