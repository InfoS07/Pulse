class NewsArticle {
  final String title;
  final String description;
  final String? articleText;

  NewsArticle({
    required this.title,
    required this.description,
    this.articleText = "loremIpsum",
  });
}


List<NewsArticle> getNewsStories() {
  return [
    NewsArticle(
      title: "Breaking News",
      description: "This is a breaking news description.",
    ),
    NewsArticle(
      title: "Sports Update",
      description: "Latest update on sports events.",
    ),
    NewsArticle(
      title: "Tech Trends",
      description: "The latest trends in technology.",
    ),
    // Ajoutez d'autres articles si nécessaire
  ];
}