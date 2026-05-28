class ProductListResponse {
  final int idReconocimiento;
  final int tramo;
  final int nivel;
  final int secuencia;
  final String upc;
  final bool automatico;
  final String sku;
  final String descripcion;

  ProductListResponse({
    required this.idReconocimiento,
    required this.tramo,
    required this.nivel,
    required this.secuencia,
    required this.upc,
    required this.automatico,
    required this.sku,
    required this.descripcion,
  });

  // Constructor vacío opcional para simular @NoArgsConstructor
  ProductListResponse.empty()
      : idReconocimiento = 0,
        tramo = 0,
        nivel = 0,
        secuencia = 0,
        upc = '',
        automatico = false,
        sku = '',
        descripcion = '';

  // Método para copiar el objeto con nuevos valores opcional
  ProductListResponse copyWith({
    int? idReconocimiento,
    int? tramo,
    int? nivel,
    int? secuencia,
    String? upc,
    bool? automatico,
    String? sku,
    String? descripcion,
  }) {
    return ProductListResponse(
      idReconocimiento: idReconocimiento ?? this.idReconocimiento,
      tramo: tramo ?? this.tramo,
      nivel: nivel ?? this.nivel,
      secuencia: secuencia ?? this.secuencia,
      upc: upc ?? this.upc,
      automatico: automatico ?? this.automatico,
      sku: sku ?? this.sku,
      descripcion: descripcion ?? this.descripcion,
    );
  }

  // Método para crear una instancia desde un mapa
  factory ProductListResponse.fromMap(Map<String, dynamic> map) {
    return ProductListResponse(
      idReconocimiento: map['idReconocimiento'],
      tramo: map['tramo'],
      nivel: map['nivel'],
      secuencia: map['secuencia'],
      upc: map['upc'],
      automatico: map['automatico'],
      sku: map['sku'],
      descripcion: map['descripcion'],
    );
  }

  // Método para convertir la instancia a un mapa
  Map<String, dynamic> toMap() {
    return {
      'idReconocimiento': idReconocimiento,
      'tramo': tramo,
      'nivel': nivel,
      'secuencia': secuencia,
      'upc': upc,
      'automatico': automatico,
      'sku': sku,
      'descripcion': descripcion,
    };
  }

}
