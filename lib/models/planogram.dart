class Planograma {
  final int id;
  final String nombrePlanograma;
  final String urlPdf;

  Planograma({
    required this.id,
    required this.nombrePlanograma,
    required this.urlPdf,
  });

  // Método para crear una instancia desde un JSON
  factory Planograma.fromJson(Map<String, dynamic> json) {
    return Planograma(
      id: json['id'],
      nombrePlanograma: json['nombrePlanograma'],
      urlPdf: json['urlPdf'],
    );
  }

  // Método para convertir una instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombrePlanograma': nombrePlanograma,
      'urlPdf': urlPdf,
    };
  }
}
