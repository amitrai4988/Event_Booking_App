class Category {
  final int id;
  final String title;
  final String subtitle;
  final String image;
  final String description;
  final List<Map<String, dynamic>> items;

  Category({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.description,
    required this.items,
  });
}
