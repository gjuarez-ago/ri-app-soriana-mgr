class MisplacedProductsResponse {
    final int? totalFueraDelTramo;
    final int? totalFueraDeNivel;
    final int? totalFueraDeTramoYNivel;
    final int? totalFrentes;
    final List<MisplacedProduct>? lsFueraDelTramo;
    final List<MisplacedProduct>? lsFueraDelNivel;
    final List<MisplacedProduct>? lsFueraDelTramoNivel;
    final List<MisplacedProductFrente>? lsFrentes;

    MisplacedProductsResponse({
      required this.totalFueraDelTramo,
      required this.totalFueraDeNivel,
      required this.totalFueraDeTramoYNivel,
      required this.totalFrentes,
      required this.lsFueraDelTramo,
      required this.lsFueraDelNivel,
      required this.lsFueraDelTramoNivel,
      required this.lsFrentes,
    });

    factory MisplacedProductsResponse.fromJson(Map<String, dynamic> json) => MisplacedProductsResponse(
      totalFueraDelTramo: json["totalFueraDelTramo"],
      totalFueraDeNivel: json["totalFueraDeNivel"],
      totalFueraDeTramoYNivel: json["totalFueraDeTramoYNivel"],
      totalFrentes: json["totalFrentes"],
      lsFueraDelTramo: json["lsFueraDelTramo"] == null ? [] : List<MisplacedProduct>.from(json["lsFueraDelTramo"].map((x) => MisplacedProduct.fromJson(x))),
      lsFueraDelNivel: json["lsFueraDelNivel"] == null ? [] : List<MisplacedProduct>.from(json["lsFueraDelNivel"].map((x) => MisplacedProduct.fromJson(x))),
      lsFueraDelTramoNivel: json["lsFueraDelTramoNivel"] == null ? [] : List<MisplacedProduct>.from(json["lsFueraDelTramoNivel"].map((x) => MisplacedProduct.fromJson(x))),
      lsFrentes: json["lsFrentes"] == null ? [] : List<MisplacedProductFrente>.from(json["lsFrentes"].map((x) => MisplacedProductFrente.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
      "totalFueraDelTramo": totalFueraDelTramo,
      "totalFueraDeNivel": totalFueraDeNivel,
      "totalFueraDeTramoYNivel": totalFueraDeTramoYNivel,
      "totalFrentes": totalFrentes,
      "lsFueraDelTramo": lsFueraDelTramo == null ? [] : List<dynamic>.from(lsFueraDelTramo!.map((x) => x.toJson())),
      "lsFueraDelNivel": lsFueraDelNivel == null ? [] : List<dynamic>.from(lsFueraDelNivel!.map((x) => x.toJson())),
      "lsFueraDelTramoNivel": lsFueraDelTramoNivel == null ? [] : List<dynamic>.from(lsFueraDelTramoNivel!.map((x) => x.toJson())),
      "lsFrentes": lsFrentes == null ? [] : List<dynamic>.from(lsFrentes!.map((x) => x.toJson())),
    };

}

class MisplacedProductFrente {
    final List<String>? upc;
    final int? sku;
    final String? imagen;
    final String? nombreProducto;
    final int? frentesPlanograma;
    final int? frentesRealograma;

    MisplacedProductFrente({
        this.upc,
        this.sku,
        this.imagen,
        this.nombreProducto,
        this.frentesPlanograma,
        this.frentesRealograma,
    });

    factory MisplacedProductFrente.fromJson(Map<String, dynamic> json) {
        List<String> upcParsed = ['N/A'];
        if (json["upc"] != null) {
            if (json["upc"] is List) {
                upcParsed = List<String>.from(json["upc"].map((x) => x.toString()));
            } else {
                upcParsed = [json["upc"].toString()];
            }
        }
        
        return MisplacedProductFrente(
            upc: upcParsed,
            sku: json["sku"] is String ? int.tryParse(json["sku"]) : json["sku"],
            imagen: json["imagen"],
            nombreProducto: json["nombreProducto"],
            frentesPlanograma: json["frentesPlanograma"],
            frentesRealograma: json["frentesRealograma"],
        );
    }

    Map<String, dynamic> toJson() => {
        "upc": upc == null ? ['N/A'] : List<dynamic>.from(upc!.map((x) => x)),
        "sku": sku,
        "imagen": imagen,
        "nombreProducto": nombreProducto,
        "frentesPlanograma": frentesPlanograma,
        "frentesRealograma": frentesRealograma,
    };
}

class MisplacedProduct {
  final int? sku;
  final String? nombreProducto;
  final String? upc;
  final String? imagen;
  final String? clasificacion;
  final int frentesPlanograma;
  final int frentesRealograma;
  final List<Ubicacion> ubicacionActual;
  final List<Ubicacion> ubicacionCorrecta;

    MisplacedProduct({
      required this.sku,
      required this.nombreProducto,
      required this.upc,
      required this.imagen,
      required this.clasificacion,
      required this.frentesPlanograma,
      required this.frentesRealograma,
      required this.ubicacionActual,
      required this.ubicacionCorrecta,
    });

    factory MisplacedProduct.fromJson(Map<String, dynamic> json) {
      String upcParsed = "";
      if (json["upc"] != null) {
        upcParsed = json["upc"] is List ? json["upc"].join(", ") : json["upc"].toString();
      }
      return MisplacedProduct(
        sku: json["sku"] is String ? int.tryParse(json["sku"]) : json["sku"],
        nombreProducto: json["nombreProducto"],
        upc: upcParsed.isEmpty ? null : upcParsed,
        imagen: json["imagen"],
        clasificacion: json["clasificacion"],
        frentesPlanograma: json["frentesPlanograma"] ?? 0,
        frentesRealograma: json["frentesRealograma"] ?? 0,
        ubicacionActual: json["ubicacionActual"] == null ? [] : List<Ubicacion>.from(json["ubicacionActual"].map((x) => Ubicacion.fromJson(x))),
        ubicacionCorrecta: json["ubicacionCorrecta"] == null ? [] : List<Ubicacion>.from(json["ubicacionCorrecta"].map((x) => Ubicacion.fromJson(x))),
      );
    }

    Map<String, dynamic> toJson() => {
      "sku": sku,
      "nombreProducto": nombreProducto,
      "upc": upc,
      "imagen": imagen,
      "clasificacion": clasificacion,
      "frentesPlanograma": frentesPlanograma,
      "frentesRealograma": frentesRealograma,
      "ubicacionActual": List<dynamic>.from(ubicacionActual.map((x) => x.toJson())),
      "ubicacionCorrecta": List<dynamic>.from(ubicacionCorrecta.map((x) => x.toJson())),
    };

}

class Ubicacion {
  final int tramo;
  final int nivel;
  final int secuencia;
  final int frentes;
  final String mueble; // 👈 nuevo campo

  Ubicacion({
    required this.tramo,
    required this.nivel,
    required this.secuencia,
    required this.frentes,
    required this.mueble, // 👈 agregar al constructor
  });

  factory Ubicacion.fromJson(Map<String, dynamic> json) => Ubicacion(
        tramo: json["tramo"],
        nivel: json["nivel"],
        secuencia: json["secuencia"],
        frentes: json["frentes"],
        mueble: json["nombreMueble"] ?? "", // 👈 evitar null
      );

  Map<String, dynamic> toJson() => {
        "tramo": tramo,
        "nivel": nivel,
        "secuencia": secuencia,
        "frentes": frentes,
        "nombreMueble": mueble, // 👈 agregar al json
      };
}
