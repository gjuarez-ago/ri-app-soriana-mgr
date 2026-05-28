class CapturarFaltanteParams {
  int evento;
  String sku;
  String categoria;
  int idTienda;
  int idBitacora; // Nuevo campo agregado
  int idUbicacion;

  CapturarFaltanteParams({
    required this.evento,
    required this.sku,
    required this.idTienda,
    required this.categoria,
    required this.idBitacora, // Incluido en el constructor
    required this.idUbicacion
  });

  factory CapturarFaltanteParams.fromJson(Map<String, dynamic> json) {
    return CapturarFaltanteParams(
      evento: json['evento'],
      sku: json['sku'],
      idTienda: json['idTienda'],
      categoria: json['categoria'],
      idBitacora: json['idBitacora'], // Incluido en fromJson
      idUbicacion: json['idUbicacion'], // Incluido en fromJson
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evento': evento,
      'sku': sku,
      'idTienda': idTienda,
      'categoria': categoria,
      'idBitacora': idBitacora, // Incluido en toJson
            'idUbicacion': idUbicacion, // Incluido en toJson

    };
  }
}
