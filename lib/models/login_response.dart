class LoginResponse {
  final String mensaje;
  final String jwt;
  final int idRol;
  final String apMaterno;
  final String apPaterno;
  final String name;
  final String idUsuario;
  final bool esSupercito;
  final String rol;
  final ConstantsEnviroment constants;
  final bool admin;

  LoginResponse({
    required this.mensaje,
    required this.jwt,
    required this.idRol,
    required this.apMaterno,
    required this.apPaterno,
    required this.name,
    required this.idUsuario,
    required this.esSupercito,
    required this.rol,
    required this.constants,
    required this.admin,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      mensaje: json['mensaje'],
      jwt: json['jwt'],
      idRol: json['idRol'],
      apMaterno: json['apMaterno'],
      apPaterno: json['apPaterno'],
      name: json['name'],
      idUsuario: json['idUsuario'],
      esSupercito: json['esSupercito'],
      rol: json['rol'] as String, // Ahora es un String en lugar de una lista
      constants: ConstantsEnviroment.fromJson(json['constants']),
      admin: json['admin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mensaje': mensaje,
      'jwt': jwt,
      'idRol': idRol,
      'apMaterno': apMaterno,
      'apPaterno': apPaterno,
      'name': name,
      'idUsuario': idUsuario,
      'rol': rol, // Ahora es un String en lugar de una lista
      'esSupercito': esSupercito,
      'constants': constants.toJson(),
      'admin': admin,
    };
  }
}

class ConstantsEnviroment {
  final String apiPathService;
  final String apiUrlService;
  final String apiEnvironment;
  final String apiPathSuaje;
  final String apiUrlSuaje;
  final String apiPathRICh;
  final String apiUrlRICh;
  final String apiUrlBI;
  final String malUbicadosSecuencia;
  final String malUbicadosProdSinHuecos;

  ConstantsEnviroment({
    required this.apiPathService,
    required this.apiUrlService,
    required this.apiEnvironment,
    required this.apiPathSuaje,
    required this.apiUrlSuaje,
    required this.apiPathRICh,
    required this.apiUrlRICh,
    required this.apiUrlBI,
    required this.malUbicadosSecuencia,
    required this.malUbicadosProdSinHuecos,
  });

  factory ConstantsEnviroment.fromJson(Map<String, dynamic> json) {
    return ConstantsEnviroment(
      apiPathService: json['apiPathService'],
      apiUrlService: json['apiUrlService'],
      apiEnvironment: json['apiEnvironment'],
      apiPathSuaje: json['apiPathSuaje'],
      apiUrlSuaje: json['apiUrlSuaje'],
      apiPathRICh: json['apiPathRICh'],
      apiUrlRICh: json['apiUrlRICh'],
      apiUrlBI: json['apiUrlBI'],
      malUbicadosSecuencia: json['malUbicadosSecuencia'] ?? '',
      malUbicadosProdSinHuecos: json['malUbicadosProdSinHuecos'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'apiPathService': apiPathService,
      'apiUrlService': apiUrlService,
      'apiEnvironment': apiEnvironment,
      'apiPathSuaje': apiPathSuaje,
      'apiUrlSuaje': apiUrlSuaje,
      'apiPathRICh': apiPathRICh,
      'apiUrlRICh': apiUrlRICh,
      'apiUrlBI': apiUrlBI,
      'malUbicadosSecuencia': malUbicadosSecuencia,
      'malUbicadosProdSinHuecos': malUbicadosProdSinHuecos,
    };
  }
}
