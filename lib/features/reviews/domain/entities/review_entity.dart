class ReviewEntity {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String date;
  final String purchasedSize;
  final String purchasedColor;
  final String buyerHeight;
  final String buyerWeight;
  final String fitFeedback;
  final String comment;
  final List<String> reviewImages;
  final int helpfulCount;
  final bool isHelpful;
  final String? sellerReply;

  const ReviewEntity({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.date,
    required this.purchasedSize,
    required this.purchasedColor,
    required this.buyerHeight,
    required this.buyerWeight,
    required this.fitFeedback,
    required this.comment,
    this.reviewImages = const [],
    this.helpfulCount = 0,
    this.isHelpful = false,
    this.sellerReply,
  });

  ReviewEntity copyWith({
    String? id,
    String? userName,
    String? userAvatar,
    double? rating,
    String? date,
    String? purchasedSize,
    String? purchasedColor,
    String? buyerHeight,
    String? buyerWeight,
    String? fitFeedback,
    String? comment,
    List<String>? reviewImages,
    int? helpfulCount,
    bool? isHelpful,
    String? sellerReply,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      date: date ?? this.date,
      purchasedSize: purchasedSize ?? this.purchasedSize,
      purchasedColor: purchasedColor ?? this.purchasedColor,
      buyerHeight: buyerHeight ?? this.buyerHeight,
      buyerWeight: buyerWeight ?? this.buyerWeight,
      fitFeedback: fitFeedback ?? this.fitFeedback,
      comment: comment ?? this.comment,
      reviewImages: reviewImages ?? this.reviewImages,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      isHelpful: isHelpful ?? this.isHelpful,
      sellerReply: sellerReply ?? this.sellerReply,
    );
  }
}
