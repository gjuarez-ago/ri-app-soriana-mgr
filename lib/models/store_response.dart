class StoreResponse {
  final int claveTienda;
  final int evento;
  final String? tienda;
  final int? idBitacora; // Campo opcional

  StoreResponse({
    required this.claveTienda,
    required this.evento,
    this.tienda,
    this.idBitacora, // Campo opcional en el constructor
  });

  // Constructor vacío opcional para simular @NoArgsConstructor
  StoreResponse.empty()
      : claveTienda = 0,
        evento = 0,
        idBitacora = null, // Inicialización como null
        tienda = null;

  // Método para copiar el objeto con nuevos valores opcional
  StoreResponse copyWith({
    int? claveTienda,
    int? evento,
    String? tienda,
    int? idBitacora,
  }) {
    return StoreResponse(
      claveTienda: claveTienda ?? this.claveTienda,
      evento: evento ?? this.evento,
      tienda: tienda ?? this.tienda,
      idBitacora: idBitacora ?? this.idBitacora, // Copia el valor de idBitacora o usa el actual
    );
  }

  // Método para crear una instancia desde un mapa
  factory StoreResponse.fromMap(Map<String, dynamic> map) {
    return StoreResponse(
      claveTienda: map['claveTienda'],
      evento: map['evento'],
      tienda: map['tienda'],
      idBitacora: map['idBitacora'], // Puede ser null
    );
  }

  // Método para convertir la instancia a un mapa
  Map<String, dynamic> toMap() {
    return {
      'claveTienda': claveTienda,
      'evento': evento,
      'tienda': tienda,
      'idBitacora': idBitacora, // Puede ser null
    };
  }
}
