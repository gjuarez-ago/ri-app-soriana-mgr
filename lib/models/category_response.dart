class CategoryResponse {
  final String fiIdCategoria;
  final String fcCategoria;

  CategoryResponse({
    required this.fiIdCategoria,
    required this.fcCategoria,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      fiIdCategoria: json['fiIdCategoria'] as String,
      fcCategoria: json['fcCategoria'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fiIdCategoria': fiIdCategoria,
      'fcCategoria': fcCategoria,
    };
  }
}
