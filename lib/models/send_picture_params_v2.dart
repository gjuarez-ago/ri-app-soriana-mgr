class SendPictureParamsV2 {
  final int idRealograma;
  final int tramo;
  final String usuario;
  final String categoria;
  final String fechaCap;
  final int segments;
  final String? imagen;
  final String? imagenInferior;
  final String? imagenMedia;
  final String? imagenSuperior;
  final int idTienda;        // Nuevo campo
  final int evento;         // Nuevo campo
  final String ambiente;    // Nuevo campo

  SendPictureParamsV2({
    required this.idRealograma,
    required this.tramo,
    required this.usuario,
    required this.categoria,
    required this.fechaCap,
    required this.segments,
    this.imagen,
    this.imagenInferior,
    this.imagenMedia,
    this.imagenSuperior,
    required this.idTienda,       // Inicialización del nuevo campo
    required this.evento,        // Inicialización del nuevo campo
    required this.ambiente,      // Inicialización del nuevo campo
  });

  Map<String, dynamic> toJson() {
    return {
      'idRealograma': idRealograma,
      'tramo': tramo,
      'usuario': usuario,
      'categoria': categoria,
      'fechaCap': fechaCap,
      'segments': segments,
      'idTienda': idTienda,       // Agregado al método toJson
      'evento': evento,          // Agregado al método toJson
      'ambiente': ambiente,      // Agregado al método toJson
    };
  }
}
