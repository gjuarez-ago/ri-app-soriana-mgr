class DetalleNivelResponse {
  final int? idRealograma;
  final int? tramo;
  final int? nivel;
  final String? upc;
  final int? secuencia;
  final String? sku;
  final String? prodName;

  DetalleNivelResponse({
    this.idRealograma,
    this.tramo,
    this.nivel,
    this.upc,
    this.secuencia,
    this.sku,
    this.prodName,
  });

  // Método para crear una instancia de la clase a partir de un JSON
  factory DetalleNivelResponse.fromJson(Map<String, dynamic> json) {
    return DetalleNivelResponse(
      idRealograma: json['idRealograma'] as int?,
      tramo: json['tramo'] as int?,
      nivel: json['nivel'] as int?,
      upc: json['upc'] as String?,
      secuencia: json['secuencia'] as int?,
      sku: json['sku'] as String?,
      prodName: json['prodName'] as String?,
    );
  }

  // Método para convertir una instancia de la clase a un JSON
  Map<String, dynamic> toJson() {
    return {
      'idRealograma': idRealograma,
      'tramo': tramo,
      'nivel': nivel,
      'upc': upc,
      'secuencia': secuencia,
      'sku': sku,
      'prodName': prodName,
    };
  }
}
