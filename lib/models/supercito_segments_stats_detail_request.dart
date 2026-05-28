class SupercitoSegmentStatsDetailRequest {
  final int idTienda;
  final int idEvento;
  final int idBitacora;
  final String ambiente;

  SupercitoSegmentStatsDetailRequest({
    required this.idTienda,
    required this.idEvento,
    required this.idBitacora,
    required this.ambiente,
  });

  // Factory constructor para crear una instancia desde un JSON
  factory SupercitoSegmentStatsDetailRequest.fromJson(Map<String, dynamic> json) {
    return SupercitoSegmentStatsDetailRequest(
      idTienda: json['idTienda'] as int,
      idEvento: json['idEvento'] as int,
      idBitacora: json['idBitacora'] as int,
      ambiente: json['ambiente'] as String,
    );
  }

  // Método para convertir una instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'idTienda': idTienda,
      'idEvento': idEvento,
      'idBitacora': idBitacora,
      'ambiente': ambiente,
    };
  }
}
