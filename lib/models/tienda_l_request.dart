class TiendaLRequest {
 
  final int idTienda;
  final int dia;
 
  TiendaLRequest({
    required this.idTienda,
    required this.dia,
  });

  // Factory constructor para crear una instancia desde un JSON
  factory TiendaLRequest.fromJson(Map<String, dynamic> json) {
    return TiendaLRequest(
      idTienda: json['idTienda'] as int,
      dia: json['dia'] as int,
    );
  }

  // Método para convertir una instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'idTienda': idTienda,
      'dia': dia,
    };
  }
}
