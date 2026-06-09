import 'package:cached_network_image/cached_network_image.dart';
import 'package:ago_app/models/get_issues_params.dart';
import 'package:ago_app/models/label_incidents_response.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:ago_app/widgets/show_general_loading.dart';
import 'package:flutter/material.dart';
import 'package:ago_app/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LabelsWithIncidentsPage extends StatefulWidget {
  final GetIssuesParams? params;
  static String routeName = "labels_with_incident_page";
  const LabelsWithIncidentsPage({super.key, this.params});

  @override
  State<LabelsWithIncidentsPage> createState() =>
      _LabelsWithIncidentsPageState();
}

class _LabelsWithIncidentsPageState extends State<LabelsWithIncidentsPage> {
  RIBloc? _riBloc;

  late bool isAdmin = false;
  int selectedIndex = 0;
  final List<Color> buttonColors = [Colors.amber, Colors.red];

  @override
  void initState() {
    super.initState();
    getPref();
    print(
        "idBitacora en LabelsWithIncidentsPage -> ${widget.params!.idBitacora}");

    _riBloc = BlocProvider.of<RIBloc>(context);
    _riBloc?.add(
        EventGetLabelWithIncidents(idBitacora: widget.params!.idBitacora));
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    isAdmin = preferences.getBool('admin')!;
    print("Es admin $isAdmin");
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    // final filterHeight = size.height * 0.08;
    // final filterWidth = size.width * 1.0;

    return Scaffold(
      appBar: AppBar(        
        iconTheme: const IconThemeData(
          color: Colors.black
        ),
        centerTitle: true,
        title: Text(
          'Etiquetas con incidencias',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,              
            ),
        ),
       
      ),
      body: BlocConsumer<RIBloc, RIState>(
        listener: (context, state) {
          if (state is ErrorGetLabelWithIncidents) {
            Navigator.pop(context);
            print(state.messageError);
          }

          if (state is IsLoadingGetLabelWithIncidents) {
            showGeneralLoading(context);
          }

          if (state is SuccessGetLabelWithIncidents) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is SuccessGetLabelWithIncidents) {
            final totalIncorrectas = state.response.incorrectas?.length;
            final totalSinEtiqueta = state.response.sinEtiqueta?.length;
            final totalsinPromocion = state.response.sinPromocion?.length;
            final List<Etiqueta>? listToShow;

            switch (selectedIndex) {
              case 0:
                listToShow = state.response.incorrectas;
                break;
              case 1:
                listToShow = state.response.sinEtiqueta;
                break;
              case 2:
                listToShow = state.response.sinPromocion;
                break;
              default:
                listToShow = state.response.incorrectas;
            }

            final itemCountt = listToShow?.length ?? 0;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ButtonsCards(
                      totalIncorrectas: totalIncorrectas!,
                      totalSinEtiqueta: totalSinEtiqueta!,
                      totalsinPromocion: totalsinPromocion!,
                      selectedIndex: selectedIndex,
                      onSelected: (i) => setState(() => selectedIndex = i),
                    ),
                    Expanded(
                          child: ListView.builder(
                              itemCount: itemCountt,
                              itemBuilder: (context, index) {
                                final prod = listToShow?[index];
                                return LabelCard(
                                  product: prod!,
                                );
                              }),
                        ),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: Text('No hay datos disponibles'));
          }
        },
      ),
    );
  }
}

class LabelCard extends StatelessWidget {
  final Etiqueta product;
  const LabelCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // final imageWidth = size.width * 0.2;
    // final imageHeight = size.width * 0.255;
    // final dataWidth = size.width * 0.65;
    // final cardHeight = size.height * 0.2;

    return SizedBox(
      width: size.width,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreviewPage(
                imageUrl: product.imagen!,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Card(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xffEBEBEAFF),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(5),
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: CachedNetworkImage(
                              imageUrl: product.imagen!,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2,),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Image.network(
                                'https://cdn-icons-png.flaticon.com/512/1257/1257249.png',
                                fit: BoxFit.contain,
                              ),
                              fit:  BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        flex: 7,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.nombreProducto ?? 'Nombre no disponible',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'UPC:',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: Text(
                                      '${product.upc}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),                                  
                                ],
                              ),

                              const SizedBox(height: 5),

                               Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'UPC:',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: Text(
                                      '${product.sku}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),                                  
                                ],
                              ),

                              const SizedBox(height: 5),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Tramo:',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: Text(
                                      '${product.tramo}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),                                  
                                ],
                              ),

                              const SizedBox(height: 5),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Nivel:',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: Text(
                                      '${product.nivel}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),                                  
                                ],
                              ),

                              const SizedBox(height: 5),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Precio auditado:',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: Text(
                                      '\$${product.precioAuditado}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),                                  
                                ],
                              ),

                              const SizedBox(height: 5),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Precio regular:',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: Text(
                                      '\$${product.precioRegular}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color.fromARGB(255, 94, 180, 98),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),                                  
                                ],
                              ),

                              const SizedBox(height: 5),
                              

                              if(product.precioPromocion! > 0)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Precio promoción:',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '\$${product.precioPromocion}',
                                      style: const TextStyle( 
                                        fontSize: 14,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),                                  
                                ],
                              ),
                            ],
                          ),
                        ),                     
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildProductInfo(
  //     {required String titleL,
  //     required String valueL,
  //     required String titleR,
  //     required String valueR,
  //     int flex = 2,
  //     double sizeFont = 10,
  //     Color titleColorL = Colors.black,
  //     Color valueColorL = Colors.black,
  //     Color titleColorR = Colors.black,
  //     Color valueColorR = Colors.black,
  //     bool valueBoldL = false,
  //     bool valueBoldR = false}) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     crossAxisAlignment: CrossAxisAlignment.end,
  //     children: [
  //       _buildValueView(
  //           title: titleL,
  //           value: valueL,
  //           flex: flex,
  //           sizeFont: sizeFont,
  //           titleColor: titleColorL,
  //           valueColor: valueColorL,
  //           valueBold: valueBoldL),
  //       _buildValueView(
  //           title: titleR,
  //           value: '${valueR}',
  //           flex: flex,
  //           sizeFont: sizeFont,
  //           titleColor: titleColorR,
  //           valueColor: valueColorR,
  //           valueBold: valueBoldR),
  //     ],
  //   );
  // }

  // Widget _buildValueView(
  //     {required String title,
  //     required String value,
  //     int flex = 2,
  //     double sizeFont = 14,
  //     Color titleColor = Colors.black,
  //     Color valueColor = Colors.black,
  //     bool valueBold = false}) {
  //   final titleTextStyle = TextStyle(
  //     fontWeight: FontWeight.bold,
  //     color: titleColor,
  //     fontSize: sizeFont,
  //   );
  //   final valueTextStyle = TextStyle(
  //     fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
  //     color: valueColor,
  //     fontSize: sizeFont,
  //   );
  //   return Flexible(
  //     flex: flex,
  //     child: RichText(
  //       maxLines: 3,
  //       textAlign: TextAlign.start,
  //       text: TextSpan(
  //         children: [
  //           TextSpan(text: '$title: ', style: titleTextStyle),
  //           TextSpan(text: value, style: valueTextStyle),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

class _ButtonsCards extends StatelessWidget {
  final int totalIncorrectas;
  final int totalSinEtiqueta;
  final int totalsinPromocion;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _ButtonsCards({
    required this.totalIncorrectas, 
    required this.totalSinEtiqueta,
    required this.totalsinPromocion,
    required this.selectedIndex,
    required this.onSelected, 
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Card(
        color: Colors.white,
        elevation: 4,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: ChipButton(
                    label: "Incorrectas",
                    number: totalIncorrectas,
                    icon: Icons.loyalty_outlined,
                    isSelected: selectedIndex == 0,
                    onTap: () => onSelected(0),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: ChipButton(
                    label: "Sin etiqueta",
                    number: totalSinEtiqueta,
                    icon: Icons.disabled_by_default_outlined,
                    isSelected: selectedIndex == 1,
                    onTap: () => onSelected(1),
                  ),
                ),
              ),
               Expanded(
                child: Center(
                  child: ChipButton(
                    label: "Sin promoción",
                    number: totalsinPromocion,
                    icon: Icons.price_change_outlined,//Icons.do_not_disturb_off_outlined,
                    isSelected: selectedIndex == 2,
                    onTap: () => onSelected(2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChipButton extends StatelessWidget {
  final String label;
  final int number;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const ChipButton({
    super.key,
    required this.label,
    required this.number,
    required this.icon,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Color(0xff636ae8);
    final Color inactiveColor = Colors.grey.shade600;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (number > 0) ?Colors.red : Colors.grey,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$number',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PreviewPage extends StatelessWidget {
  final String imageUrl;

  const PreviewPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Imagen del producto',
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
      body: Center(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(), // Placeholder de carga
          ),
          errorWidget: (context, url, error) => Container(
            width: 40,
            height: 40,
            color: Colors.grey[200],
            child: Image.network(
              'https://cdn-icons-png.flaticon.com/512/1257/1257249.png',
              fit: BoxFit.cover,
            ),
          ),
          imageBuilder: (context, imageProvider) => PhotoView(imageProvider: imageProvider)
        ),
      ),
    );
  }
}

