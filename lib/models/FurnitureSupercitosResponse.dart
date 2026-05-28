class FurnitureSupercitosResponse {
  final int idRealograma; // Corresponde al campo "IdRealograma"
  final String nombreRealograma; // Corresponde al campo "NombreRealograma"
  final int idBitacora; // Corresponde al campo "idBitacora"

  FurnitureSupercitosResponse({
    required this.idRealograma,
    required this.nombreRealograma,
    required this.idBitacora,
  });

  // Método para crear un objeto Realograma desde un mapa (JSON).
  factory FurnitureSupercitosResponse.fromJson(Map<String, dynamic> json) {
    return FurnitureSupercitosResponse(
      idRealograma: json['idRealograma'],
      nombreRealograma: json['nombreRealograma'],
      idBitacora: json['idBitacora'],
    );
  }

  // Método para convertir un objeto Realograma a un mapa (JSON).
  Map<String, dynamic> toJson() {
    return {
      'idRealograma': idRealograma,
      'nombreRealograma': nombreRealograma,
      'idBitacora': idBitacora,
    };
  }
}
