class CaptureResponse {
  bool estatus;
  String respuesta;

  CaptureResponse({required this.estatus, required this.respuesta});

  factory CaptureResponse.fromJson(Map<String, dynamic> json) {
    return CaptureResponse(
      estatus: json['estatus'],
      respuesta: json['mensaje'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estatus': estatus,
      'mensaje': respuesta,
    };
  }
}
