class SegmentsSupercitos {
  final int idRealograma; // Corresponde al campo "IdRealograma"
  final int tramo; // Corresponde al campo "tramo"
  final int estatusTramo; // Corresponde al campo "estatusTramo"
  final String imagen; // Corresponde al campo "imagen"
  final int conCajas; // Corresponde al campo "conCajas"
  final int sinCajas; // Corresponde al campo "sinCajas"
  final int conHuecos; // Corresponde al campo "conHuecos"

  SegmentsSupercitos({
    required this.idRealograma,
    required this.tramo,
    required this.estatusTramo,
    required this.imagen,
    required this.conCajas,
    required this.sinCajas,
    required this.conHuecos,
  });

  // Método para crear un objeto RealogramaDetalle desde un mapa (JSON).
  factory SegmentsSupercitos.fromJson(Map<String, dynamic> json) {
    return SegmentsSupercitos(
      idRealograma: json['idRealograma'],
      tramo: json['tramo'],
      estatusTramo: json['estatusTramo'],
      imagen: json['imagen'],
      conCajas: json['conCajas'],
      sinCajas: json['sinCajas'],
      conHuecos: json['conHuecos'],
    );
  }

  // Método para convertir un objeto RealogramaDetalle a un mapa (JSON).
  Map<String, dynamic> toJson() {
    return {
      'idRealograma': idRealograma,
      'tramo': tramo,
      'estatusTramo': estatusTramo,
      'conCajas': conCajas,
      'sinCajas': sinCajas,
      'conHuecos': conHuecos,
    };
  }
}
