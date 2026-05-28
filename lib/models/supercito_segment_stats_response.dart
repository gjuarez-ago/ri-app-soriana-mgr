class SupercitoSegmentStatsResponse {
  final int idBitacora;
  final int idTienda;
  final int evento;
  final int totalNiveles;
  final int suaje;
  final int cajaAbierta;
  final int sinCaja;
  final double porSuaje;
  final double porCajaAbierta;
  final double porSinCaja;

  // Constructor
  SupercitoSegmentStatsResponse({
    required this.idBitacora,
    required this.idTienda,
    required this.evento,
    required this.totalNiveles,
    required this.suaje,
    required this.cajaAbierta,
    required this.sinCaja,
    required this.porSuaje,
    required this.porCajaAbierta,
    required this.porSinCaja,
  });

  // Factory constructor para mapear desde JSON
  factory SupercitoSegmentStatsResponse.fromJson(Map<String, dynamic> json) {
    return SupercitoSegmentStatsResponse(
      idBitacora: json['idBitacora'],
      idTienda: json['IdTienda'],
      evento: json['Evento'],
      totalNiveles: json['totalNiveles'],
      suaje: json['suaje'],
      cajaAbierta: json['cajaAbierta'],
      sinCaja: json['sinCaja'],
      porSuaje: (json['porSuaje'] as num).toDouble(),
      porCajaAbierta: (json['porcajaAbierta'] as num).toDouble(),
      porSinCaja: (json['porSinCaja'] as num).toDouble(),
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'idBitacora': idBitacora,
      'IdTienda': idTienda,
      'Evento': evento,
      'totalNiveles': totalNiveles,
      'suaje': suaje,
      'cajaAbierta': cajaAbierta,
      'sinCaja': sinCaja,
      'porSuaje': porSuaje,
      'porcajaAbierta': porCajaAbierta,
      'porSinCaja': porSinCaja,
    };
  }
}
