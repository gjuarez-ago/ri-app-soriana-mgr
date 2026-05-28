class EventsResponse {
  final int idTienda;
  final int evento;
  final String fechaMon;
  final String idCategoria;
  final double cumplimientoNvo;
  final int catalogo;
  final int monitoreo;
  final int teoricos;
  final double gap;
  final int idBitacora; // Nuevo campo agregado

  EventsResponse({
    required this.catalogo,
    required this.cumplimientoNvo,
    required this.evento,
    required this.fechaMon,
    required this.gap,
    required this.idCategoria,
    required this.idTienda,
    required this.monitoreo,
    required this.teoricos,
    required this.idBitacora, // Inicialización del nuevo campo
  });

  // Método factory para crear una instancia desde JSON
  factory EventsResponse.fromJson(Map<String, dynamic> json) {
    return EventsResponse(
      catalogo: json['catalogo'],
      cumplimientoNvo: json['cumplimientoNvo'],
      evento: json['evento'],
      fechaMon: json['fechaMon'],
      gap: json['gap'],
      idCategoria: json['idCategoria'],
      idTienda: json['idTienda'],
      monitoreo: json['monitoreo'],
      teoricos: json['teoricos'],
      idBitacora: json['idBitacora'], // Lectura del nuevo campo
    );
  }

  // Método para convertir la instancia a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'catalogo': catalogo,
      'cumplimientoNvo': cumplimientoNvo,
      'evento': evento,
      'fechaMon': fechaMon,
      'gap': gap,
      'idCategoria': idCategoria,
      'idTienda': idTienda,
      'monitoreo': monitoreo,
      'teoricos': teoricos,
      'idBitacora': idBitacora, // Inclusión del nuevo campo en la serialización
    };
  }
}
