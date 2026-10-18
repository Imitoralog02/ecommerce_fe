import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';

class MockReviewRepository implements ReviewRepository {
  final Map<String, List<ReviewEntity>> _reviewsByProduct = {};
  final Set<String> _submissionKeys = {};

  static const _seedReviews = [
    ReviewEntity(
      id: 'rev_01',
      userName: 'Trần Mai Phương',
      userAvatar: 'assets/images/real/onb_shopping.jpg',
      rating: 5,
      date: '14/10/2026',
      purchasedSize: 'Size S',
      purchasedColor: 'Kem Be',
      buyerHeight: '1m62',
      buyerWeight: '48kg',
      fitFeedback: 'Vừa vặn hoàn hảo',
      comment:
          'Chất vải voan tơ mềm mại bay bổng ngoài mong đợi, có lớp lót lụa kín đáo không sợ mỏng. Mình cao 1m62 mặc size S chạm bắp chân rất tôn dáng. Giao hàng 2h siêu nhanh!',
      reviewImages: [
        'assets/images/real/p_dress.jpg',
        'assets/images/real/p_dress_side.jpg',
      ],
      helpfulCount: 38,
      sellerReply:
          'NÉORA Concierge cảm ơn bạn Phương đã tin chọn thiết kế Đầm hoa midi! Chúc bạn luôn rạng rỡ và duyên dáng cùng các trang phục của NÉORA nhé ✨',
    ),
    ReviewEntity(
      id: 'rev_02',
      userName: 'Lê Thuỳ Dung',
      userAvatar: 'assets/images/real/onb_shopping.jpg',
      rating: 5,
      date: '12/10/2026',
      purchasedSize: 'Size M',
      purchasedColor: 'Camel Nâu',
      buyerHeight: '1m65',
      buyerWeight: '54kg',
      fitFeedback: 'Đúng chuẩn phom',
      comment:
          'Đường may giấu chỉ sắc sảo chuẩn hàng may đo cao cấp. Tone màu camel tôn da cực kỳ, mặc đi tiệc hay đi làm đều nhận được nhiều lời khen!',
      reviewImages: ['assets/images/real/p_knit.jpg'],
      helpfulCount: 21,
    ),
    ReviewEntity(
      id: 'rev_03',
      userName: 'Ngọc Hân',
      userAvatar: 'assets/images/real/onb_shopping.jpg',
      rating: 4.5,
      date: '08/10/2026',
      purchasedSize: 'Size S',
      purchasedColor: 'Kem Be',
      buyerHeight: '1m58',
      buyerWeight: '46kg',
      fitFeedback: 'Vừa vặn',
      comment:
          'Váy đẹp như hình, đóng gói hộp NÉORA thơm mùi nước hoa rất tinh tế. Hơi dài một chút so với chiều cao của mình nhưng thắt nơ lại rất xinh.',
      helpfulCount: 15,
      sellerReply:
          'Dạ NÉORA hỗ trợ lên lai hoặc đổi size tận nhà hoàn toàn miễn phí trong 30 ngày nha bạn Hân ơi. Cảm ơn bạn rất nhiều!',
    ),
    ReviewEntity(
      id: 'rev_04',
      userName: 'Hoàng Yến',
      userAvatar: 'assets/images/real/onb_shopping.jpg',
      rating: 5,
      date: '05/10/2026',
      purchasedSize: 'Size L',
      purchasedColor: 'Camel Nâu',
      buyerHeight: '1m66',
      buyerWeight: '61kg',
      fitFeedback: 'Che khuyết điểm tốt',
      comment:
          'Form váy wrap này thần thánh thật sự, che được vòng 2 khéo léo. Chị em văn phòng nên có một chiếc trong tủ đồ nha!',
      helpfulCount: 9,
    ),
  ];

  @override
  List<ReviewEntity> load(String productId) => _reviewsByProduct.putIfAbsent(
    productId,
    () => List.unmodifiable(_seedReviews),
  );

  @override
  void save(String productId, List<ReviewEntity> reviews) {
    _reviewsByProduct[productId] = List.unmodifiable(reviews);
  }

  @override
  bool addIfAbsent({
    required String productId,
    required String submissionKey,
    required ReviewEntity review,
  }) {
    if (!_submissionKeys.add(submissionKey)) return false;
    save(productId, [review, ...load(productId)]);
    return true;
  }
}
