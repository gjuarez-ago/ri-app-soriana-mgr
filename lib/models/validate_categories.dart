class ValidateCategories {
  final int store;
  final String? category;
  final String upc;

  ValidateCategories({
    required this.store,
    required this.category,
    required this.upc,
  });

  // 🔹 Convertir objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'store': store,
      'category': category,
      'upc': upc,
    };
  }

  // 🔹 Crear objeto desde JSON
  factory ValidateCategories.fromJson(Map<String, dynamic> json) {
    return ValidateCategories(
      store: json['store'] as int,
      category: json['category'] as String,
      upc: json['upc'] as String,
    );
  }
}
