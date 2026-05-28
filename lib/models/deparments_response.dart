class DeparmentsResponse {
  final int idDepartamento;
  final String? departamento;

  DeparmentsResponse({
    required this.idDepartamento,
    this.departamento,
  });

  // Constructor vacío opcional para simular @NoArgsConstructor
  DeparmentsResponse.empty()
      : idDepartamento = 0,
        departamento = null;

  // Método para copiar el objeto con nuevos valores opcional
  DeparmentsResponse copyWith({
    int? idDepartamento,
    String? departamento,
  }) {
    return DeparmentsResponse(
      idDepartamento: idDepartamento ?? this.idDepartamento,
      departamento: departamento ?? this.departamento,
    );
  }

  // Método para crear una instancia desde un mapa
  factory DeparmentsResponse.fromMap(Map<String, dynamic> map) {
    return DeparmentsResponse(
      idDepartamento: map['idDepartamento'],
      departamento: map['departamento'],
    );
  }

  // Método para convertir la instancia a un mapa
  Map<String, dynamic> toMap() {
    return {
      'idDepartamento': idDepartamento,
      'departamento': departamento,
    };
  }
}
