import 'package:ago_app/bloc/bloc.dart';
import 'package:ago_app/models/planogram.dart';
import 'package:ago_app/models/planogram_item_product.dart';
import 'package:ago_app/pages/pdf_view/pdf_view_url.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:ago_app/widgets/generic_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewPDFByBI extends StatefulWidget {
  final String? category;
  final String? store;
  final int? origin;
  final String? upc;
  final int type;

  const ViewPDFByBI({
    super.key,
    required this.category,
    required this.store,
    required this.origin,
    required this.upc,
    required this.type,
  });

  @override
  State<ViewPDFByBI> createState() => _ViewPDFByBIState();
}

class _ViewPDFByBIState extends State<ViewPDFByBI> {
  RIBloc? _riBloc;
  List<Planograma> listPlanograms = [];
  List<PlanogramaItemResponse> listPlanogramsItems = [];
  int _currentViewIndex = 0; // 0 para tabla, 1 para cards
  bool _hasAttemptedProducts = false;

  @override
  void initState() {
    super.initState();
    _riBloc = BlocProvider.of<RIBloc>(context);
    // Cargar datos iniciales
    _loadInitialData();
  }

  void _loadInitialData() {
    _riBloc?.add(
      EventGetPdfPlanogram(
        category: widget.category!,
        store: widget.store!,
        esSupercito: widget.origin == 1 ? true : false,
      ),
    );

    if (widget.type == 0) {
      setState(() {
        _hasAttemptedProducts = false;
      });
      _riBloc?.add(
        EventGetProductPLN(tienda: int.parse(widget.store!), upc: widget.upc!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Planogramas',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        elevation: 1,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Constants.appBarStartColor, Constants.appBarEndColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.7],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Botones de selección de vista
            if (widget.type == 0) // Solo mostrar botones si origin es 0
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentViewIndex = 0;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _currentViewIndex == 0 ? Colors.blue : Colors.grey,
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.table_chart, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Planogramas',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentViewIndex = 1;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _currentViewIndex == 1 ? Colors.blue : Colors.grey,
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.view_module, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Ubicación',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Contenido principal
            Expanded(
              child: BlocListener<RIBloc, RIState>(
                listener: (context, state) {
                  if (state is ErrorGetPdfPlanogram ||
                      state is ErrorGetPrductPLN) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          'Error: ${state.messageError}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }

                  if (state is SuccessGetPrductPLN) {
                    setState(() {
                      listPlanogramsItems = state.response;
                      _hasAttemptedProducts = true;
                    });
                  }

                  if (state is ErrorGetPrductPLN) {
                    setState(() {
                      _hasAttemptedProducts = true;
                    });
                  }

                  if (state is SuccessGetPdfPlanogram) {
                    setState(() {
                      listPlanograms = state.response;
                    });
                  }
                },
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Si origin no es 0, siempre mostrar la tabla
    if (widget.type != 0) {
      return _buildTableView();
    }

    // Si origin es 0, mostrar la vista seleccionada
    switch (_currentViewIndex) {
      case 0:
        return _buildTableView();
      case 1:
        return _buildCardsView();
      default:
        return _buildTableView();
    }
  }

  Widget _buildTableView() {
    if (listPlanograms.isEmpty) {
      return Center(
        child: CenteredImageWithText(
          assetPath: 'assets/images/planet.png',
          title: 'Sin información',
          description: 'No hay planogramas para mostrar.',
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          dividerThickness: 2,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black.withOpacity(0.5), width: 1),
          ),
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Planograma')),
            DataColumn(label: Text('Acción')),
          ],
          rows: listPlanograms.map((planogram) {
            return DataRow(
              cells: [
                DataCell(Text(planogram.id.toString())),
                DataCell(Text(planogram.nombrePlanograma)),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.open_in_new, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PdfViewByURL(url: planogram.urlPdf),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCardsView() {
    return BlocBuilder<RIBloc, RIState>(
      builder: (context, state) {
        // Prioridad 1: Mostrar datos si ya los tenemos (del estado actual o de la lista guardada)
        final items = (state is SuccessGetPrductPLN)
            ? state.response
            : listPlanogramsItems;

        if (items.isNotEmpty) {
          return SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final planogram = items[index];
                return Card(
                  color: Colors.white,
                  elevation: 6,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final bool isWide = constraints.maxWidth > 600;
                        return isWide
                            ? _buildWideLayout(planogram)
                            : _buildNormalLayout(planogram);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }

        // Prioridad 2: Mostrar error si hay alguno y no tenemos datos
        if (state is ErrorGetPrductPLN ||
            (state.messageError != null &&
                items.isEmpty &&
                state is! IsLoadingGetPdfPlanogram &&
                state is! IsLoadingGetPrductPLN)) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error al obtener ubicación',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.messageError ??
                        'Ocurrió un error inesperado al cargar la ubicación.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _loadInitialData(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Prioridad 3: Mostrar carga si está específicamente cargando productos
        if (state is IsLoadingGetPrductPLN) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Cargando ubicación...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Prioridad 4: Si ya intentamos cargar productos y la lista sigue vacía
        if ((state is SuccessGetPrductPLN && state.response.isEmpty) ||
            (_hasAttemptedProducts && listPlanogramsItems.isEmpty)) {
          return Center(
            child: CenteredImageWithText(
              assetPath: 'assets/images/planet.png',
              title: 'Sin información',
              description: 'No hay información de ubicación disponible.',
            ),
          );
        }

        // Por defecto, mientras no tengamos datos ni hayamos terminado el intento, mostramos el loader
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  // Método para diseño normal (vertical)
  Widget _buildNormalLayout(PlanogramaItemResponse planogram) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título con icono
        Row(
          children: [
            Icon(Icons.view_compact, size: 20, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                planogram.nombrePlanograma,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Información en dos columnas para mejor organización
        _buildInfoRow('UPC', planogram.fcUpc),
        _buildInfoRow('SKU', planogram.fiSku.toString()),
        _buildInfoRow('Categoría', planogram.categoria),
        _buildInfoRow('Tramo', planogram.fiSegmento.toString()),
        _buildInfoRow('Charola', planogram.fiNoCharola.toString()),
        _buildInfoRow('Ubicación', planogram.fiOrden.toString()),
      ],
    );
  }

  // Método para diseño horizontal en pantallas anchas
  Widget _buildWideLayout(PlanogramaItemResponse planogram) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna para el título
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.view_compact, size: 24, color: Colors.blue[700]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      planogram.nombrePlanograma,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Podrías añadir más elementos aquí si es necesario
            ],
          ),
        ),

        const SizedBox(width: 24),

        // Columna para la información
        Expanded(
          flex: 3,
          child: Wrap(
            spacing: 20,
            runSpacing: 12,
            children: [
              _buildInfoChip('UPC', planogram.fcUpc.toString()),
              _buildInfoChip('SKU', planogram.fiSku.toString()),
              _buildInfoChip('Categoría', planogram.categoria.toString()),
              _buildInfoChip('Tramo', planogram.fiSegmento.toString()),
              _buildInfoChip('Charola', planogram.fiNoCharola.toString()),
              _buildInfoChip('Ubicación', planogram.fiOrden.toString()),
            ],
          ),
        ),
      ],
    );
  }

  // Widget para filas de información
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 15, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para chips de información (en diseño horizontal)
  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }
}
