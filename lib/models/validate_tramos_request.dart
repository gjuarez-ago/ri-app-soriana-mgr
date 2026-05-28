// 📂 lib/services/ri/models/valida_tramos_request.dart

class ValidaTramosRequest {
  final int idBitacora;
  final int tienda;
  final String categoria;

  ValidaTramosRequest({
    required this.idBitacora,
    required this.tienda,
    required this.categoria,
  });

  // 🔹 Para convertir de JSON a objeto
  factory ValidaTramosRequest.fromJson(Map<String, dynamic> json) {
    return ValidaTramosRequest(
      idBitacora: json['idBitacora'] as int,
      tienda: json['tienda'] as int,
      categoria: json['categoria'] as String,
    );
  }

  // 🔹 Para convertir objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'idBitacora': idBitacora,
      'tienda': tienda,
      'categoria': categoria,
    };
  }
}
