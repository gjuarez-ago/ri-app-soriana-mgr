class SegmentIncidentsResponse {
  final int idRegistro;
  final int idReconocimiento;
  final int tramo;
  final int nivel;
  final int secuencia;
  String? upc;
  final bool automatico;
  bool escaneado;
  String? imagen; // Agregado nuevo parámetro

  SegmentIncidentsResponse({
    required this.idRegistro,
    required this.idReconocimiento,
    required this.tramo,
    required this.nivel,
    required this.secuencia,
    this.upc,
    required this.automatico,
    this.escaneado = false,
    this.imagen, // Inicialización del nuevo parámetro
  });

  // Constructor vacío opcional para simular @NoArgsConstructor
  SegmentIncidentsResponse.empty()
      : idRegistro = 0,
        idReconocimiento = 0,
        tramo = 0,
        nivel = 0,
        secuencia = 0,
        upc = null,
        automatico = false,
        escaneado = false,
        imagen = null; // Inicialización del nuevo parámetro

  // Método para copiar el objeto con nuevos valores opcional
  SegmentIncidentsResponse copyWith({
    int? idRegistro,
    int? idReconocimiento,
    int? tramo,
    int? nivel,
    int? secuencia,
    String? upc,
    bool? automatico,
    bool? escaneado,
    String? imagen, // Agregado nuevo parámetro
  }) {
    return SegmentIncidentsResponse(
      idRegistro: idRegistro ?? this.idRegistro,
      idReconocimiento: idReconocimiento ?? this.idReconocimiento,
      tramo: tramo ?? this.tramo,
      nivel: nivel ?? this.nivel,
      secuencia: secuencia ?? this.secuencia,
      upc: upc ?? this.upc,
      automatico: automatico ?? this.automatico,
      escaneado: escaneado ?? this.escaneado,
      imagen: imagen ?? this.imagen, // Asignación del nuevo parámetro
    );
  }

  // Método para crear una instancia desde un mapa
  factory SegmentIncidentsResponse.fromMap(Map<String, dynamic> map) {
    return SegmentIncidentsResponse(
      idRegistro: map['idRegistro'],
      idReconocimiento: map['idReconocimiento'],
      tramo: map['tramo'],
      nivel: map['nivel'],
      secuencia: map['secuencia'],
      upc: map['upc'],
      automatico: map['automatico'],
      escaneado: map['escaneado'] ?? false,
      imagen: map['imagen'], // Agregado nuevo parámetro
    );
  }

  // Método para convertir la instancia a un mapa
  Map<String, dynamic> toMap() {
    return {
      'idRegistro': idRegistro,
      'idReconocimiento': idReconocimiento,
      'tramo': tramo,
      'nivel': nivel,
      'secuencia': secuencia,
      'upc': upc,
      'automatico': automatico,
      'escaneado': escaneado,
    };
  }
}
