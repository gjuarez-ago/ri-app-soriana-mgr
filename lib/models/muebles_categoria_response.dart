class MueblesCategoriaResponse {
  
  final String categoria;
  final int idRealograma;
  final int idReconocimiento;
  final String nombreRealograma;

  MueblesCategoriaResponse({
    required this.categoria,
    required this.idRealograma,
    required this.idReconocimiento,
    required this.nombreRealograma,
  });

  // Método para crear una instancia de MueblesCategoriaResponse a partir de un JSON
  factory MueblesCategoriaResponse.fromJson(Map<String, dynamic> json) {
    return MueblesCategoriaResponse(
      categoria: json['categoria'],
      idRealograma: json['idRealograma'],
      idReconocimiento: json['idReconocimiento'],
      nombreRealograma: json['nombreRealograma'],
    );
  }

  // Método para convertir una instancia de MueblesCategoriaResponse a JSON
  Map<String, dynamic> toJson() {
    return {
      'categoria': categoria,
      'idRealograma': idRealograma,
      'idReconocimiento': idReconocimiento,
      'nombreRealograma': nombreRealograma,
    };
  }
}
