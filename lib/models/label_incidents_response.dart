class IncidenciasEtiquetasResponse {
    final List<Etiqueta>? incorrectas;
    final List<Etiqueta>? sinEtiqueta;
    final List<Etiqueta>? sinPromocion;

    IncidenciasEtiquetasResponse({
        this.incorrectas,
        this.sinEtiqueta,
        this.sinPromocion,
    });

    factory IncidenciasEtiquetasResponse.fromJson(Map<String, dynamic> json) => IncidenciasEtiquetasResponse(
        incorrectas: json["etiquetasIncorrectas"] == null ? [] : List<Etiqueta>.from(json["etiquetasIncorrectas"]!.map((x) => Etiqueta.fromJson(x))),
        sinEtiqueta: json["sinEtiquetas"] == null ? [] : List<Etiqueta>.from(json["sinEtiquetas"]!.map((x) => Etiqueta.fromJson(x))),
        sinPromocion: json["sinPromocion"] == null ? [] : List<Etiqueta>.from(json["sinPromocion"]!.map((x) => Etiqueta.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "etiquetasIncorrectas": incorrectas == null ? [] : List<dynamic>.from(incorrectas!.map((x) => x.toJson())),
        "sinEtiquetas": sinEtiqueta == null ? [] : List<dynamic>.from(sinEtiqueta!.map((x) => x.toJson())),
        "sinPromocion": sinPromocion == null ? [] : List<dynamic>.from(sinPromocion!.map((x) => x.toJson())),
    };

    @override
    String toString() {
      return 'IncidenciasEtiquetasResponse('
          'incorrectas: ${incorrectas?.length ?? 0}, '
          'sinEtiqueta: ${sinEtiqueta?.length ?? 0}, '
          'sinPromocion: ${sinPromocion?.length ?? 0}'
          ')';
    }
}

class Etiqueta {
  final String? upc;
  final int? sku;
  final String? nombreProducto;
  final int? tramo;
  final int? nivel;
  final int? secuencia;
  final double? precioAuditado;
  final double? precioCorrecto;
  final double? precioRegular; // <-- Nuevo campo
  final double? precioPromocion; // <-- Nuevo campo
  final String? imagen;
  final String? categorizacion;

  bool get noLabel => (categorizacion ?? '') == 'SIN ETIQUETA';

  Etiqueta({
    required this.upc,
    required this.sku,
    required this.nombreProducto,
    required this.tramo,
    required this.nivel,
    required this.secuencia,
    required this.precioAuditado,
    required this.precioCorrecto,
    required this.precioRegular, // <-- Nuevo parámetro
    required this.precioPromocion, // <-- Nuevo parámetro
    required this.imagen,
    required this.categorizacion,
  });

  factory Etiqueta.fromJson(Map<String, dynamic> json) => Etiqueta(
        upc: json["upc"],
        sku: json["sku"],
        nombreProducto: json["nombreProducto"],
        tramo: json["tramo"],
        nivel: json["nivel"],
        secuencia: json["secuencia"],
        precioAuditado: json["precioAuditado"]?.toDouble(),
        precioCorrecto: json["precioVigente"]?.toDouble(),
        precioRegular: json["precioRegular"]?.toDouble(), // <-- Nuevo campo
        precioPromocion: json["precioPromocion"]?.toDouble(), // <-- Nuevo campo
        imagen: json["imagen"],
        categorizacion: json["categorizacion"],
      );

  Map<String, dynamic> toJson() => {
        "upc": upc,
        "sku": sku,
        "nombreProducto": nombreProducto,
        "tramo": tramo,
        "nivel": nivel,
        "secuencia": secuencia,
        "precioAuditado": precioAuditado,
        "precioVigente": precioCorrecto,
        "precioRegular": precioRegular, // <-- Nuevo campo
        "precioPromocion": precioPromocion, // <-- Nuevo campo
        "imagen": imagen,
        "categorizacion": categorizacion,
      };

  @override
  String toString() {
    return 'Etiqueta('
        'upc: $upc, '
        'sku: $sku, '
        'nombreProducto: $nombreProducto, '
        'tramo: $tramo, '
        'nivel: $nivel, '
        'secuencia: $secuencia, '
        'precioAuditado: $precioAuditado, '
        'precioCorrecto: $precioCorrecto, '
        'precioRegular: $precioRegular, '
        'precioPromocion: $precioPromocion, '
        'categorizacion: $categorizacion'
        ')';
  }

}
