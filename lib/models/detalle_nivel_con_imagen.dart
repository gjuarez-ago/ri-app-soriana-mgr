import 'package:ago_app/models/detalle_nivel_response.dart';
class DetalleNivelConImagen {
  final String imageUrl;
  final List<DetalleNivelResponse> detalleNivel;

  DetalleNivelConImagen({
    required this.imageUrl,
    required this.detalleNivel,
  });

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'detalleNivel': detalleNivel.map((e) => e.toJson()).toList(),
    };
  }
}
