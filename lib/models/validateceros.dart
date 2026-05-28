class ValidateCeros {
  final int idRealograma;
  final String category;
  final int tramo;

  ValidateCeros({
    required this.idRealograma,
    required this.category,
    required this.tramo,
  });

  // 🔹 Convertir objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'idRealograma': idRealograma,
      'category': category,
      'tramo': tramo,
    };
  }

  // 🔹 Crear objeto desde JSON
  factory ValidateCeros.fromJson(Map<String, dynamic> json) {
    return ValidateCeros(
      idRealograma: json['idRealograma'] as int,
      category: json['category'] as String,
      tramo: json['tramo'] as int,
    );
  }
}
