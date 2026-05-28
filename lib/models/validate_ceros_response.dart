class ValidateCerosResponse {
  final bool estatus;
  final String descripcion;
  final int idReconocimiento;
  final int tramo;

  ValidateCerosResponse({
    required this.estatus,
    required this.descripcion,
    required this.idReconocimiento,
    required this.tramo,
  });

  // Factory constructor para crear desde JSON
  factory ValidateCerosResponse.fromJson(Map<String, dynamic> json) {
    return ValidateCerosResponse(
      estatus: json['estatus'] as bool,
      descripcion: json['descripcion'] as String,
      idReconocimiento: json['idReconocimiento'] as int,
      tramo: json['tramo'] as int,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'estatus': estatus,
      'descripcion': descripcion,
      'idReconocimiento': idReconocimiento,
      'tramo': tramo,
    };
  }

  @override
  String toString() {
    return 'ValidateCerosResponse(estatus: $estatus, descripcion: $descripcion, idReconocimiento: $idReconocimiento, tramo: $tramo)';
  }
}
