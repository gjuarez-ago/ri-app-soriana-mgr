class LayoutFaltanteResponse {
  
  String? nombrePlanograma;
  int? fiPlnIdMod;
  int? fiSegmento;
  int? fiNoCharola;
  int? fiOrden;
  String? fiSku;
  int? fiFtes;
  String? producto;

  LayoutFaltanteResponse({
    this.nombrePlanograma,
    this.fiPlnIdMod,
    this.fiSegmento,
    this.fiNoCharola,
    this.fiOrden,
    this.fiSku,
    this.fiFtes,
    this.producto,
  });

  // Método para crear una instancia de LayoutFaltanteResponse a partir de un Map (JSON)
  factory LayoutFaltanteResponse.fromJson(Map<String, dynamic> json) {
    return LayoutFaltanteResponse(
      nombrePlanograma: json['nombrePlanograma'],
      fiPlnIdMod: json['fiPlnIdMod'],
      fiSegmento: json['fiSegmento'],
      fiNoCharola: json['fiNoCharola'],
      fiOrden: json['fiOrden'],
      fiSku: json['fiSku'],
      fiFtes: json['fiFtes'],
      producto: json['producto'],
    );
  }

  // Método para convertir una instancia de LayoutFaltanteResponse en un Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'nombrePlanograma': nombrePlanograma,
      'fiPlnIdMod': fiPlnIdMod,
      'fiSegmento': fiSegmento,
      'fiNoCharola': fiNoCharola,
      'fiOrden': fiOrden,
      'fiSku': fiSku,
      'fiFtes': fiFtes,
      'producto': producto,
    };
  }
}