class SendPictureParams {
  String? imagenSuperior;
  String? imagenMedia;
  String? imagenInferior;
  int segments;

  SendPictureParams({
    this.imagenSuperior,
    this.imagenMedia,
    this.imagenInferior,
    required this.segments,
  });

  factory SendPictureParams.fromJson(Map<String, dynamic> json) {
    return SendPictureParams(
      imagenSuperior: json['imagen_superior'] as String?,
      imagenMedia: json['imagen_media'] as String?,
      imagenInferior: json['imagen_inferior'] as String?,
      segments: json['segments'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'segments': segments,
    };
  }
}
