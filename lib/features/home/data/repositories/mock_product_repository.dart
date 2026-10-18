import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

class MockProductRepository implements ProductRepository {
  static const List<ProductEntity> _mockCatalog = [
    ProductEntity(
      id: 'prod_dress_wrap',
      pieceNumber: '01',
      title: 'Đầm hoa wrap dáng midi nữ tính',
      brand: 'NÉORA Collection',
      subCategory: 'ĐẦM',
      category: 'Đầm',
      price: 459000.0,
      originalPrice: 659000.0,
      composition: 'Voan tơ mềm mại thoáng mát · Lót lụa mềm',
      description:
          'Đầm hoa nhí dáng wrap thắt nơ tôn dáng, chất liệu voan tơ bay bổng, thoáng mát phù hợp dạo phố, đi biển hay đi làm nhẹ nhàng.',
      availableSizes: ['S', 'M', 'L', 'XL'],
      availableColors: [Color(0xFFE8D9C4), Color(0xFFC8A97E)],
      colorNames: ['Kem Be', 'Camel Nâu'],
      tag: 'BÁN CHẠY',
      imageType: 'dress',
      imagePath: 'assets/images/real/p_dress.jpg',
      isHeroPiece: true,
      rating: 4.9,
      reviewCount: 348,
      soldCount: 1200,
      isFavorite: true,
    ),
    ProductEntity(
      id: 'prod_knit_sweater',
      pieceNumber: '02',
      title: 'Áo len cổ lọ dệt kim mềm mịn',
      brand: 'NÉORA Studio',
      subCategory: 'ÁO LEN',
      category: 'Áo len',
      price: 389000.0,
      originalPrice: 520000.0,
      composition: 'Len dệt sợi mịn ấm áp · Không xù lông',
      description:
          'Áo len phom rộng cổ lọ mềm mại, tone màu be yến mạch nhã nhặn dễ phối đồ cho mùa thu đông.',
      availableSizes: ['S', 'M', 'L'],
      availableColors: [Color(0xFFE5DFC9), Color(0xFFF5EBE6)],
      colorNames: ['Be Yến Mạch', 'Kem Sữa'],
      tag: 'MÙA THU',
      imageType: 'knit_sweater',
      imagePath: 'assets/images/real/p_knit.jpg',
      rating: 4.8,
      reviewCount: 178,
      soldCount: 860,
      isFavorite: false,
    ),
    ProductEntity(
      id: 'prod_hoodie_lavender',
      pieceNumber: '03',
      title: 'Áo hoodie oversize màu lavender',
      brand: 'NÉORA Street',
      subCategory: 'HOODIE',
      category: 'Hoodie',
      price: 329000.0,
      originalPrice: 450000.0,
      composition: 'Nỉ bông cao cấp dày dặn (420gsm)',
      description:
          'Áo hoodie dáng rộng phong cách trẻ trung năng động, mũ 2 lớp đứng phom và túi kangaroo tiện lợi.',
      availableSizes: ['M', 'L', 'XL'],
      availableColors: [Color(0xFFD6C8F2), Color(0xFFD8D8D8)],
      colorNames: ['Lavender', 'Xám Tiêu'],
      tag: 'MỚI',
      imageType: 'hoodie',
      imagePath: 'assets/images/real/p_hoodie.jpg',
      rating: 4.9,
      reviewCount: 245,
      soldCount: 2100,
      isFavorite: true,
    ),
    ProductEntity(
      id: 'prod_linen_shirt',
      pieceNumber: '04',
      title: 'Sơ mi linen cộc tay thoáng mát',
      brand: 'NÉORA Men',
      subCategory: 'SƠ MI',
      category: 'Sơ mi',
      price: 279000.0,
      originalPrice: 350000.0,
      composition: '100% Linen tự nhiên thoáng khí',
      description:
          'Áo sơ mi linen cổ bẻ phom thoải mái, chất vải dệt tự nhiên thấm hút mồ hôi tối đa, phong cách tối giản thanh lịch.',
      availableSizes: ['S', 'M', 'L', 'XL'],
      availableColors: [Color(0xFFFFFFFF), Color(0xFFC8B29B)],
      colorNames: ['Trắng Basic', 'Be Tự Nhiên'],
      tag: 'CỰC MÁT',
      imageType: 'shirt',
      imagePath: 'assets/images/real/p_shirt.jpg',
      rating: 4.7,
      reviewCount: 92,
      soldCount: 640,
      isFavorite: false,
    ),
    ProductEntity(
      id: 'prod_jeans_wide',
      pieceNumber: '05',
      title: 'Quần jeans ống rộng wash nhạt',
      brand: 'NÉORA Denim',
      subCategory: 'QUẦN',
      category: 'Quần',
      price: 399000.0,
      originalPrice: 499000.0,
      composition: '100% Denim Cotton cao cấp đứng dáng',
      description:
          'Quần bò lưng cao ống suông che khuyết điểm, màu wash sáng trẻ trung, phối đồ cực kỳ tôn dáng.',
      availableSizes: ['26', '27', '28', '29'],
      availableColors: [Color(0xFF98B8D8)],
      colorNames: ['Xanh Wash Nhạt'],
      tag: 'HOT',
      imageType: 'jeans',
      imagePath: 'assets/images/real/p_jeans.jpg',
      rating: 4.8,
      reviewCount: 310,
      soldCount: 1500,
      isFavorite: false,
    ),
    ProductEntity(
      id: 'prod_sneaker_white',
      pieceNumber: '06',
      title: 'Giày sneaker da trắng basic',
      brand: 'NÉORA Footwear',
      subCategory: 'GIÀY',
      category: 'Giày',
      price: 690000.0,
      originalPrice: 890000.0,
      composition: 'Da tổng hợp êm ái · Đế cao su đúc nguyên khối',
      description:
          'Giày thể thao trắng thiết kế tối giản, đệm lót êm chân hỗ trợ di chuyển cả ngày, dễ dàng phối với mọi outfit.',
      availableSizes: ['36', '37', '38', '39', '40'],
      availableColors: [Color(0xFFFFFFFF)],
      colorNames: ['Trắng'],
      tag: 'BÁN CHẠY',
      imageType: 'sneaker',
      imagePath: 'assets/images/real/p_sneaker.jpg',
      rating: 4.9,
      reviewCount: 520,
      soldCount: 3200,
      isFavorite: true,
    ),
    ProductEntity(
      id: 'prod_leather_bag',
      pieceNumber: '07',
      title: 'Túi đeo vai da khoá vàng sang trọng',
      brand: 'NÉORA Accessories',
      subCategory: 'TÚI',
      category: 'Túi',
      price: 590000.0,
      originalPrice: 790000.0,
      composition: 'Da nhân tạo vân hạt cao cấp · Khoá mạ vàng',
      description:
          'Túi đeo vai phom hộp thời thượng, quai đeo êm ái kèm khoá bấm kim loại vàng sáng bóng, chứa vừa điện thoại và đồ dùng.',
      availableSizes: ['Free size'],
      availableColors: [Color(0xFF8B4513), Color(0xFF1E1E1E)],
      colorNames: ['Nâu Bò', 'Đen Tuyển'],
      tag: 'TRENDING',
      imageType: 'bag',
      imagePath: 'assets/images/real/p_bag.jpg',
      rating: 4.9,
      reviewCount: 188,
      soldCount: 930,
      isFavorite: false,
    ),
    ProductEntity(
      id: 'prod_dress_floral_side',
      pieceNumber: '08',
      title: 'Váy hoa xoè dáng dài thướt tha',
      brand: 'NÉORA Collection',
      subCategory: 'ĐẦM',
      category: 'Đầm',
      price: 499000.0,
      originalPrice: 699000.0,
      composition: 'Chiffon lụa mềm mại',
      description:
          'Mẫu váy hoa nhẹ nhàng tiểu thư, tùng váy xoè bồng bềnh chuyển động thướt tha theo từng bước chân.',
      availableSizes: ['S', 'M', 'L'],
      availableColors: [Color(0xFFE8D9C4)],
      colorNames: ['Kem Be Thơ'],
      tag: 'MỚI',
      imageType: 'dress',
      imagePath: 'assets/images/real/p_dress_side.jpg',
      rating: 4.8,
      reviewCount: 119,
      soldCount: 720,
      isFavorite: true,
    ),
  ];

  @override
  Future<List<ProductEntity>> getFeaturedProducts() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _mockCatalog;
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 30));
    try {
      return _mockCatalog.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (category == 'Tất cả' || category == 'All') {
      return _mockCatalog;
    }
    return _mockCatalog
        .where((p) => p.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  @override
  Future<List<ProductEntity>> getSneakers() async {
    return _mockCatalog;
  }

  static List<ProductEntity> get mockCatalog => _mockCatalog;
  List<ProductEntity> getMockCatalog() => _mockCatalog;
}
