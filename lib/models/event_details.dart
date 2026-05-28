class EventDetail {
  final int idTienda;
  final int evento;
  final String idCategoria;
  final String categoria;
  final String fechaMon;
  final double cumplimientoNvo;
  final double fnAdyacencia;
  final double fncalNivel;
  final double fnCalTramo;
  final double fnFtes; // Nuevo campo
  final double fnSurtido; // Nuevo campo
  final double secuencia;
  final double skusCumplen;
  final double skusNoCumplen;
  final int catalogo;
  final int monitoreados;
  final double monitoreadosPorc;
  final int faltanteTotal;
  final double faltanteTotalPorc;
  final int faltanteAnaquel;
  final double faltanteAnaquelPorc;
  final int teoricos;
  final double teoricosPorc;

  // Nuevos campos
  final int totalMueblesPlanos;
  final int totalMueblesReales;
  final int totalTramosPlanos;
  final int totalTramosReales;
  final int difTramos;

  //Campos para Reporte de Precios
  final int idBitacora;
  final int etiTotales;
  final double etiTotalesPorc;
  final int etiCorrectas;
  final double etiCorrectasPorc;
  final int etiIncorrectas;
  final double etiIncorrectasPorc;
  final int sinEti;
  final double sinEtiPorc;
  final int sinPromocion;
  final double sinPromocionPorc;
  final double etiquetasEncontradas;

  EventDetail(
      {required this.catalogo,
      required this.categoria,
      required this.cumplimientoNvo,
      required this.evento,
      required this.faltanteAnaquel,
      required this.faltanteAnaquelPorc,
      required this.faltanteTotal,
      required this.faltanteTotalPorc,
      required this.fechaMon,
      required this.fnAdyacencia,
      required this.fnCalTramo,
      required this.fncalNivel,
      required this.fnFtes,
      required this.fnSurtido,
      required this.secuencia,
      required this.skusCumplen,
      required this.skusNoCumplen,
      required this.idCategoria,
      required this.idTienda,
      required this.monitoreados,
      required this.monitoreadosPorc,
      required this.teoricos,
      required this.teoricosPorc,
      required this.idBitacora,
      required this.totalMueblesPlanos,
      required this.totalMueblesReales,
      required this.totalTramosPlanos,
      required this.totalTramosReales,
      required this.difTramos,
      required this.etiTotales,
      required this.etiTotalesPorc,
      required this.etiCorrectas,
      required this.etiCorrectasPorc,
      required this.etiIncorrectas,
      required this.etiIncorrectasPorc,
      required this.sinEti,
      required this.sinEtiPorc,
      required this.sinPromocion,
      required this.sinPromocionPorc,
      required this.etiquetasEncontradas});

  factory EventDetail.fromJson(Map<String, dynamic> json) {
    return EventDetail(
      catalogo: json['catalogo'],
      categoria: json['categoria'] ?? "",
      cumplimientoNvo: json['cumplimientoNvo'],
      evento: json['evento'],
      faltanteAnaquel: json['faltanteAnaquel'],
      faltanteAnaquelPorc: json['faltanteAnaquelPorc'],
      faltanteTotal: json['faltanteTotal'],
      faltanteTotalPorc: json['faltanteTotalPorc'],
      fechaMon: json['fechaMon'] ?? "",
      fnAdyacencia: json['fnAdyacencia'],
      fnCalTramo: json['fnCalTramo'],
      fncalNivel: json['fncalNivel'],
      fnFtes: json['fnFtes'],
      fnSurtido: json['fnSurtido'],
      secuencia: (json['secuencia'] as num?)?.toDouble() ?? 0.0,
      skusCumplen: (json['cumplen'] as num?)?.toDouble() ?? 0.0,
      skusNoCumplen: (json['noCumplen'] as num?)?.toDouble() ?? 0.0,
      idCategoria: json['idCategoria'] ?? "",
      idTienda: json['idTienda'],
      monitoreados: json['monitoreados'],
      monitoreadosPorc: (json['monitoreadosPorc'] as num?)?.toDouble() ?? 0.0,
      teoricos: json['teoricos'],
      teoricosPorc: json['teoricosPorc'],
      idBitacora: json["idBitacora"],
      totalMueblesPlanos: json['totalMueblesPlanos'],
      totalMueblesReales: json['totalMueblesReales'],
      totalTramosPlanos: json['totalTramosPlanos'],
      totalTramosReales: json['totalTramosReales'],
      difTramos: json['difTramos'],
      etiTotales: json["etiquetasTotales"],
      etiTotalesPorc: json["etiquetasTotalesPorcentaje"],
      etiCorrectas: json["etiquetasCorrectas"],
      etiCorrectasPorc: json["etiquetasCorrectasPorcentaje"]?.toDouble(),
      etiIncorrectas: json["etiquetasIncorrectas"],
      etiIncorrectasPorc: json["etiquetasIncorrectasPorcentaje"]?.toDouble(),
      sinEti: json["sinEtiqueta"],
      sinEtiPorc: json["sinEtiquetaPorcentaje"]?.toDouble(),
      sinPromocion: json["sinPromocion"],
      sinPromocionPorc: json["sinPromocionPorcentaje"]?.toDouble(),
      etiquetasEncontradas:
          (json['etiquetasEncontradas'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'catalogo': catalogo,
      'categoria': categoria,
      'cumplimientoNvo': cumplimientoNvo,
      'evento': evento,
      'faltanteAnaquel': faltanteAnaquel,
      'faltanteAnaquelPorc': faltanteAnaquelPorc,
      'faltanteTotal': faltanteTotal,
      'faltanteTotalPorc': faltanteTotalPorc,
      'fechaMon': fechaMon,
      'fnAdyacencia': fnAdyacencia,
      'fnCalTramo': fnCalTramo,
      'fncalNivel': fncalNivel,
      'fnFtes': fnFtes,
      'fnSurtido': fnSurtido,
      'secuencia': secuencia,
      'skusCumplen': skusCumplen,
      'skusNoCumplen': skusNoCumplen,
      'idCategoria': idCategoria,
      'idTienda': idTienda,
      'monitoreados': monitoreados,
      'monitoreadosPorc': monitoreadosPorc,
      'teoricos': teoricos,
      'teoricosPorc': teoricosPorc,
      "idBitacora": idBitacora,
      'totalMueblesPlanos': totalMueblesPlanos,
      'totalMueblesReales': totalMueblesReales,
      'totalTramosPlanos': totalTramosPlanos,
      'totalTramosReales': totalTramosReales,
      'difTramos': difTramos,
      "etiquetasTotales": etiTotales,
      "etiquetasTotalesPorcentaje": etiTotalesPorc,
      "etiquetasCorrectas": etiCorrectas,
      "etiquetasCorrectasPorcentaje": etiCorrectasPorc,
      "etiquetasIncorrectas": etiIncorrectas,
      "etiquetasIncorrectasPorcentaje": etiIncorrectasPorc,
      "sinPromocion": sinPromocion,
      "sinPromocionPorcentaje": sinPromocionPorc,
      "sinEtiqueta": sinEti,
      "sinEtiquetaPorcentaje": sinEtiPorc,
      "etiquetasEncontradas": etiquetasEncontradas
    };
  }
}
