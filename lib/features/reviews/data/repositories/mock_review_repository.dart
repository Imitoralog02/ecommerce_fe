import '../../../../data/local/demo_preferences_store.dart';
import '../../../home/data/repositories/mock_product_repository.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';

class MockReviewRepository implements ReviewRepository {
  MockReviewRepository([this._store]) {
    final saved = _store?.read(_key);
    if (saved is! Map) return;
    try {
      final data = Map<String, dynamic>.from(saved);
      final byProduct = Map<String, dynamic>.from(data['reviews'] as Map);
      for (final entry in byProduct.entries) {
        _reviewsByProduct[entry.key] = (entry.value as List)
            .map((value) => _fromJson(Map<String, dynamic>.from(value as Map)))
            .toList();
      }
      _submissionKeys.addAll(
        (data['submissionKeys'] as List).whereType<String>(),
      );
    } catch (_) {
      _reviewsByProduct.clear();
      _submissionKeys.clear();
    }
  }

  static const _key = 'demo_reviews_v1';
  final DemoPreferencesStore? _store;
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
          'Chất vải voan tơ mềm mại bay bổng ngoài mong đợi, có lớp lót lụa kín đáo không sợ mỏng. Mình cao 1m62 mặc size S chạm bắp chân rất tôn dáng. Gói hàng đẹp mắt!',
      reviewImages: [
        'assets/images/real/p_dress.jpg',
        'assets/images/real/p_dress_side.jpg',
      ],
      helpfulCount: 38,
      sellerReply:
          'Phản hồi minh họa: Cảm ơn bạn đã chia sẻ cảm nhận về đầm hoa midi ✨',
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
          'Đường may sắc sảo, phom váy lên dáng đẹp. Tone màu camel tôn da, mặc đi tiệc hay đi làm đều nhận được nhiều lời khen!',
      reviewImages: ['assets/images/real/p_dress_side.jpg'],
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
          'Phản hồi minh họa: Bạn có thể thử gửi yêu cầu đổi size trong mục đơn hàng. Bản demo chưa xử lý giao nhận thực tế.',
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
    () => List.unmodifiable(_seedFor(productId)),
  );

  List<ReviewEntity> _seedFor(String productId) {
    if (productId == 'prod_dress_wrap') return _seedReviews;
    final matches = MockProductRepository.mockCatalog.where(
      (p) => p.id == productId,
    );
    if (matches.isEmpty) {
      return [
        const ReviewEntity(
          id: 'seed_generic',
          userName: 'Khách hàng NÉORA',
          userAvatar: '',
          rating: 5,
          date: '10/10/2026',
          purchasedSize: '',
          purchasedColor: '',
          buyerHeight: '',
          buyerWeight: '',
          fitFeedback: 'Hài lòng',
          comment: 'Sản phẩm đúng mô tả và được đóng gói cẩn thận.',
        ),
      ];
    }
    final product = matches.first;
    return [
      ReviewEntity(
        id: 'seed_${product.id}',
        userName: 'Khách hàng NÉORA',
        userAvatar: '',
        rating: product.rating,
        date: '10/10/2026',
        purchasedSize: product.availableSizes.isEmpty
            ? ''
            : product.availableSizes.first,
        purchasedColor: product.colorNames.isEmpty
            ? ''
            : product.colorNames.first,
        buyerHeight: '',
        buyerWeight: '',
        fitFeedback: 'Đúng như mô tả',
        comment:
            'Mình đã nhận ${product.title}. Chất liệu và màu sắc đúng như hình, đóng gói cẩn thận.',
        reviewImages: product.imagePath == null
            ? const []
            : [product.imagePath!],
      ),
    ];
  }

  @override
  void save(String productId, List<ReviewEntity> reviews) {
    _reviewsByProduct[productId] = List.unmodifiable(reviews);
    _persist();
  }

  @override
  bool addIfAbsent({
    required String productId,
    required String submissionKey,
    required ReviewEntity review,
  }) {
    if (!_submissionKeys.add(submissionKey)) return false;
    save(productId, [review, ...load(productId)]);
    _persist();
    return true;
  }

  void _persist() => _store?.write(_key, {
    'reviews': _reviewsByProduct.map(
      (key, value) => MapEntry(key, value.map(_toJson).toList()),
    ),
    'submissionKeys': _submissionKeys.toList(),
  });

  static Map<String, Object?> _toJson(ReviewEntity value) => {
    'id': value.id,
    'userName': value.userName,
    'userAvatar': value.userAvatar,
    'rating': value.rating,
    'date': value.date,
    'purchasedSize': value.purchasedSize,
    'purchasedColor': value.purchasedColor,
    'buyerHeight': value.buyerHeight,
    'buyerWeight': value.buyerWeight,
    'fitFeedback': value.fitFeedback,
    'comment': value.comment,
    'reviewImages': value.reviewImages,
    'helpfulCount': value.helpfulCount,
    'isHelpful': value.isHelpful,
    'sellerReply': value.sellerReply,
  };

  static ReviewEntity _fromJson(Map<String, dynamic> value) => ReviewEntity(
    id: value['id'] as String,
    userName: value['userName'] as String,
    userAvatar: value['userAvatar'] as String,
    rating: (value['rating'] as num).toDouble(),
    date: value['date'] as String,
    purchasedSize: value['purchasedSize'] as String,
    purchasedColor: value['purchasedColor'] as String,
    buyerHeight: value['buyerHeight'] as String,
    buyerWeight: value['buyerWeight'] as String,
    fitFeedback: value['fitFeedback'] as String,
    comment: value['comment'] as String,
    reviewImages: List<String>.from(value['reviewImages'] as List),
    helpfulCount: value['helpfulCount'] as int,
    isHelpful: value['isHelpful'] as bool,
    sellerReply: value['sellerReply'] as String?,
  );
}
