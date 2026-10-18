import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductEntity {
  final String id;
  final String pieceNumber;
  final String title;
  final String brand;
  final String subCategory;
  final String category;
  final double price;
  final double? originalPrice;
  final String composition;
  final String description;
  final List<String> availableSizes;
  final List<Color> availableColors;
  final List<String> colorNames;
  final String imageType;
  final String? imagePath;
  final String tag;
  final bool isHeroPiece;
  final double rating;
  final int reviewCount;
  final int soldCount;
  final bool isFavorite;

  const ProductEntity({
    required this.id,
    required this.pieceNumber,
    required this.title,
    this.brand = 'NÉORA',
    required this.subCategory,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.composition,
    required this.description,
    required this.availableSizes,
    this.availableColors = const [
      Color(0xFF1C1C1E),
      Color(0xFFE5E5EA),
      Color(0xFF2C3E50),
    ],
    this.colorNames = const ['Black', 'Off-White', 'Navy'],
    required this.imageType,
    this.imagePath,
    this.tag = 'NEW',
    this.isHeroPiece = false,
    this.rating = 4.9,
    this.reviewCount = 136,
    this.soldCount = 250,
    this.isFavorite = false,
  });

  String get formattedPrice {
    if (price < 10000) {
      return '\$${price.toStringAsFixed(2)}';
    }
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(price.toInt())}₫';
  }

  String? get formattedOriginalPrice {
    if (originalPrice == null) return null;
    if (originalPrice! < 10000) {
      return '\$${originalPrice!.toStringAsFixed(2)}';
    }
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(originalPrice!.toInt())}₫';
  }

  String get sizeRange => availableSizes.isNotEmpty
      ? '${availableSizes.first}-${availableSizes.last}'
      : 'XS-L';

  bool get isNew =>
      tag.toUpperCase().contains('MỚI') || tag.toUpperCase().contains('NEW');

  ProductEntity copyWith({
    String? id,
    String? pieceNumber,
    String? title,
    String? brand,
    String? subCategory,
    String? category,
    double? price,
    double? originalPrice,
    String? composition,
    String? description,
    List<String>? availableSizes,
    List<Color>? availableColors,
    List<String>? colorNames,
    String? imageType,
    String? imagePath,
    String? tag,
    bool? isHeroPiece,
    double? rating,
    int? reviewCount,
    int? soldCount,
    bool? isFavorite,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      pieceNumber: pieceNumber ?? this.pieceNumber,
      title: title ?? this.title,
      brand: brand ?? this.brand,
      subCategory: subCategory ?? this.subCategory,
      category: category ?? this.category,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      composition: composition ?? this.composition,
      description: description ?? this.description,
      availableSizes: availableSizes ?? this.availableSizes,
      availableColors: availableColors ?? this.availableColors,
      colorNames: colorNames ?? this.colorNames,
      imageType: imageType ?? this.imageType,
      imagePath: imagePath ?? this.imagePath,
      tag: tag ?? this.tag,
      isHeroPiece: isHeroPiece ?? this.isHeroPiece,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      soldCount: soldCount ?? this.soldCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
