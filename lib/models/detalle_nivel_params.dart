class DetalleNivelParams {
  final int idRealograma;
  final int nivel;
  final int tramo;
  final int idReconocimiento;

  DetalleNivelParams({
    required this.idRealograma,
    required this.nivel,
    required this.tramo,
    required this.idReconocimiento
  });

  // Método para convertir una instancia de DetalleNivelParams a JSON
  Map<String, dynamic> toJson() {
    return {
      'idRealograma': idRealograma,
      'nivel': nivel,
      'tramo': tramo,
      'idReconocimiento': idReconocimiento,
    };
  }
}
