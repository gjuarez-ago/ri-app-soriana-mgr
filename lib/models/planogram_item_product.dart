class PlanogramaItemResponse {
  final int idTienda;
  final int idPlanograma;
  final String fcCategoria;
  final String categoria;
  final String nombrePlanograma;
  final int fiSegmento;
  final int fiNoCharola;
  final int fiFtes;
  final int fiOrden;
  final String fiSku;
  final String fcUpc;
  final String prodName;

  PlanogramaItemResponse({
    required this.idTienda,
    required this.idPlanograma,
    required this.fcCategoria,
    required this.categoria,
    required this.nombrePlanograma,
    required this.fiSegmento,
    required this.fiNoCharola,
    required this.fiFtes,
    required this.fiOrden,
    required this.fiSku,
    required this.fcUpc,
    required this.prodName,
  });

  factory PlanogramaItemResponse.fromJson(Map<String, dynamic> json) {
    return PlanogramaItemResponse(
      idTienda: json['IdTienda'] ?? 0,
      idPlanograma: json['IdPlanograma'] ?? 0,
      fcCategoria: json['fcCategoria'] ?? 0,
      categoria: json['Categoria'] ?? '',
      nombrePlanograma: json['NombrePlanograma'] ?? '',
      fiSegmento: json['fiSegmento'] ?? 0,
      fiNoCharola: json['fiNoCharola'] ?? 0,
      fiFtes: json['fiFtes'] ?? 0,
      fiOrden: json['fiOrden'] ?? 0,
      fiSku: json['fiSKU'] ?? 0,
      fcUpc: json['fcUpc'] ?? '',
      prodName: json['PROD_NAME'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdTienda': idTienda,
      'IdPlanograma': idPlanograma,
      'fcCategoria': fcCategoria,
      'Categoria': categoria,
      'NombrePlanograma': nombrePlanograma,
      'fiSegmento': fiSegmento,
      'fiNoCharola': fiNoCharola,
      'fiFtes': fiFtes,
      'fiOrden': fiOrden,
      'fiSKU': fiSku,
      'fcUpc': fcUpc,
      'PROD_NAME': prodName,
    };
  }
}
