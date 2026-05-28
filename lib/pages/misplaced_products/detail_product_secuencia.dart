import 'package:ago_app/bloc/ri/ri_bloc.dart';
import 'package:ago_app/bloc/ri/ri_state.dart';
import 'package:ago_app/bloc/ri/ri_event.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ago_app/models/producto_mal_acomodado_secuencia.dart';
import 'package:ago_app/models/adyacencia_error_response.dart';

class AdyacenciaUI {
  final String titulo;
  final String imagen;
  final String nombreProducto;
  final String upc;

  AdyacenciaUI(this.titulo, this.imagen, this.nombreProducto, this.upc);
}

class DetailProductSecuencia extends StatefulWidget {
  final ProductoMalAcomodadoSecuencia product;
  final int idBitacora;

  const DetailProductSecuencia(
      {Key? key, required this.product, required this.idBitacora})
      : super(key: key);

  @override
  _DetailProductSecuenciaState createState() => _DetailProductSecuenciaState();
}

class _DetailProductSecuenciaState extends State<DetailProductSecuencia> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<RIBloc>(context)
        .add(EventGetAdyacenciaError(idBitacora: widget.idBitacora));
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double horizontalPadding = 16.0;
    final double availableWidth = screenWidth - (horizontalPadding * 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle del producto',
          textAlign: TextAlign.right,
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
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
          )),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<RIBloc, RIState>(listener: (context, state) {
          if (state is ErrorGetAdyacenciaError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    state.messageError ?? 'Error al obtener adyacencias')));
          }
        }, builder: (context, state) {
          bool isLoading = state is IsLoadingGetAdyacenciaError;
          List<AdyacenciaUI> actuales = [];
          List<AdyacenciaUI> planograma = [];

          if (state is SuccessGetAdyacenciaError) {
            final List<AdyacenciaErrorResponse> data =
                (state as SuccessGetAdyacenciaError).response;
            AdyacenciaErrorResponse? match;
            for (var d in data) {
              if (d.fcUPC == widget.product.upc) {
                match = d;
                break;
              }
            }

            if (match != null) {
              if (match.adyIzqActual != "-1" &&
                  match.adyIzqActual.trim().isNotEmpty)
                actuales.add(AdyacenciaUI('Izquierda', match.imgIzqActual,
                    match.nombreIzqActual, match.upcIzqActual));
              if (match.adyDerActual != "-1" &&
                  match.adyDerActual.trim().isNotEmpty)
                actuales.add(AdyacenciaUI('Derecha', match.imgDerActual,
                    match.nombreDerActual, match.upcDerActual));

              if (match.adyIzquierdaPln != "-1" &&
                  match.adyIzquierdaPln.trim().isNotEmpty)
                planograma.add(AdyacenciaUI(
                    'Izquierda PLN',
                    match.imgIzquierdaPln,
                    match.nombreIzquierdaPln,
                    match.upcIzquierdaPln));
              if (match.adyDerechaPln != "-1" &&
                  match.adyDerechaPln.trim().isNotEmpty)
                planograma.add(AdyacenciaUI('Derecha PLN', match.imgDerechaPln,
                    match.nombreDerechaPln, match.upcDerechaPln));
            }
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainProductCard(context),
                  const SizedBox(height: 24),
                  if (isLoading)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator()))
                  else ...[
                    if (actuales.isNotEmpty) ...[
                      _buildSectionTitle('Adyacentes Actuales'),
                      const SizedBox(height: 12),
                      _buildAdjacencyHorizontalList(actuales, availableWidth),
                    ] else if (state is SuccessGetAdyacenciaError) ...[
                      _buildSectionTitle('Adyacentes Actuales'),
                      const SizedBox(height: 12),
                      _buildEmptyAdjacency(
                          'No se encontraron adyacentes actuales'),
                    ],
                    const SizedBox(height: 24),
                    if (planograma.isNotEmpty) ...[
                      _buildSectionTitle('Adyacentes del Planograma'),
                      const SizedBox(height: 12),
                      _buildAdjacencyHorizontalList(planograma, availableWidth),
                    ] else if (state is SuccessGetAdyacenciaError) ...[
                      _buildSectionTitle('Adyacentes del Planograma'),
                      const SizedBox(height: 12),
                      _buildEmptyAdjacency(
                          'No hay información de planograma para este producto'),
                    ],
                  ],
                  const SizedBox(height: 15),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMainProductCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Hero(
            tag: 'product_${widget.product.upc}',
            child: SizedBox(
              height: 150,
              child: _buildImage(widget.product.imagen),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.product.nombreProducto,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoBadge('UPC:', widget.product.upc),
              const SizedBox(width: 20),
              _buildInfoBadge('SKU:', widget.product.fiSku.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        Text(
          value,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildAdjacencyHorizontalList(
      List<AdyacenciaUI> list, double availableWidth) {
    final int itemCount = list.length;
    const double spacing = 12.0;

    final double totalSpacing =
        spacing * (itemCount - 1 > 0 ? itemCount - 1 : 0);

    double cardWidth = (availableWidth - totalSpacing) / itemCount;

    if (cardWidth < 120.0) cardWidth = 140.0;

    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (ctx, i) => const SizedBox(width: spacing),
        itemBuilder: (ctx, index) {
          final item = list[index];
          return _buildAdjacencyCard(item, cardWidth);
        },
      ),
    );
  }

  Widget _buildAdjacencyCard(AdyacenciaUI item, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.titulo,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Center(
              child: _buildImage(item.imagen),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.nombreProducto,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'UPC: ${item.upc}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAdjacency(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade400, size: 30),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.isEmpty || url == '') {
      return const Icon(Icons.image_not_supported,
          size: 80, color: Colors.grey);
    }
    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }
}
