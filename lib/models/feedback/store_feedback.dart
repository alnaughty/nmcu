import 'package:nomnom/models/feedback/customer_feedback.dart';

class StoreFeedback {
  final int count;
  final double averageRating;
  final List<CustomerFeedback> feedbacks;
  StoreFeedback(
      {required this.averageRating,
      required this.count,
      required this.feedbacks});

  factory StoreFeedback.fromJson(Map<String, dynamic> json) {
    final List f = json['feedbacks'] ?? [];
    final List<CustomerFeedback> feedbacks =
        f.map((e) => CustomerFeedback.fromJson(e)).toList();
    print(feedbacks);
    final int _count = json['count'];
    final double ave = double.parse(
      json['average_rating'].toString(),
    );

    final res = StoreFeedback(
      averageRating: ave,
      count: _count,
      feedbacks: feedbacks,
    );
    print("RESULT PARSED $res");
    return res;
  }
  Map<String, dynamic> toJson() => {
        "count": count,
        "average": averageRating,
        "feedbacks": feedbacks.map((e) => e.toJson()).toList(),
      };
  @override
  String toString() => "${toJson()}";
}
