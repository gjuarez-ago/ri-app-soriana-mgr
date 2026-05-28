class SendPicturesSupercitosParams {
  final int idRealograma;
  final int tramo;
  final String usuario;
  final String fechaCap;
  final String imagenInferior;
  final String imagenSuperior;
  final int segments;
  final int idTienda;
  final String categoria;
  final int evento;

  SendPicturesSupercitosParams({
    required this.idRealograma,
    required this.tramo,
    required this.usuario,
    required this.fechaCap,
    required this.imagenInferior,
    required this.imagenSuperior,
    required this.segments,
    required this.idTienda,
    required this.categoria,
    required this.evento,
  });

  factory SendPicturesSupercitosParams.fromJson(Map<String, dynamic> json) {
    return SendPicturesSupercitosParams(
      idRealograma: json['idRealograma'],
      tramo: json['tramo'],
      usuario: json['usuario'],
      fechaCap: json['fechaCap'],
      imagenInferior: json['imagenInferior'],
      imagenSuperior: json['imagenSuperior'],
      segments: json['segments'],
      idTienda: json['idTienda'],
      categoria: json['categoria'],
      evento: json['evento'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idRealograma': idRealograma,
      'tramo': tramo,
      'usuario': usuario,
      'fechaCap': fechaCap,
      'imagenInferior': imagenInferior,
      'imagenSuperior': imagenSuperior,
      'segments': segments,
      'idTienda': idTienda,
      'categoria': categoria,
      'evento': evento,
    };
  }
}
