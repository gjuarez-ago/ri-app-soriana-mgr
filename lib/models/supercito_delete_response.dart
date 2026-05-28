class SupercitoDeleteResponse {
  final String respuesta; // Identificador único del realograma

  SupercitoDeleteResponse({required this.respuesta});

  // Factory para crear una instancia desde un JSON
  factory SupercitoDeleteResponse.fromJson(Map<String, dynamic> json) {
    return SupercitoDeleteResponse(
      respuesta: json['respuesta'] as String,
    );
  }

  // Método para convertir la instancia a un JSON
  Map<String, dynamic> toJson() {
    return {
      'respuesta': respuesta,
    };
  }
}
