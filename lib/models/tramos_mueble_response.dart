class TramosMuebleResponse {
  final int idRealograma;
  final int idReconocimiento;
  final String? imagen;
  final int niveles;
  final int tramo;

  TramosMuebleResponse({
    required this.idRealograma,
    required this.idReconocimiento,
    required this.imagen,
    required this.niveles,
    required this.tramo,
  });

  // Método para crear una instancia de TramosMuebleResponse a partir de un JSON
  factory TramosMuebleResponse.fromJson(Map<String, dynamic> json) {
    return TramosMuebleResponse(
      idRealograma: json['idRealograma'],
      idReconocimiento: json['idReconocimiento'],
      imagen: json['imagen'],
      niveles: json['niveles'],
      tramo: json['tramo'],
    );
  }

  // Método para convertir una instancia de TramosMuebleResponse a JSON
  Map<String, dynamic> toJson() {
    return {
      'idRealograma': idRealograma,
      'idReconocimiento': idReconocimiento,
      'niveles': niveles,
      'tramo': tramo,
    };
  }
}
