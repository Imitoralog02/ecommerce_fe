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
      subCategory: 'NỮ • ĐẦM',
      category: 'Đầm',
      price: 459000.0,
      originalPrice: 659000.0,
      composition: 'Voan tơ mềm mại thoáng mát · Lót lụa mềm',
      description:
          'Đầm dáng wrap tôn dáng, chất liệu mềm mại thoáng mát phù hợp dạo phố hay đi làm nhẹ nhàng.',
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
      title: 'Áo khoác linen cổ lọ dệt mịn',
      brand: 'NÉORA Studio',
      subCategory: 'NAM • ÁO LEN',
      category: 'Áo len',
      price: 389000.0,
      originalPrice: 520000.0,
      composition: 'Linen & sợi dệt tự nhiên thoáng nhẹ',
      description:
          'Áo khoác dệt phom rộng mềm mại, tông màu rêu nhã nhặn dễ phối đồ mỗi ngày.',
      availableSizes: ['S', 'M', 'L'],
      availableColors: [Color(0xFF566349), Color(0xFFE5DFC9)],
      colorNames: ['Xanh Rêu', 'Be Yến Mạch'],
      tag: 'DỄ PHỐI',
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
      title: 'Áo hoodie oversize cotton tự nhiên',
      brand: 'NÉORA Everyday',
      subCategory: 'UNISEX • HOODIE',
      category: 'Hoodie',
      price: 329000.0,
      originalPrice: 450000.0,
      composition: 'Cotton tự nhiên dày dặn thoáng khí',
      description:
          'Phom dáng rộng thoải mái, tông màu trung tính dễ mặc trong nhịp sống thường ngày.',
      availableSizes: ['M', 'L', 'XL'],
      availableColors: [Color(0xFFD8D3C8), Color(0xFF566349)],
      colorNames: ['Be Cát', 'Xanh Rêu'],
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
      title: 'Sơ mi cotton dáng rộng thoáng mát',
      brand: 'NÉORA Studio',
      subCategory: 'NỮ • ÁO SƠ MI',
      category: 'Sơ mi',
      price: 279000.0,
      originalPrice: 350000.0,
      composition: '100% Cotton hữu cơ thoáng khí',
      description:
          'Áo sơ mi cổ bẻ phom thoải mái, chất vải dệt tự nhiên thấm hút mồ hôi tối đa, phong cách tối giản thanh lịch.',
      availableSizes: ['S', 'M', 'L', 'XL'],
      availableColors: [
        Color(0xFFF3EFE6),
        Color(0xFFC8B29B),
        Color(0xFFDCE3E6),
      ],
      colorNames: ['Trắng Ngà', 'Be Cát', 'Xanh Nhạt'],
      tag: 'DỄ PHỐI',
      imageType: 'shirt',
      imagePath: 'assets/images/real/p_shirt.jpg',
      rating: 4.8,
      reviewCount: 126,
      soldCount: 640,
      isFavorite: false,
    ),
    ProductEntity(
      id: 'prod_jeans_wide',
      pieceNumber: '05',
      title: 'Quần âu ống suông lưng cao',
      brand: 'NÉORA Tailoring',
      subCategory: 'NỮ • QUẦN',
      category: 'Quần',
      price: 399000.0,
      originalPrice: 499000.0,
      composition: 'Vải tuyết mưa pha rayon đứng dáng',
      description:
          'Quần lưng cao ống suông che khuyết điểm, tông xám than thanh lịch dễ phối cùng sơ mi.',
      availableSizes: ['26', '27', '28', '29'],
      availableColors: [Color(0xFF3E403D), Color(0xFFD8D0C5)],
      colorNames: ['Xám Than', 'Kem Đá'],
      tag: 'BÁN CHẠY',
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
      subCategory: 'PHỤ KIỆN • GIÀY',
      category: 'Giày',
      price: 690000.0,
      originalPrice: 890000.0,
      composition: 'Da mềm êm ái · Đế cao su đúc nguyên khối',
      description:
          'Giày trắng thiết kế tối giản, đệm lót êm chân hỗ trợ di chuyển cả ngày, dễ dàng phối với mọi outfit.',
      availableSizes: ['36', '37', '38', '39', '40'],
      availableColors: [Color(0xFFF7F5F0)],
      colorNames: ['Trắng Kem'],
      tag: 'DỄ PHỐI',
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
      title: 'Túi đeo vai da mềm khoá vàng',
      brand: 'NÉORA Accessories',
      subCategory: 'PHỤ KIỆN • TÚI',
      category: 'Túi',
      price: 590000.0,
      originalPrice: 790000.0,
      composition: 'Da vân mịn cao cấp · Khoá mạ vàng ấm',
      description:
          'Túi đeo vai phom gọn thanh lịch, quai đeo êm ái, chứa vừa điện thoại và đồ dùng hàng ngày.',
      availableSizes: ['Free size'],
      availableColors: [Color(0xFF8B5A2B), Color(0xFF222220)],
      colorNames: ['Nâu Da Bò', 'Đen'],
      tag: 'ĐIỂM NHẤN',
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
      title: 'Đầm linen suông cổ chữ V tự nhiên',
      brand: 'NÉORA Collection',
      subCategory: 'NỮ • ĐẦM',
      category: 'Đầm',
      price: 499000.0,
      originalPrice: 699000.0,
      composition: '100% Linen tự nhiên đã xử lý mềm',
      description:
          'Mẫu đầm suông nhẹ nhàng, thoáng mát và tự nhiên theo từng bước chân.',
      availableSizes: ['S', 'M', 'L'],
      availableColors: [Color(0xFFE8D9C4)],
      colorNames: ['Kem Tự Nhiên'],
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
