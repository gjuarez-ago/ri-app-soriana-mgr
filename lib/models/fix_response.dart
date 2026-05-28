class FixResponse {
  bool estatus;
  String respuesta;

  FixResponse({required this.estatus, required this.respuesta});

  factory FixResponse.fromJson(Map<String, dynamic> json) {
    return FixResponse(
      estatus: json['estatus'],
      respuesta: json['respuesta'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estatus': estatus,
      'mensaje': respuesta,
    };
  }
}
