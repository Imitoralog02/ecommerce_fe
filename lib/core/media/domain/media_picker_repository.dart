enum MediaPickerPurpose { visualSearch, review, returnEvidence }

abstract class MediaPickerRepository {
  Future<String?> pickImage(
    MediaPickerPurpose purpose, {
    String? suggestedAsset,
  });
}
