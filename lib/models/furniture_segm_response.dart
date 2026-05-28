class FurnitureSegmentResponse {
  
  final int idReconocimiento;
  final int idRealograma;
  final int tramo;
  final int estatusTramo;
  final int incidencias;
  final int correctas;
  final String? imagen;

  FurnitureSegmentResponse({
    required this.idReconocimiento,
    required this.idRealograma,
    required this.tramo,
    required this.estatusTramo,
    required this.incidencias,
    required this.correctas,
    required this.imagen,
  });

  // Constructor vacío opcional para simular @NoArgsConstructor
  FurnitureSegmentResponse.empty()
      : idReconocimiento = 0,
        idRealograma = 0,
        tramo = 0,
        estatusTramo = 0,
        incidencias = 0,
        correctas = 0,
        imagen = "";

  // Método para copiar el objeto con nuevos valores opcional
  FurnitureSegmentResponse copyWith({
    int? idReconocimiento,
    int? idRealograma,
    int? tramo,
    int? estatusTramo,
    int? incidencias,
    int? correctas,
    String? imagen,
  }) {
    return FurnitureSegmentResponse(
        idReconocimiento: idReconocimiento ?? this.idReconocimiento,
        idRealograma: idRealograma ?? this.idRealograma,
        tramo: tramo ?? this.tramo,
        estatusTramo: estatusTramo ?? this.estatusTramo,
        incidencias: incidencias ?? this.incidencias,
        correctas: correctas ?? this.correctas,
        imagen: imagen ?? this.imagen);
  }

  // Método para crear una instancia desde un mapa
  factory FurnitureSegmentResponse.fromMap(Map<String, dynamic> map) {
    return FurnitureSegmentResponse(
      idReconocimiento: map['idReconocimiento'],
      idRealograma: map['idRealograma'],
      tramo: map['tramo'],
      estatusTramo: map['estatusTramo'],
      incidencias: map['incidencias'],
      correctas: map['correctas'],
      imagen: map['imagen'],
    );
  }

  // Método para convertir la instancia a un mapa
  Map<String, dynamic> toMap() {
    return {
      'idReconocimiento': idReconocimiento,
      'idRealograma': idRealograma,
      'tramo': tramo,
      'estatusTramo': estatusTramo,
      'incidencias': incidencias,
      'correctas': correctas,
    };
  }
}
