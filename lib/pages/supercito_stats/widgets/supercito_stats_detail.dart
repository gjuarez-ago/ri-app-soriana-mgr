import 'package:ago_app/bloc/bloc.dart';
import 'package:ago_app/models/supercito_segm_stats_detail.dart';
import 'package:ago_app/models/supercito_segments_stats_detail_request.dart';
import 'package:ago_app/pages/missing_products/missing_products_page.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SupercitoStatsDetail extends StatefulWidget {
  final SupercitoSegmentStatsDetailRequest request;

  const SupercitoStatsDetail({super.key, required this.request});

  static String routeName = "supercitos_stats_detail_page";

  @override
  State<SupercitoStatsDetail> createState() => _SupercitoStatsDetailState();
}

class _SupercitoStatsDetailState extends State<SupercitoStatsDetail> {
  RIBloc? _riBloc; // Declaración del BLoC

  List<SupercitoSegmStatsDetail> listProducts = [];

  @override
  void initState() {
    super.initState();
    _riBloc = BlocProvider.of<RIBloc>(context); // Obtener instancia del BLoC
    _riBloc?.add(EventGetStatsDetails(
        request: widget.request)); // Puedes ajustar los parámetros
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle por tramo',
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
          if (state is ErrorGetStatsDetails) {
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('Error: ${state.messageError}'),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is IsLoadingGetStatsDetails) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SuccessGetStatsDetails) {
            listProducts = state.response;

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Tramo')),
                    DataColumn(label: Text('% con Cajas')),
                    DataColumn(label: Text('% sin Caja')),
                    DataColumn(label: Text('Imagen')),
                  ],
                  rows: listProducts.map((product) {
                    return DataRow(cells: [
                      DataCell(Text(product.tramo.toString())),
                      DataCell(Text(product.porcCajas.toString())),
                      DataCell(Text(product.porcSinCajas.toString())),
                      DataCell(
                        TextButton(
                          onPressed: () {
                           Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImagePreviewPage(
                                  imageUrl: product.imagen ??
                                      'https://cdn-icons-png.flaticon.com/512/1257/1257249.png',
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            backgroundColor: Colors.blue, // Color de fondo
                            foregroundColor:
                                Colors.white, // Color del texto
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Ver imagen",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
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
                    DataColumn(label: Text('Tramo')),
                    DataColumn(label: Text('% con Cajas')),
                    DataColumn(label: Text('% sin Caja')),
                    DataColumn(label: Text('Imagen')),
                  ],
                  rows: listProducts.map((product) {
                    return DataRow(cells: [
                      DataCell(Text(product.tramo.toString())),
                      DataCell(Text(product.porcCajas.toString())),
                      DataCell(Text(product.porcSinCajas.toString())),
                      DataCell(
                        TextButton(
                          onPressed: () {
                           Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImagePreviewPage(
                                  imageUrl: product.imagen ??
                                      'https://cdn-icons-png.flaticon.com/512/1257/1257249.png',
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            backgroundColor: Colors.blue, // Color de fondo
                            foregroundColor:
                                Colors.white, // Color del texto
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Ver imagen",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
