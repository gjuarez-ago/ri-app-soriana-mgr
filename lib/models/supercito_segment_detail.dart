class SupercitoSegmentDetail {
 final int idRealograma;
  final int tramo;
  final int suaje;
  final int cajaAbierta;
  final int sinCaja;
  final String imagen;

  SupercitoSegmentDetail({
    required this.idRealograma,
    required this.tramo,
    required this.suaje,
    required this.cajaAbierta,
    required this.sinCaja,
    required this.imagen,
  });

  // Método para convertir JSON a objeto Dart
  factory SupercitoSegmentDetail.fromJson(Map<String, dynamic> json) {
    return SupercitoSegmentDetail(
      idRealograma: json['idRealograma'],
      tramo: json['tramo'],
      suaje: json['suaje'],              // Mapea como int
      cajaAbierta: json['cajaAbierta'],  // Mapea como int
      sinCaja: json['sinCaja'],          // Mapea como int
      imagen: json['imagen'],
    );
  }

  // Método para convertir objeto Dart a JSON
  Map<String, dynamic> toJson() {
    return {
      'idRealograma': idRealograma,
      'tramo': tramo,
      'suaje': suaje,              // Devuelve como int
      'cajaAbierta': cajaAbierta,  // Devuelve como int
      'sinCaja': sinCaja,          // Devuelve como int
    };
  }
}
