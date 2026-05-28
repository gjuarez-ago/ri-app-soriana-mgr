class SendPictureResponse {
  bool procesado;
  String? mensaje;
  int? productos;

  SendPictureResponse({
    required this.procesado,
    this.mensaje,
    this.productos,
  });

  factory SendPictureResponse.fromJson(Map<String, dynamic> json) {
    return SendPictureResponse(
      procesado: json['procesado'] as bool,
      mensaje: json['mensaje'] as String?,
      productos: json['productos'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'procesado': procesado,
      'mensaje': mensaje,
      'productos': productos,
    };
  }
}
