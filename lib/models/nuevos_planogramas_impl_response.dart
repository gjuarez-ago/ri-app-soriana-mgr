import 'package:ago_app/models/implementation_of_planograms_item_response.dart';

class NuevosPlanogramasImplResponse {
  final int caducados;
  final int porImplementar;
  final int implementados;
  final List<ImplementationOfPlanogramsItemResponse> planogramas;

  NuevosPlanogramasImplResponse({
    required this.caducados, 
    required this.porImplementar, 
    required this.implementados, 
    required this.planogramas
  });

  factory NuevosPlanogramasImplResponse.fromJson(Map<String,dynamic> json) => NuevosPlanogramasImplResponse(
    caducados: json['caducados']?? 0, 
    porImplementar: json['porImplementar']?? 0, 
    implementados: json['implementados']?? 0, 
    planogramas: (json["planogramas"] as List<dynamic>)
      .map((e) => ImplementationOfPlanogramsItemResponse.fromJson(e))
      .toList()
  );
  
  Map<String, dynamic> toJson() => {
    "caducados": caducados,
    "porImplementar": porImplementar,
    "implementados": implementados,
    "planogramas": planogramas.map((e) => e.toJson()).toList(),
  };

  @override
  String toString() {
    return '''
      NuevosPlanogramasImplResponse(
        caducados: $caducados,
        porImplementar: $porImplementar,
        implementados: $implementados,
        planogramas: $planogramas
      )''';
  }
}