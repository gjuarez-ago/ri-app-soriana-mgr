class TiendaLResponse {
  final int? idTienda;
  final String? tienda;
  final int? idFormato;
  final String? idCategoriaPln;
  final bool? prioritaria;
  final String? categoria;
  final bool? auditado;
  final int? diaMes;
  final double? cumplimiento;       // Nuevo campo
  final double? faltante;        // Nuevo campo
  final bool? faltanteMayor;     // Nuevo campo
  final int? grupo;           // Nuevo campo

  TiendaLResponse({
    this.idTienda,
    this.tienda,
    this.idFormato,
    this.idCategoriaPln,
    this.prioritaria,
    this.categoria,
    this.auditado,
    this.diaMes,
    this.cumplimiento,       // Nuevo campo en constructor
    this.faltante,           // Nuevo campo en constructor
    this.faltanteMayor,      // Nuevo campo en constructor
    this.grupo,             // Nuevo campo en constructor
  });

  factory TiendaLResponse.fromJson(Map<String, dynamic> json) {
    return TiendaLResponse(
      idTienda: json['idTienda'] as int?,
      tienda: json['tienda'] as String?,
      idFormato: json['idFormato'] as int?,
      idCategoriaPln: json['idCategoriaPln']?.toString(),
      prioritaria: json['prioritaria'] as bool?,
      categoria: json['categoria'] as String?,
      auditado: json['auditado'] as bool?,
      diaMes: json['diaMes'] as int?,
      cumplimiento: json['cumplimiento'] as double?,          // Nuevo campo en fromJson
      faltante: json['faltante'] as double?,               // Nuevo campo en fromJson
      faltanteMayor: json['faltanteMayor'] as bool?,       // Nuevo campo en fromJson
      grupo: json['grupo'] as int?,                     // Nuevo campo en fromJson
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdTienda': idTienda,
      'tienda': tienda,
      'IdFormato': idFormato,
      'idCategoriaPln': idCategoriaPln,
      'prioritaria': prioritaria,
      'categoria': categoria,
      'auditado': auditado,
      'diaMes': diaMes,
      'cumplimiento': cumplimiento,        // Nuevo campo en toJson
      'faltante': faltante,                // Nuevo campo en toJson
      'faltanteMayor': faltanteMayor,      // Nuevo campo en toJson
      'grupo': grupo,                     // Nuevo campo en toJson
    };
  }
}