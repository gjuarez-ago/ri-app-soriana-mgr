class UbicacionResponse {
  final int idUbicacion;
  final String ubicacion;

  UbicacionResponse({
    required this.idUbicacion,
    required this.ubicacion,
  });

  factory UbicacionResponse.fromJson(Map<String, dynamic> json) {
    return UbicacionResponse(
      idUbicacion: json['idUbicacion'],
      ubicacion: json['ubicacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUbicacion': idUbicacion,
      'ubicacion': ubicacion,
    };
  }
}
