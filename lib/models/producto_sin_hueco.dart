class ProductoSinHueco {
  final int idBitacora;
  final String fiSku;
  final String nombreProducto;
  final String upc;
  final String imagen;

  ProductoSinHueco({
    required this.idBitacora,
    required this.fiSku,
    required this.nombreProducto,
    required this.upc,
    required this.imagen,
  });
  factory ProductoSinHueco.fromJson(Map<String, dynamic> json) {
    String upcParsed = "";
    if (json['upc'] != null) {
      upcParsed = json['upc'] is List ? json['upc'].join(', ') : json['upc'].toString();
    }
    return ProductoSinHueco(
      idBitacora: json['idBitacora'] ?? 0,
      fiSku: json['fiSku'] ?? 0,
      nombreProducto: json['nombreProducto'] ?? '',
      upc: upcParsed,
      imagen: json['imagen'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idBitacora': idBitacora,
      'fiSku': fiSku,
      'nombreProducto': nombreProducto,
      'upc': upc,
      'imagen': imagen,
    };
  }
}
