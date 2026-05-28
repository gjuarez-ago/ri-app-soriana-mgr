class SupercitoSegmentEventos {
  final int idBitacora;
  final int claveTienda;
  final int evento;
  final String idCategoria;
  final double espacioCajas;
  final int espacioTotalMueble;
  final int porcCajas;
  final int porcSinCajas;
  final DateTime fechaAuditoria;
  final String fechaMonitoreo;

  final int catalogo;
  final int cumplimientoNvo;
  final bool fbMostrarFA;
  final bool fbMostrarPLN;
  final int gap;
  final int monitoreados;
  final int teoricos;

  SupercitoSegmentEventos({
    required this.idBitacora,
    required this.claveTienda,
    required this.evento,
    required this.idCategoria,
    required this.espacioCajas,
    required this.espacioTotalMueble,
    required this.porcCajas,
    required this.porcSinCajas,
    required this.fechaAuditoria,
    required this.fechaMonitoreo,
    required this.catalogo,
    required this.cumplimientoNvo,
    required this.fbMostrarFA,
    required this.fbMostrarPLN,
    required this.gap,
    required this.monitoreados,
    required this.teoricos,
  });

  factory SupercitoSegmentEventos.fromJson(Map<String, dynamic> json) {
    return SupercitoSegmentEventos(
      idBitacora: _toInt(json['idBitacora']),
      claveTienda: _toInt(json['claveTienda']),
      evento: _toInt(json['evento']),
      idCategoria: json['idCategoria']?.toString() ?? '',
      espacioCajas: _toDouble(json['espacioCajas']),
      espacioTotalMueble: _toInt(json['espacioTotalMueble']),
      porcCajas: _toInt(json['porcCajas']),
      porcSinCajas: _toInt(json['porcSinCajas']),
      fechaAuditoria: DateTime.parse(json['fechaAuditoria']),
      fechaMonitoreo: json['fechaMonitoreo'] ?? '',
      catalogo: _toInt(json['catalogo']),
      cumplimientoNvo: _toInt(json['cumplimientoNvo']),
      fbMostrarFA: json['fbMostrarFA'] ?? false,
      fbMostrarPLN: json['fbMostrarPLN'] ?? false,
      gap: _toInt(json['gap']),
      monitoreados: _toInt(json['monitoreados']),
      teoricos: _toInt(json['teoricos']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idBitacora': idBitacora,
      'claveTienda': claveTienda,
      'evento': evento,
      'idCategoria': idCategoria,
      'espacioCajas': espacioCajas,
      'espacioTotalMueble': espacioTotalMueble,
      'porcCajas': porcCajas,
      'porcSinCajas': porcSinCajas,
      'fechaAuditoria': fechaAuditoria.toIso8601String(),
      'fechaMonitoreo': fechaMonitoreo,
      'catalogo': catalogo,
      'cumplimientoNvo': cumplimientoNvo,
      'fbMostrarFA': fbMostrarFA,
      'fbMostrarPLN': fbMostrarPLN,
      'gap': gap,
      'monitoreados': monitoreados,
      'teoricos': teoricos,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
