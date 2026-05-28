class ResumePicturesParams {
  final int idRealograma;
  final int tramo;
  final String? usuario;
  final String? categoria;
  final DateTime fechaCap;
  final String? imagen;

  ResumePicturesParams({
    required this.idRealograma,
    required this.tramo,
    required this.usuario,
    required this.categoria,
    required this.fechaCap,
    required this.imagen,
  });

  factory ResumePicturesParams.fromJson(Map<String, dynamic> json) {
    return ResumePicturesParams(
      idRealograma: json['idRealograma'] as int,
      tramo: json['tramo'] as int,
      usuario: json['usuario'] as String,
      categoria: json['categoria'] as String,
      fechaCap: DateTime.parse(json['fechaCap'] as String),
      imagen: json['imagen'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idRealograma': idRealograma,
      'tramo': tramo,
      'usuario': usuario,
      'categoria': categoria,
      'fechaCap': fechaCap.toIso8601String(),
    };
  }
}
