class ConsultasResponse {

  final bool estatus;
  final String descripcion;
  
  ConsultasResponse({
    required this.estatus,
    required this.descripcion,
  });

  factory ConsultasResponse.fromJson(Map<String, dynamic> json) {
    return ConsultasResponse(
      estatus: json['estatus'] as bool,
      descripcion: json['descripcion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estatus': estatus,
      'descripcion': descripcion
    };
  }
}
