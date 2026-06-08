class ProductoMalAcomodadoSecuencia {
  final int idBitacora;
  final String fiSku;
  final int tramo;
  final int nivel;
  final int secuencia;
  final String nombreProducto;
  final String upc;
  final String imagen;

  ProductoMalAcomodadoSecuencia({
    required this.idBitacora,
    required this.fiSku,
    required this.tramo,
    required this.nivel,
    required this.secuencia,
    required this.nombreProducto,
    required this.upc,
    required this.imagen,
  });

  factory ProductoMalAcomodadoSecuencia.fromJson(Map<String, dynamic> json) {
    String upcParsed = "";
    if (json['upc'] != null) {
      upcParsed =
          json['upc'] is List ? json['upc'].join(', ') : json['upc'].toString();
    }

    return ProductoMalAcomodadoSecuencia(
      idBitacora: json['idBitacora'] ?? 0,
      fiSku: json['fiSku']?.toString() ?? '',
      tramo: json['tramo'] ?? 0,
      nivel: json['nivel'] ?? 0,
      secuencia: json['secuencia'] ?? 0,
      nombreProducto: json['nombreProducto'] ?? '',
      upc: upcParsed,
      imagen: json['imagen'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idBitacora': idBitacora,
      'fiSku': fiSku,
      'tramo': tramo,
      'nivel': nivel,
      'secuencia': secuencia,
      'nombreProducto': nombreProducto,
      'upc': upc,
      'imagen': imagen,
    };
  }
}
