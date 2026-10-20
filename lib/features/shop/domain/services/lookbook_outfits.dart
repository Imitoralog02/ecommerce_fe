import 'package:flutter/material.dart';

import '../../../home/domain/entities/product_entity.dart';

class LookbookHotspot {
  final String title;
  final String category;
  final double price;
  final double originalPrice;
  final String imageType;
  final String imagePath;
  final Offset position;
  final ProductEntity product;
  final String selectedSize;
  final String selectedColor;

  const LookbookHotspot({
    required this.title,
    required this.category,
    required this.price,
    required this.originalPrice,
    required this.imageType,
    required this.imagePath,
    required this.position,
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
  });
}

class LookbookThemeModel {
  final String id;
  final String badge;
  final String occasion;
  final String gender;
  final String title;
  final String subtitle;
  final String imagePath;
  final String inspiration;
  final List<LookbookHotspot> items;

  const LookbookThemeModel({
    required this.id,
    required this.badge,
    required this.occasion,
    required this.gender,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.inspiration,
    required this.items,
  });

  double get totalPrice => items.fold(0, (sum, item) => sum + item.price);
  double get totalOriginalPrice =>
      items.fold(0, (sum, item) => sum + item.originalPrice);
  double get bundlePrice => totalPrice;
  double get savings => totalOriginalPrice - bundlePrice;
}

typedef _Piece = ({String id, String size, String color, Offset position});

class _OutfitTemplate {
  const _OutfitTemplate({
    required this.id,
    required this.occasion,
    required this.gender,
    required this.title,
    required this.imagePath,
    required this.inspiration,
    required this.pieces,
  });

  final String id;
  final String occasion;
  final String gender;
  final String title;
  final String imagePath;
  final String inspiration;
  final List<_Piece> pieces;
}

class LookbookOutfits {
  const LookbookOutfits._();

  static List<LookbookThemeModel> select(
    List<ProductEntity> catalog, {
    required String occasion,
    required String gender,
    required double budget,
    String bagColor = 'Nâu Da Bò',
  }) {
    final products = {for (final product in catalog) product.id: product};
    final templates = <_OutfitTemplate>[
      _OutfitTemplate(
        id: 'female-work',
        occasion: 'Đi làm',
        gender: 'Nữ',
        title: 'Đi làm, thật nhẹ nhàng',
        imagePath: 'assets/images/real/splash_2_work.jpg',
        inspiration:
            'Sơ vin nhẹ và xắn tay áo một nếp để tổng thể tự nhiên hơn.',
        pieces: [
          (
            id: 'prod_linen_shirt',
            size: 'M',
            color: 'Trắng Ngà',
            position: const Offset(.5, .35),
          ),
          (
            id: 'prod_jeans_wide',
            size: '27',
            color: 'Xám Than',
            position: const Offset(.5, .65),
          ),
          (
            id: 'prod_leather_bag',
            size: 'Free size',
            color: bagColor,
            position: const Offset(.68, .55),
          ),
        ],
      ),
      _OutfitTemplate(
        id: 'male-work',
        occasion: 'Đi làm',
        gender: 'Nam',
        title: 'Gọn gàng, không gò bó',
        imagePath: 'assets/images/real/banner_men.jpg',
        inspiration:
            'Phom dáng vừa vặn cùng chất liệu thoáng khí cho ngày làm việc.',
        pieces: [
          (
            id: 'prod_knit_sweater',
            size: 'L',
            color: 'Xanh Rêu',
            position: const Offset(.5, .35),
          ),
          (
            id: 'prod_sneaker_white',
            size: '40',
            color: 'Trắng Kem',
            position: const Offset(.5, .82),
          ),
        ],
      ),
      _OutfitTemplate(
        id: 'female-play',
        occasion: 'Đi chơi',
        gender: 'Nữ',
        title: 'Dạo phố nhẹ tênh',
        imagePath: 'assets/images/real/p_dress.jpg',
        inspiration: 'Đầm mềm và sneaker giúp bạn thoải mái cả ngày.',
        pieces: [
          (
            id: 'prod_dress_wrap',
            size: 'M',
            color: 'Kem Be',
            position: const Offset(.5, .4),
          ),
          (
            id: 'prod_sneaker_white',
            size: '38',
            color: 'Trắng Kem',
            position: const Offset(.5, .82),
          ),
        ],
      ),
      _OutfitTemplate(
        id: 'male-play',
        occasion: 'Đi chơi',
        gender: 'Nam',
        title: 'Cuối tuần thoải mái',
        imagePath: 'assets/images/real/p_hoodie.jpg',
        inspiration: 'Hoodie cotton và sneaker cho nhịp đi chơi năng động.',
        pieces: [
          (
            id: 'prod_hoodie_lavender',
            size: 'L',
            color: 'Be Cát',
            position: const Offset(.5, .35),
          ),
          (
            id: 'prod_sneaker_white',
            size: '40',
            color: 'Trắng Kem',
            position: const Offset(.5, .82),
          ),
        ],
      ),
      _OutfitTemplate(
        id: 'female-party',
        occasion: 'Dự tiệc',
        gender: 'Nữ',
        title: 'Tinh tế cho buổi hẹn',
        imagePath: 'assets/images/real/p_dress_side.jpg',
        inspiration: 'Đầm linen và túi da tạo điểm nhấn vừa đủ.',
        pieces: [
          (
            id: 'prod_dress_floral_side',
            size: 'M',
            color: 'Kem Tự Nhiên',
            position: const Offset(.5, .4),
          ),
          (
            id: 'prod_leather_bag',
            size: 'Free size',
            color: bagColor,
            position: const Offset(.7, .6),
          ),
        ],
      ),
      _OutfitTemplate(
        id: 'male-party',
        occasion: 'Dự tiệc',
        gender: 'Nam',
        title: 'Lịch lãm vừa đủ',
        imagePath: 'assets/images/real/banner_men.jpg',
        inspiration: 'Áo dệt mịn phối phụ kiện da cho buổi gặp gỡ.',
        pieces: [
          (
            id: 'prod_knit_sweater',
            size: 'L',
            color: 'Be Yến Mạch',
            position: const Offset(.5, .35),
          ),
          (
            id: 'prod_leather_bag',
            size: 'Free size',
            color: bagColor,
            position: const Offset(.7, .6),
          ),
        ],
      ),
      _OutfitTemplate(
        id: 'female-travel',
        occasion: 'Du lịch',
        gender: 'Nữ',
        title: 'Đi xa, mặc thật dễ',
        imagePath: 'assets/images/real/p_hoodie.jpg',
        inspiration: 'Chọn những món dễ phối để hành lý gọn nhẹ.',
        pieces: [
          (
            id: 'prod_hoodie_lavender',
            size: 'M',
            color: 'Be Cát',
            position: const Offset(.5, .35),
          ),
          (
            id: 'prod_jeans_wide',
            size: '27',
            color: 'Kem Đá',
            position: const Offset(.5, .65),
          ),
          (
            id: 'prod_sneaker_white',
            size: '38',
            color: 'Trắng Kem',
            position: const Offset(.5, .86),
          ),
        ],
      ),
      _OutfitTemplate(
        id: 'male-travel',
        occasion: 'Du lịch',
        gender: 'Nam',
        title: 'Sẵn sàng lên đường',
        imagePath: 'assets/images/real/p_hoodie.jpg',
        inspiration: 'Hoodie và sneaker cùng bạn di chuyển thoải mái.',
        pieces: [
          (
            id: 'prod_hoodie_lavender',
            size: 'L',
            color: 'Xanh Rêu',
            position: const Offset(.5, .35),
          ),
          (
            id: 'prod_sneaker_white',
            size: '40',
            color: 'Trắng Kem',
            position: const Offset(.5, .82),
          ),
        ],
      ),
    ];

    final result = <LookbookThemeModel>[];
    for (final template in templates) {
      if (template.occasion != occasion ||
          (gender != 'Tất cả' && template.gender != gender)) {
        continue;
      }
      final items = <LookbookHotspot>[];
      var total = 0.0;
      for (final piece in template.pieces) {
        final product = products[piece.id];
        if (product == null ||
            !product.availableSizes.contains(piece.size) ||
            !product.colorNames.contains(piece.color) ||
            product.imagePath == null) {
          items.clear();
          break;
        }
        if (total + product.price > budget) continue;
        total += product.price;
        items.add(
          LookbookHotspot(
            title: product.title,
            category:
                '${piece.size == 'Free size' ? 'Một cỡ' : 'Cỡ ${piece.size}'} • ${piece.color}',
            price: product.price,
            originalPrice: product.originalPrice ?? product.price,
            imageType: product.imageType,
            imagePath: product.imagePath!,
            position: piece.position,
            product: product,
            selectedSize: piece.size,
            selectedColor: piece.color,
          ),
        );
      }
      if (items.isEmpty) continue;
      result.add(
        LookbookThemeModel(
          id: template.id,
          badge: template.gender == 'Nam'
              ? 'DÀNH CHO NAM'
              : 'NÉORA CHỌN CHO BẠN',
          occasion: template.occasion,
          gender: template.gender,
          title: template.title,
          subtitle:
              '${template.gender} • ${items.length} món • ${items.map((item) => item.product.category).join(', ')}',
          imagePath: template.imagePath,
          inspiration: template.inspiration,
          items: List.unmodifiable(items),
        ),
      );
    }
    return result;
  }
}
