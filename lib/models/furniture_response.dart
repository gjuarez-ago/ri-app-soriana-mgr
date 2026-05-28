class FurnitureResponse {
  final int idRealograma;
  final String? nombreRealograma;

  FurnitureResponse({
    required this.idRealograma,
    required this.nombreRealograma,
  });

  factory FurnitureResponse.fromJson(Map<String, dynamic> json) {
    return FurnitureResponse(
      idRealograma: json['idRealograma'] as int,
      nombreRealograma: json['nombreRealograma'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idRealograma': idRealograma,
      'nombreRealograma': nombreRealograma,
    };
  }
}
