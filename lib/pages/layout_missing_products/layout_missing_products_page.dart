import 'package:ago_app/bloc/bloc.dart';
import 'package:ago_app/models/faltante_response.dart';
import 'package:ago_app/models/layout_faltante_params.dart';
import 'package:ago_app/models/layout_faltante_response.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LayoutMissingProductsPage extends StatefulWidget {
  final FaltanteResponse? params;
  final int? tienda;
  final int? evento;
  final String? idCategoria;
  final int? bitacora;

  static String routeName = "capture_product_page";

  const LayoutMissingProductsPage(
      {super.key,
      this.params,
      this.tienda,
      this.evento,
      this.idCategoria,
      this.bitacora});

  @override
  State<LayoutMissingProductsPage> createState() =>
      _LayoutMissingProductsPageState();
}

class _LayoutMissingProductsPageState extends State<LayoutMissingProductsPage> {
  RIBloc? _riBloc; // Declaración del BLoC

  List<LayoutFaltanteResponse> listProducts = [];

  @override
  void initState() {
    super.initState();
    _riBloc = BlocProvider.of<RIBloc>(context); // Obtener instancia del BLoC
    _riBloc?.add(EventLayoutProductosFaltantes(
        params: LayoutFaltantesParams(
            idTienda: widget.tienda!,
            evento: widget.evento!,
            idCategoria: widget.idCategoria!,
            upc: widget.params!.sku!,
            idBitacora: widget.bitacora))); // Puedes ajustar los parámetros
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ubicación planograma',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 1,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Constants.appBarStartColor,
                Constants.appBarEndColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.7],
            ),
          ),
        ),
      ),
      body: BlocConsumer<RIBloc, RIState>(
        listener: (context, state) {
          if (state is ErrorLayoutProductosFaltantes) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('Error: ${state.messageError}'),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is IsLoadingLayoutProductosFaltantes) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SuccessLayoutProductosFaltantes) {
            listProducts = state.productosFaltantes;

            return SafeArea(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Producto: ${widget.params!.nombreProd}', // Título
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "SKU: ${widget.params!.sku}", // Subtítulo
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    // Tabla de datos
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Planograma')),
                          DataColumn(label: Text('Tramo')),
                          DataColumn(label: Text('Nivel')),
                          DataColumn(label: Text('Posición')),
                          DataColumn(label: Text('Frentes')),
                        ],
                        rows: listProducts.map((product) {
                          return DataRow(cells: [
                            DataCell(Text(product.nombrePlanograma!)),
                            DataCell(Text(product.fiSegmento.toString())),
                            DataCell(Text(product.fiNoCharola.toString())),
                            DataCell(Text(product.fiOrden.toString())),
                            DataCell(Text(product.fiFtes.toString())),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return SafeArea(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Planograma de Productos', // Título
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Detalles de los productos organizados en tramos y charolas', // Subtítulo
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    // Tabla de datos
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Planograma')),
                          DataColumn(label: Text('Tramo')),
                          DataColumn(label: Text('Charola')),
                          DataColumn(label: Text('Orden')),
                          DataColumn(label: Text('Frentes')),
                        ],
                        rows: listProducts.map((product) {
                          return DataRow(cells: [
                            DataCell(Text(product.nombrePlanograma!)),
                            DataCell(Text(product.fiSegmento.toString())),
                            DataCell(Text(product.fiNoCharola.toString())),
                            DataCell(Text(product.fiOrden.toString())),
                            DataCell(Text(product.fiFtes.toString())),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
