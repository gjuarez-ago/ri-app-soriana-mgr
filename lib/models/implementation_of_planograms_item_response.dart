class ImplementationOfPlanogramsItemResponse {
  final int? id;
  final String? idCategoria;
  final String? categoria;
  final String? fechaInicio;
  final String? fechaCortaInicio;
  final String? fechaFin;
  final String? fechaCortaFin;
  final String? estatus;

  ImplementationOfPlanogramsItemResponse({
    this.id,
    this.idCategoria,
    this.categoria,
    this.fechaInicio,
    this.fechaCortaInicio,
    this.fechaFin,
    this.fechaCortaFin,
    this.estatus
  });

  factory ImplementationOfPlanogramsItemResponse.fromJson(Map<String, dynamic> json) => ImplementationOfPlanogramsItemResponse(
    id: json["id"] ?? 0,
    idCategoria: json["idCategoria"] ?? '',
    categoria: json["categoria"] ?? '',
    fechaInicio: json["fechaInicio"] ?? '',
    fechaCortaInicio: json["fechaCortaInicio"] ?? '',
    fechaFin: json["fechaFin"] ?? '',
    fechaCortaFin: json["fechaCortaFin"] ?? '',
    estatus: json["estatus"] ?? ''
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "idCategoria": idCategoria,
    "categoria": categoria,
    "fechaInicio": fechaInicio,
    "fechaCortaInicio": fechaCortaInicio,
    "fechaFin": fechaFin,
    "fechaCortaFin": fechaCortaFin,
    "estatus": estatus
  };

  @override
  String toString() {
    return 'ImplementationOfPlanogramsItemResponse('
        'id: $id, '
        'idCategoria: $idCategoria, '
        'categoria: $categoria, '
        'fechaInicio: $fechaInicio, '
        'fechaCortaInicio: $fechaCortaInicio, '
        'fechaFin: $fechaFin, '
        'fechaCortaFin: $fechaCortaFin, '
        'estatus: $estatus'
        ')';
  }
}