class SendPictureSupectitosResponse {
  bool procesado;
  String? mensaje;
  int? niveles;

  SendPictureSupectitosResponse({
    required this.procesado,
    this.mensaje,
    this.niveles,
  });

  factory SendPictureSupectitosResponse.fromJson(Map<String, dynamic> json) {
    return SendPictureSupectitosResponse(
      procesado: json['procesado'] as bool,
      mensaje: json['mensaje'] as String?,
      niveles: json['niveles'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'procesado': procesado,
      'mensaje': mensaje,
      'niveles': niveles,
    };
  }
}
