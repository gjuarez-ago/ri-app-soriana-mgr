class FixIssuesResponse {
   bool estatus;
  String respuesta;

  FixIssuesResponse({required this.estatus, required this.respuesta});

  factory FixIssuesResponse.fromJson(Map<String, dynamic> json) {
    return FixIssuesResponse(
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
