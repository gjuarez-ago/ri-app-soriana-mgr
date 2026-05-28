class ViewDetailHelper {
  final String idCategoria;
  final int evento;
  final int idTienda;
  final int idRealograma;
  final int idBitacora; // Nuevo campo agregado

  ViewDetailHelper({
    required this.idCategoria,
    required this.evento,
    required this.idTienda,
    required this.idRealograma,
    required this.idBitacora, // Incluido en el constructor
  });

  // Constructor vacío opcional para simular @NoArgsConstructor
  ViewDetailHelper.empty()
      : idCategoria = "",
        evento = 0,
        idTienda = 0,
        idRealograma = 0,
        idBitacora = 0; // Incluido en el constructor vacío

  // Método para copiar el objeto con nuevos valores opcional
  ViewDetailHelper copyWith({
    String? idCategoria,
    int? evento,
    int? idTienda,
    int? idRealograma,
    int? idBitacora, // Incluido en el copyWith
  }) {
    return ViewDetailHelper(
      idCategoria: idCategoria ?? this.idCategoria,
      evento: evento ?? this.evento,
      idTienda: idTienda ?? this.idTienda,
      idRealograma: idRealograma ?? this.idRealograma,
      idBitacora: idBitacora ?? this.idBitacora, // Incluido en el return
    );
  }

  // Método para crear una instancia desde un mapa
  factory ViewDetailHelper.fromMap(Map<String, dynamic> map) {
    return ViewDetailHelper(
      idCategoria: map['idCategoria'] ?? "",
      evento: map['evento'] ?? 0,
      idTienda: map['idTienda'] ?? 0,
      idRealograma: map['idRealograma'] ?? 0,
      idBitacora: map['idBitacora'] ?? 0, // Incluido en fromMap
    );
  }

  // Método para convertir la instancia a un mapa
  Map<String, dynamic> toMap() {
    return {
      'idCategoria': idCategoria,
      'evento': evento,
      'idTienda': idTienda,
      'idRealograma': idRealograma,
      'idBitacora': idBitacora, // Incluido en toMap
    };
  }
}
