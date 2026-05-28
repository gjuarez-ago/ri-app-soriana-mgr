class ResumePicturesResponse {
  final int idRealograma;
  final int idReconocimiento;
  final int tramo;
  final int total;
  final int incidencias;
  final int correctas;
  final String idCategoria;
  final String imagen;
  
  ResumePicturesResponse({
    required this.idRealograma,
    required this.idReconocimiento,
    required this.tramo,
    required this.total,
    required this.incidencias,
    required this.correctas,
    required this.idCategoria,
    required this.imagen,
  });

  factory ResumePicturesResponse.fromJson(Map<String, dynamic> json) {
    return ResumePicturesResponse(
      idRealograma: json['IdRealograma'] as int,
      idReconocimiento: json['IdReconocimiento'] as int,
      tramo: json['tramo'] as int,
      total: json['total'] as int,
      incidencias: json['incidencias'] as int,
      correctas: json['correctas'] as int,
      idCategoria: json['idCategoria'] as String,
      imagen: json['imagen'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdRealograma': idRealograma,
      'IdReconocimiento': idReconocimiento,
      'tramo': tramo,
      'total': total,
      'incidencias': incidencias,
      'correctas': correctas,
      'idCategoria': idCategoria,
    };
  }
}
