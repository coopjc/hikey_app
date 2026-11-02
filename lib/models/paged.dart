class Paged<T> {
  const Paged({
    required this.content,
    required this.size,
    required this.number,
    required this.totalElements,
    required this.totalPages,
  });

  final List<T> content;
  final int size;
  final int number;
  final int totalElements;
  final int totalPages;

  factory Paged.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final Map<String, dynamic> page = json['page'] as Map<String, dynamic>;

    return Paged<T>(
      content: (json['content'] as List<dynamic>)
          .map((dynamic item) => fromItem(item as Map<String, dynamic>))
          .toList(),
      size: page['size'] as int,
      number: page['number'] as int,
      totalElements: page['total_elements'] as int,
      totalPages: page['total_pages'] as int,
    );
  }
}
