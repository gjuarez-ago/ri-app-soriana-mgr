class LayoutFaltantesParams {
  int idTienda;
  int evento;
  String idCategoria;
  int? idBitacora; // Usamos `int?` porque en Dart `Long` no existe, y los enteros grandes se manejan con `int`
  String upc;

  LayoutFaltantesParams({
    required this.idTienda,
    required this.evento,
    required this.idCategoria,
    this.idBitacora,
    required this.upc,
  });

  // Método para crear una instancia de LayoutFaltantesParams a partir de un Map (JSON)
  factory LayoutFaltantesParams.fromJson(Map<String, dynamic> json) {
    return LayoutFaltantesParams(
      idTienda: json['idTienda'],
      evento: json['evento'],
      idCategoria: json['idCategoria'],
      idBitacora: json['idBitacora'],
      upc: json['upc'],
    );
  }

  // Método para convertir una instancia de LayoutFaltantesParams en un Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'idTienda': idTienda,
      'evento': evento,
      'idCategoria': idCategoria,
      'idBitacora': idBitacora,
      'upc': upc,
    };
  }
}
