class GetIssuesParams {
  int evento;
  String idCategoria;
  int idTienda;
  int idBitacora; // Nuevo campo agregado

  GetIssuesParams({
    required this.evento,
    required this.idCategoria,
    required this.idTienda,
    required this.idBitacora, // Incluido en el constructor
  });

  factory GetIssuesParams.fromJson(Map<String, dynamic> json) {
    return GetIssuesParams(
      evento: json['evento'],
      idCategoria: json['idCategoria'],
      idTienda: json['idTienda'],
      idBitacora: json['idBitacora'], // Incluido en fromJson
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evento': evento,
      'idCategoria': idCategoria,
      'idTienda': idTienda,
      'idBitacora': idBitacora, // Incluido en toJson
    };
  }
}
