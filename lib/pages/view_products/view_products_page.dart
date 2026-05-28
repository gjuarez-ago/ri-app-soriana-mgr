import 'package:ago_app/bloc/bloc.dart';
import 'package:ago_app/models/product_list_response.dart';
import 'package:ago_app/models/view_detail_tramo.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewProductsPage extends StatefulWidget {

  final ViewDetailTramo? params;
  
  const ViewProductsPage({super.key, this.params});

  static String routeName = "view_products_page";

  @override
  State<ViewProductsPage> createState() => _ViewProductsPageState();
}

class _ViewProductsPageState extends State<ViewProductsPage> {
  
  RIBloc? _riBloc; // Declaración del BLoC

  List<ProductListResponse> listProducts = [];

  @override
  void initState() {
    super.initState();
    _riBloc = BlocProvider.of<RIBloc>(context); // Obtener instancia del BLoC
    _riBloc?.add(EventGetProducts(idReconocimiento: widget.params!.idReconocimiento, tramo: widget.params!.tramo!)); // Puedes ajustar los parámetros
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Listado de productos',
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
      body: SafeArea(
        child: BlocConsumer<RIBloc, RIState>(
          listener: (context, state) {
            if (state is ErrorGetProducts) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('Error: ${state.messageError}'),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is IsLoadingGetProducts) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SuccessGetProducts) {
              listProducts = state.response;
        
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('ID reconocimiento')),
                      DataColumn(label: Text('Tramo')),
                      DataColumn(label: Text('Nivel')),
                      DataColumn(label: Text('Secuencia')),
                      DataColumn(label: Text('UPC')),
                      DataColumn(label: Text('Automático')),
                      DataColumn(label: Text('SKU')),
                      DataColumn(label: Text('Descripción')),
                    ],
                    rows: listProducts.map((product) {
                      return DataRow(cells: [
                        DataCell(Text(product.idReconocimiento.toString())),
                        DataCell(Text(product.tramo.toString())),
                        DataCell(Text(product.nivel.toString())),
                        DataCell(Text(product.secuencia.toString())),
                        DataCell(Text(product.upc)),
                        DataCell(Text(product.automatico ? 'Sí' : 'No')),
                        DataCell(Text(product.sku)),
                        DataCell(Text(product.descripcion)),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            } else {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('ID reconocimiento')),
                      DataColumn(label: Text('Tramo')),
                      DataColumn(label: Text('Nivel')),
                      DataColumn(label: Text('Secuencia')),
                      DataColumn(label: Text('UPC')),
                      DataColumn(label: Text('Automático')),
                      DataColumn(label: Text('SKU')),
                      DataColumn(label: Text('Descripción')),
                    ],
                    rows: listProducts.map((product) {
                      return DataRow(cells: [
                        DataCell(Text(product.idReconocimiento.toString())),
                        DataCell(Text(product.tramo.toString())),
                        DataCell(Text(product.nivel.toString())),
                        DataCell(Text(product.secuencia.toString())),
                        DataCell(Text(product.upc)),
                        DataCell(Text(product.automatico ? 'Sí' : 'No')),
                        DataCell(Text(product.sku)),
                        DataCell(Text(product.descripcion)),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
