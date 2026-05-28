class SearchParamsRequest {

  bool isByMenu;
  String? categoria;
  int? tienda;

  SearchParamsRequest({
    required this.isByMenu,
    this.categoria,
    this.tienda,
  });

}
 // Nuevo campo