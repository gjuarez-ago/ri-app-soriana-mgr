class FaltanteResponse {
  final bool esTeorico;
  final int existencia;
  final String? fcCategoriaPln;
  final String? fcSubClase;
  final String? nombreProd;
  final String? sku;
  final String? upc;
  final String? rutaPublica;
  final int vecesFaltante;
  final String? tipoResurtido;
  final String? metodoResurtido;
  final String? proveedor;
  final String? fechaAlmacen;
  final String? numPalet;
  final bool conUbicacion;
  final int eventosMaximoFaltante;

  FaltanteResponse({
    required this.esTeorico,
    required this.existencia,
    this.fcCategoriaPln,
    this.fcSubClase,
    this.nombreProd,
    this.sku,
    this.upc,
    this.rutaPublica,
    required this.vecesFaltante,
    this.tipoResurtido,
    this.metodoResurtido,
    this.proveedor,
    this.fechaAlmacen,
    this.numPalet,
    required this.conUbicacion,
    required this.eventosMaximoFaltante,
  });

  factory FaltanteResponse.fromJson(Map<String, dynamic> json) {
    return FaltanteResponse(
      esTeorico: json['esTeorico'],
      existencia: json['existencia'],
      fcCategoriaPln: json['fcCategoriaPln'],
      fcSubClase: json['fcSubClase'],
      nombreProd: json['nombreProd'],
      sku: json['sku'],
      upc: json['upc'],
      rutaPublica: json['rutaPublica'],
      vecesFaltante: json['vecesFaltante'],
      tipoResurtido: json['tipoResurtido'],
      metodoResurtido: json['metodoResurtido'],
      proveedor: json['proveedor'],
      fechaAlmacen: json['fechaAlmacen'],
      numPalet: json['numPalet'],
      conUbicacion: json['conUbicacion'],
      eventosMaximoFaltante: json['eventosMaximoFaltante'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'esTeorico': esTeorico,
      'existencia': existencia,
      'fcCategoriaPln': fcCategoriaPln,
      'fcSubClase': fcSubClase,
      'nombreProd': nombreProd,
      'sku': sku,
      'upc': upc,
      'rutaPublica': rutaPublica,
      'vecesFaltante': vecesFaltante,
      'tipoResurtido': tipoResurtido,
      'metodoResurtido': metodoResurtido,
      'proveedor': proveedor,
      'fechaAlmacen': fechaAlmacen,
      'numPalet': numPalet,
      'conUbicacion': conUbicacion,
      'eventosMaximoFaltante': eventosMaximoFaltante,
    };
  }

  static List<FaltanteResponse> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => FaltanteResponse.fromJson(json)).toList();
  }
}
