class SupercitoSegmStatsDetail {
  
  final int idBitacora;
  final int idRealograma;
  final int tramo;
  final int niveles;
  final double espacioCajas;
  final double espacioTotalTramo;
  final int porcCajas;
  final int porcSinCajas;
  final String? imagen;

  SupercitoSegmStatsDetail({
    required this.idBitacora,
    required this.idRealograma,
    required this.tramo,
    required this.niveles,
    required this.espacioCajas,
    required this.espacioTotalTramo,
    required this.porcCajas,
    required this.porcSinCajas,
    required this.imagen,
  });

  factory SupercitoSegmStatsDetail.fromJson(Map<String, dynamic> json) {
    return SupercitoSegmStatsDetail(
      idBitacora: json['idBitacora'] as int,
      idRealograma: json['idRealograma'] as int,
      tramo: json['tramo'] as int,
      niveles: json['niveles'] as int,
      espacioCajas: (json['espacioCajas'] as num).toDouble(),
      espacioTotalTramo: (json['espacioTotalTramo'] as num).toDouble(),
      porcCajas: json['porcCajas'] as int,
      porcSinCajas: json['porcSinCajas'] as int,
      imagen: json['imagen'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idBitacora': idBitacora,
      'idRealograma': idRealograma,
      'tramo': tramo,
      'niveles': niveles,
      'espacioCajas': espacioCajas,
      'espacioTotalTramo': espacioTotalTramo,
      'porcCajas': porcCajas,
      'porcSinCajas': porcSinCajas,
    };
  }
}
