class SearchModelHelperSupercito {
  final int idRealograma;
  final int tramo;
  final String? mueble;
  final int idTienda;
  final int evento;
  final int idBitacora;
  final String categoria; // Nuevo campo agregado

  // Constructor
  SearchModelHelperSupercito({
    required this.idRealograma,
    required this.tramo,
    this.mueble,
    required this.idTienda,
    required this.evento,
    required this.idBitacora,
    required this.categoria,
  });

  // Método para crear una instancia desde un mapa JSON
  factory SearchModelHelperSupercito.fromJson(Map<String, dynamic> json) {
    return SearchModelHelperSupercito(
      idRealograma: json['idRealograma'],
      tramo: json['tramo'],
      mueble: json['mueble'],
      idTienda: json['idTienda'],
      evento: json['evento'],
      idBitacora: json['idBitacora'],
      categoria: json['categoria'],
    );
  }

  // Método para convertir la instancia en un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'idRealograma': idRealograma,
      'tramo': tramo,
      'mueble': mueble,
      'idTienda': idTienda,
      'evento': evento,
      'idBitacora': idBitacora,
      'categoria': categoria,
    };
  }
}
