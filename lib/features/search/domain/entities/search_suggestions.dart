class SearchSuggestions {
  const SearchSuggestions({
    required this.recentSearches,
    required this.trendingSearches,
  });

  final List<String> recentSearches;
  final List<String> trendingSearches;
}
