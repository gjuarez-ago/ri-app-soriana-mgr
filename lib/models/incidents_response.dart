class IncidentsResponse {
  final int idRealograma;
  final int idReconocimiento;
  final int idRegistro;
  final String imagen;
  final int nivel;
  final String nombreRealograma;
  final String productName;
  final int secuencia;
  final int tramo;
   String upc;
   bool? escaneado; // Hacer opcional

  IncidentsResponse({
    required this.idRealograma,
    required this.idReconocimiento,
    required this.idRegistro,
    required this.imagen,
    required this.nivel,
    required this.nombreRealograma,
    required this.productName,
    required this.secuencia,
    required this.tramo,
    required this.upc,
    this.escaneado, // No es obligatorio
  });

  factory IncidentsResponse.fromJson(Map<String, dynamic> json) {
    return IncidentsResponse(
      idRealograma: json['idRealograma'],
      idReconocimiento: json['idReconocimiento'],
      idRegistro: json['idRegistro'],
      imagen: json['imagen'] ?? '', // Valor predeterminado en caso de ausencia
      nivel: json['nivel'] ?? 0, // Valor predeterminado en caso de ausencia
      nombreRealograma: json['nombreRealograma'] ?? '', // Valor predeterminado en caso de ausencia
      productName: json['productName'] ?? '', // Valor predeterminado en caso de ausencia
      secuencia: json['secuencia'] ?? 0, // Valor predeterminado en caso de ausencia
      tramo: json['tramo'] ?? 0, // Valor predeterminado en caso de ausencia
      upc: json['upc'] ?? '', // Valor predeterminado en caso de ausencia
      escaneado: json['escaneado'] ?? false, // Valor predeterminado en caso de ausencia
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idRealograma': idRealograma,
      'idReconocimiento': idReconocimiento,
      'idRegistro': idRegistro,
      'nivel': nivel,
      'nombreRealograma': nombreRealograma,
      'productName': productName,
      'secuencia': secuencia,
      'tramo': tramo,
      'upc': upc,
      'escaneado': escaneado ?? false, // Valor por defecto
    };
  }
}
