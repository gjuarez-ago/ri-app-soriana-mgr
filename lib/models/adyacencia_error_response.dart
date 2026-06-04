class AdyacenciaErrorResponse {
  final int idBitacora;
  final int fiPlnIdMod;
  final int fiNoSegmento;
  final int fiNoCharola;
  final String fiSku;
  final String fcUPC;
  final String nombreProducto;
  final String rutaPublica;
  final int fiOrden;
  final String adyIzquierdaPln;
  final String nombreIzquierdaPln;
  final String imgIzquierdaPln;
  final String upcIzquierdaPln;
  final String adyDerechaPln;
  final String nombreDerechaPln;
  final String imgDerechaPln;
  final String upcDerechaPln;
  final String adyIzqActual;
  final String nombreIzqActual;
  final String imgIzqActual;
  final String upcIzqActual;
  final String adyDerActual;
  final String nombreDerActual;
  final String imgDerActual;
  final String upcDerActual;

  AdyacenciaErrorResponse({
    required this.idBitacora,
    required this.fiPlnIdMod,
    required this.fiNoSegmento,
    required this.fiNoCharola,
    required this.fiSku,
    required this.fcUPC,
    required this.nombreProducto,
    required this.rutaPublica,
    required this.fiOrden,
    required this.adyIzquierdaPln,
    required this.nombreIzquierdaPln,
    required this.imgIzquierdaPln,
    required this.upcIzquierdaPln,
    required this.adyDerechaPln,
    required this.nombreDerechaPln,
    required this.imgDerechaPln,
    required this.upcDerechaPln,
    required this.adyIzqActual,
    required this.nombreIzqActual,
    required this.imgIzqActual,
    required this.upcIzqActual,
    required this.adyDerActual,
    required this.nombreDerActual,
    required this.imgDerActual,
    required this.upcDerActual,
  });

  factory AdyacenciaErrorResponse.fromJson(Map<String, dynamic> json) {
    return AdyacenciaErrorResponse(
      idBitacora: json['idBitacora'] ?? 0,
      fiPlnIdMod: json['fiPlnIdMod'] ?? 0,
      fiNoSegmento: json['fiNoSegmento'] ?? 0,
      fiNoCharola: json['fiNoCharola'] ?? 0,
      fiSku: json['fiSku'] ?? 0,
      fcUPC: json['fcUPC'] ?? '',
      nombreProducto: json['nombreProducto'] ?? '',
      rutaPublica: json['rutaPublica'] ?? '',
      fiOrden: json['fiOrden'] ?? 0,
      adyIzquierdaPln: json['adyIzquierdaPln'] ?? '',
      nombreIzquierdaPln: json['nombreIzquierdaPln'] ?? '',
      imgIzquierdaPln: json['imgIzquierdaPln'] ?? '',
      upcIzquierdaPln: json['upcIzquierdaPln'] ?? '',
      adyDerechaPln: json['adyDerechaPln'] ?? '',
      nombreDerechaPln: json['nombreDerechaPln'] ?? '',
      imgDerechaPln: json['imgDerechaPln'] ?? '',
      upcDerechaPln: json['upcDerechaPln'] ?? '',
      adyIzqActual: json['adyIzqActual'] ?? '',
      nombreIzqActual: json['nombreIzqActual'] ?? '',
      imgIzqActual: json['imgIzqActual'] ?? '',
      upcIzqActual: json['upcIzqActual'] ?? '',
      adyDerActual: json['adyDerActual'] ?? '',
      nombreDerActual: json['nombreDerActual'] ?? '',
      imgDerActual: json['imgDerActual'] ?? '',
      upcDerActual: json['upcDerActual'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idBitacora': idBitacora,
      'fiPlnIdMod': fiPlnIdMod,
      'fiNoSegmento': fiNoSegmento,
      'fiNoCharola': fiNoCharola,
      'fiSku': fiSku,
      'fcUPC': fcUPC,
      'nombreProducto': nombreProducto,
      'rutaPublica': rutaPublica,
      'fiOrden': fiOrden,
      'adyIzquierdaPln': adyIzquierdaPln,
      'nombreIzquierdaPln': nombreIzquierdaPln,
      'imgIzquierdaPln': imgIzquierdaPln,
      'upcIzquierdaPln': upcIzquierdaPln,
      'adyDerechaPln': adyDerechaPln,
      'nombreDerechaPln': nombreDerechaPln,
      'imgDerechaPln': imgDerechaPln,
      'upcDerechaPln': upcDerechaPln,
      'adyIzqActual': adyIzqActual,
      'nombreIzqActual': nombreIzqActual,
      'imgIzqActual': imgIzqActual,
      'upcIzqActual': upcIzqActual,
      'adyDerActual': adyDerActual,
      'nombreDerActual': nombreDerActual,
      'imgDerActual': imgDerActual,
      'upcDerActual': upcDerActual,
    };
  }
}
