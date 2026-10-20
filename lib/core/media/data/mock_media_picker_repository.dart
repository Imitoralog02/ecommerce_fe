import '../domain/media_picker_repository.dart';

class MockMediaPickerRepository implements MediaPickerRepository {
  final Map<MediaPickerPurpose, int> _nextIndex = {};

  static const _assets = {
    MediaPickerPurpose.visualSearch: [
      'assets/images/real/p_dress.jpg',
      'assets/images/real/p_shirt.jpg',
      'assets/images/real/p_sneaker.jpg',
      'assets/images/real/p_bag.jpg',
    ],
    MediaPickerPurpose.review: [
      'assets/images/real/p_dress.jpg',
      'assets/images/real/p_dress_side.jpg',
    ],
    MediaPickerPurpose.returnEvidence: [
      'assets/images/real/p_shirt.jpg',
      'assets/images/real/p_dress.jpg',
    ],
  };

  @override
  Future<String?> pickImage(
    MediaPickerPurpose purpose, {
    String? suggestedAsset,
  }) async {
    if (suggestedAsset != null && purpose != MediaPickerPurpose.visualSearch) {
      return suggestedAsset;
    }
    final assets = _assets[purpose]!;
    final index = _nextIndex[purpose] ?? 0;
    _nextIndex[purpose] = index + 1;
    return assets[index % assets.length];
  }
}
