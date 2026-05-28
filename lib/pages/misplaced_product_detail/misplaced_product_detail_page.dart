import 'package:ago_app/models/misplaced_products_response.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:flutter/material.dart';

class MisplacedProductDetailPage extends StatelessWidget {
  final MisplacedProduct product;

  const MisplacedProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    print('Este el producto -> ${product.toJson()}');
    final size = MediaQuery.of(context).size;
    final imageHeight = size.width * 0.65;

    return Scaffold(
      appBar: AppBar(
        title: Text(
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                product.upc ?? 'No data',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              Image.network(
                product.imagen ?? '',
                height: imageHeight,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported);
                  },
              ),
              const SizedBox(height: 25),
              Text(
                product.nombreProducto ?? 'No data',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              _buildUbicacionSection(
                title: 'Ubicación Actual',
                ubicaciones: product.ubicacionActual,
                backgroundColor: Color.fromARGB(255, 255, 125, 127),
                showSecuencia: false,
              ),
              const SizedBox(height: 30),
              _buildUbicacionSection(
                title: 'Ubicación Correcta',
                ubicaciones: product.ubicacionCorrecta,
                backgroundColor: Color.fromARGB(255, 41, 114, 40),
                showSecuencia: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildUbicacionSection({
  required String title,
  required List<Ubicacion> ubicaciones,
  required Color backgroundColor,
  required bool showSecuencia,
}) {
  if (ubicaciones.isEmpty) return const SizedBox.shrink();

  final verticalPadding = showSecuencia ? 4.0 : 6.0;

  final styleBold = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: showSecuencia ? 13.5 : 15.5,
  );

  final styleNormal = TextStyle(
    color: Colors.white,
    fontSize: showSecuencia ? 13.5 : 15.5,
  );

  /// 🔹 AGRUPAR POR nombreMueble
  final Map<String, List<Ubicacion>> grouped = {};

  for (var u in ubicaciones) {
    final key = (u.mueble ?? '').trim().isEmpty
        ? 'Sin mueble'
        : u.mueble!.trim();

    grouped.putIfAbsent(key, () => []).add(u);
  }

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔹 TÍTULO
        Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 10),

        /// 🔹 RECORRER CADA GRUPO (pero sin cambiar tu estructura)
        ...grouped.entries.map((entry) {
          final nombreMueble = entry.key;
          final items = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔹 NOMBRE DEL MUEBLE
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    nombreMueble,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              /// 🔹 REGISTROS (igual que antes)
              ...items.map(
                (u) => Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: verticalPadding),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: [
                      _itemLocation(
                        label: 'Tramo',
                        value: u.tramo != 0
                            ? '${u.tramo}'
                            : '--',
                        boldStyle: styleBold,
                        normalStyle: styleNormal,
                      ),
                      _itemLocation(
                        label: 'Nivel',
                        value: u.nivel != 0
                            ? '${u.nivel}'
                            : '--',
                        boldStyle: styleBold,
                        normalStyle: styleNormal,
                      ),
                      if (showSecuencia)
                        _itemLocation(
                          label: 'Secuencia',
                          value: u.secuencia != 0
                              ? '${u.secuencia}'
                              : '--',
                          boldStyle: styleBold,
                          normalStyle: styleNormal,
                          flex: 3,
                        ),
                      Visibility(
                        visible: false,
                        child: _itemLocation(
                          label: 'Frentes',
                          value: u.frentes != 0
                              ? '${u.frentes}'
                              : '--',
                          boldStyle: styleBold,
                          normalStyle: styleNormal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          );
        }),
      ],
    ),
  );
}



  Widget _itemLocation({
    required String label,
    required String value,
    required TextStyle boldStyle,
    required TextStyle normalStyle,
    int flex = 2,
  }) {
    return Flexible(
      flex: flex,
      child: Center(
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(text: '$label: ', style: boldStyle),
              TextSpan(text: value, style: normalStyle),
            ],
          ),
        ),
      ),
    );
  }
}
