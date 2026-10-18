import '../entities/search_suggestions.dart';
import '../entities/visual_search_result.dart';

abstract class SearchRepository {
  SearchSuggestions loadSuggestions();
  void saveRecentSearches(List<String> searches);
  Future<VisualSearchResult> searchByImage(String imagePath);
}
