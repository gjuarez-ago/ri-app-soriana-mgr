class ViewDetailTramo {
  final String idCategoria;
  final int evento;
  final int idTienda;
  final int idRealograma;
  final int? tramo; // Campo opcional
  final int idReconocimiento; // Nuevo campo

  ViewDetailTramo({
    required this.idCategoria,
    required this.evento,
    required this.idTienda,
    required this.idRealograma,
    this.tramo,
    required this.idReconocimiento,
  });

  // Constructor vacío opcional para simular @NoArgsConstructor
  ViewDetailTramo.empty()
      : idCategoria = "",
        evento = 0,
        idTienda = 0,
        idRealograma = 0,
        tramo = null,
        idReconocimiento = 0;

  // Método para copiar el objeto con nuevos valores opcional
  ViewDetailTramo copyWith({
    String? idCategoria,
    int? evento,
    int? idTienda,
    int? idRealograma,
    int? tramo,
    int? idReconocimiento,
  }) {
    return ViewDetailTramo(
      idCategoria: idCategoria ?? this.idCategoria,
      evento: evento ?? this.evento,
      idTienda: idTienda ?? this.idTienda,
      idRealograma: idRealograma ?? this.idRealograma,
      tramo: tramo ?? this.tramo,
      idReconocimiento: idReconocimiento ?? this.idReconocimiento,
    );
  }

  // Método para crear una instancia desde un mapa
  factory ViewDetailTramo.fromMap(Map<String, dynamic> map) {
    return ViewDetailTramo(
      idCategoria: map['idCategoria'] ?? "",
      evento: map['evento'] ?? 0,
      idTienda: map['idTienda'] ?? 0,
      idRealograma: map['idRealograma'] ?? 0,
      tramo: map['tramo'],
      idReconocimiento: map['idReconocimiento'] ?? 0,
    );
  }

  // Método para convertir la instancia a un mapa
  Map<String, dynamic> toMap() {
    return {
      'idCategoria': idCategoria,
      'evento': evento,
      'idTienda': idTienda,
      'idRealograma': idRealograma,
      'tramo': tramo,
      'idReconocimiento': idReconocimiento,
    };
  }
}
