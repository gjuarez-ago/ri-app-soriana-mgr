class SearchModelHelper {
  
  final int idReconocimiento;
  final int idRealograma;
  final int tramo;
  final String? categoria;
  final int idTienda;
  final int event;
  final int idBitacora; // Nuevo campo agregado

  SearchModelHelper({
    required this.idReconocimiento,
    required this.idRealograma,
    required this.tramo,
    required this.categoria,
    required this.idTienda,
    required this.event,
    required this.idBitacora, // Inicialización del nuevo campo
  });

  factory SearchModelHelper.fromJson(Map<String, dynamic> json) {
    return SearchModelHelper(
      idReconocimiento: json['idReconocimiento'],
      idRealograma: json['idRealograma'],
      tramo: json['tramo'],
      idTienda: json['idTienda'],
      categoria: json['categoria'],
      event: json['event'],
      idBitacora: json['idBitacora'], // Lectura del nuevo campo
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idReconocimiento': idReconocimiento,
      'idRealograma': idRealograma,
      'tramo': tramo,
      'idTienda': idTienda,
      'categoria': categoria,
      'event': event,
      'idBitacora': idBitacora, // Inclusión del nuevo campo en la serialización
    };
  }
}
