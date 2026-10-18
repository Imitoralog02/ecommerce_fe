import '../domain/media_picker_repository.dart';

class MockMediaPickerRepository implements MediaPickerRepository {
  final Map<MediaPickerPurpose, int> _nextIndex = {};

  static const _assets = {
    MediaPickerPurpose.visualSearch: ['assets/images/real/onb_shopping.jpg'],
    MediaPickerPurpose.review: [
      'assets/images/real/lookbook_summer_3.jpg',
      'assets/images/real/lookbook_summer_4.jpg',
    ],
    MediaPickerPurpose.returnEvidence: [
      'assets/images/real/lookbook_summer_2.jpg',
      'assets/images/real/lookbook_summer_3.jpg',
    ],
  };

  @override
  Future<String?> pickImage(MediaPickerPurpose purpose) async {
    final assets = _assets[purpose]!;
    final index = _nextIndex[purpose] ?? 0;
    _nextIndex[purpose] = index + 1;
    return assets[index % assets.length];
  }
}
