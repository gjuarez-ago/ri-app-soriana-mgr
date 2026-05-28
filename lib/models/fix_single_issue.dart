class FixSingleIssueParams {
  int idRegistro;
  String upc;

  FixSingleIssueParams({
    required this.idRegistro,
    required this.upc,
  });

  factory FixSingleIssueParams.fromJson(Map<String, dynamic> json) {
    return FixSingleIssueParams(
      idRegistro: json['idRegistro'],
      upc: json['upc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idRegistro': idRegistro,
      'upc': upc,
    };
  }
  
}
