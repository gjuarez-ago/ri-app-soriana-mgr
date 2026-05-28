import 'package:ago_app/bloc/ri/ri_bloc.dart';
import 'package:ago_app/bloc/ri/ri_event.dart';
import 'package:ago_app/bloc/ri/ri_state.dart';
import 'package:ago_app/models/implementation_of_planograms_item_response.dart';
import 'package:ago_app/models/nuevos_planogramas_impl_response.dart';
import 'package:ago_app/models/store_response.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImplementationOfPlanogramsPage extends StatefulWidget {
  const ImplementationOfPlanogramsPage({super.key});

  static String routeName = "implementation_of_planograms_page";

  @override
  State<ImplementationOfPlanogramsPage> createState() =>
      _ImplementationOfPlanogramsPageState();
}

class _ImplementationOfPlanogramsPageState
    extends State<ImplementationOfPlanogramsPage> {
  RIBloc? _riBloc; // Declaración del BLoC
  RIBloc? _riBlocSet; // Declaración del BLoC

  List<StoreResponse> listStoreResponse = [];
  StoreResponse? _selectedStore = null;

  bool caducadosSelected = false; //Filtro para mostrar solo caducados
  bool porImplementarSelected = false; //Filtro para mostrar solo por implementar
  bool implementadosSelected = false; //Filtro para mostrar solo implementados

  @override
  void initState() {
    super.initState();
    _riBloc = BlocProvider.of<RIBloc>(context); // Obtener instancia del BLoC
    _riBlocSet = BlocProvider.of<RIBloc>(context); // Obtener instancia del BLoC para set
    _riBloc?.add(EventGetStoresIndicadores()); // Cargar tiendas al iniciar la página
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          'Nuevos Planogramas',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(

        // Agregar BlocListener para escuchar eventos específicos
        child: BlocListener<RIBloc, RIState>(
          listenWhen: (prev, curr) {
            return curr is EventGetStoresIndicadores ||
                   curr is SuccessSetPlanogramaImplementado;
          },
          listener: (context, state) {

            // Al cargar las tiendas
            if (state is EventGetStoresIndicadores) {
              final claveTienda = _selectedStore?.claveTienda;
              if (claveTienda != null) {
                context.read<RIBloc>().add(EventGetStoresIndicadores());
              }
            }

            // Al marcar un planograma como implementado, se vuelve a cargar la lista de planogramas para reflejar el cambio
            if (state is SuccessSetPlanogramaImplementado) {
              final claveTienda = _selectedStore?.claveTienda;
              if (claveTienda != null) {
                context.read<RIBloc>().add(EventGetImplementationOfPlanograms(idTienda: claveTienda));
              }

              // Mostrar mensaje de confirmacion al marcar un planograma como implementado
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Implementación exitosa",
                    style: TextStyle(
                        color:
                            Color.fromARGB(255, 255, 255, 255)), // Texto blanco
                  ),
                  backgroundColor:
                      Color.fromARGB(255, 76, 175, 80), // Fondo verde
                ),
              );
            }
          },

          // El BlocBuilder se encarga de reconstruir la interfaz cuando cambian los estados 
          // relacionados con las tiendas o las implementaciones de planogramas
          child: BlocBuilder<RIBloc, RIState>(
            buildWhen: (previous, current) {
              return current is SuccessGetStore ||
                  current is IsLoadingGetStore ||
                  current is ErrorGetStore ||
                  current is SuccessGetImplementationOfPlanograms ||
                  current is IsLoadingImplementationOfPlanograms ||
                  current is ErrorGetImplementationOfPlanograms;
            },

            // El builder se encarga de construir la interfaz dependiendo del estado actual del BLoC
            builder: (context, state) {
              return _buildBodyContent(context,state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, RIState state) {

    // Solo carga el listado de tiendas, a la carga inicial  de la interfaz
    // y los mantiene para no consultar cada vez que se reconstruya el widget
    if (state is IsLoadingGetStore ||  state is ErrorGetStore || state is SuccessGetStore) {
      listStoreResponse = state is SuccessGetStore ? state.response : listStoreResponse;
      return Column(
        mainAxisSize: MainAxisSize.min, // Ayuda a que la columna no se expanda infinito
        children: [
          _buildStoreDropdownWithItems(
            context,
            listStoreResponse,
            _selectedStore,
            'Tienda',
            (value) {
              setState(() {
                _selectedStore = value;
                if (value != null) {
                  _riBloc?.add(EventGetImplementationOfPlanograms(idTienda: value.claveTienda));
                }
              });
            },
          ),
          // 3. Mostrar el loader de forma condicional sin romper el árbol
          if (state is IsLoadingGetStore ||
              state is IsLoadingImplementationOfPlanograms)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(),
            ),
        ],
      );
    } else if (state is IsLoadingImplementationOfPlanograms) {
      return Column(
        mainAxisSize:
            MainAxisSize.min, // Ayuda a que la columna no se expanda infinito
        children: [
          _buildStoreDropdownWithItems(
            context,
            listStoreResponse,
            _selectedStore,
            'Tienda',
            (value) {
              setState(() {
                _selectedStore = value;
                if (value != null) {
                  _riBloc?.add(EventGetImplementationOfPlanograms(
                      idTienda: value.claveTienda));
                }
              });
            },
          ),
          const SizedBox(height: 15),
          _Loader(),
        ],
      );
    } else if (state is SuccessGetImplementationOfPlanograms) {
      // listStoreResponse = listStoreResponse;
      return _buildPlanogramsList(context, state.response);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildPlanogramsList(
      BuildContext context, NuevosPlanogramasImplResponse implementaciones) {
    return Column(children: [
      _buildStoreDropdownWithItems(
        context,
        listStoreResponse,
        _selectedStore,
        'Tienda',
        (value) {
          setState(() {
            _selectedStore = value;
            if (value != null) {
              _riBloc?.add(EventGetImplementationOfPlanograms(
                  idTienda: _selectedStore!.claveTienda));
            }
          });
        },
      ),
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: _buildHeaderBox(
                  title: "Caducados",
                  value: '${implementaciones.caducados}',
                  titleColor: Colors.red,
                  borderColor: Colors.red.shade300,
                  valueColor: Colors.red.shade700,
                  backColor: Colors.pink.shade50,
                  onTap: () {
                    caducadosSelected = !caducadosSelected;
                    setState(() {});
                  },
                  selected: caducadosSelected),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHeaderBox(
                  title: "Por Implementar",
                  value: "${implementaciones.porImplementar}",
                  titleColor: Colors.blue,
                  borderColor: Colors.blue.shade300,
                  valueColor: Colors.blue.shade700,
                  backColor: Colors.blue.shade50,
                  onTap: () {
                    setState(() {
                      porImplementarSelected = !porImplementarSelected;
                    });
                  },
                  selected: porImplementarSelected),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHeaderBox(
                  title: "Implementados",
                  value: "${implementaciones.implementados}",
                  titleColor: Colors.black87,
                  borderColor: Colors.green.shade200,
                  valueColor: Colors.black,
                  backColor: Colors.green.shade50,
                  onTap: () {
                    setState(() {
                      implementadosSelected = !implementadosSelected;
                    });
                  },
                  selected: implementadosSelected),
            ),
          ],
        ),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(12.0), // Espaciado para toda la lista
          itemCount: implementaciones.planogramas.length,
          itemBuilder: (context, index) {
            final item = implementaciones.planogramas[index];
            // Filtrado en caso que seleccione alguna targeta del encabezado
            if (caducadosSelected && item.estatus == 'caducado')
              return Container();
            if (porImplementarSelected && item.estatus == 'por_implementar')
              return Container();
            if (implementadosSelected && item.estatus == 'implementado')
              return Container();
            return _buildStatusCard(
                item: item, idTienda: _selectedStore!.claveTienda);
          },
        ),
      ),
    ]);
  }

  Widget _buildHeaderBox({
    required String title,
    required String value,
    required Color titleColor,
    required Color borderColor,
    required Color valueColor,
    required Color backColor,
    required VoidCallback onTap,
    required bool selected,
  }) {
    // Colores grises para marcar cuando esten seleccionados
    final Color grayBg = Colors.grey.shade300;
    final Color grayBorder = Colors.grey.shade600;
    final Color grayText = Colors.grey.shade800;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 110,
          height: 110,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? grayBg : backColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? grayBorder : borderColor,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? grayText : titleColor,
                  decoration: selected
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              Expanded(child: Container()),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: selected ? grayText : valueColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required ImplementationOfPlanogramsItemResponse item,
    required int idTienda}) {
    
    final status = item.estatus; // Estatos: [caducado/por_implementar/implementado]

    // Colores por estado
    Color borderColor;
    Color bgColor;
    Color chipColor;
    Color chipTextColor = Colors.white;
    String statusLabel;

    switch (status) {
      case 'caducado':
        borderColor = Colors.red.shade300;
        bgColor = Colors.red.shade50;
        chipColor = Colors.red;
        statusLabel = "Caducado";
        break;

      case 'por_implementar':
        borderColor = Colors.blue.shade300;
        bgColor = Colors.white; 
        chipColor = Colors.blue;
        statusLabel = "Por Implementar";
        break;

      case 'implementado':
        borderColor = Colors.green.shade300;
        bgColor = Colors.white; 
        chipColor = Colors.green.shade200;
        chipTextColor = Colors.green.shade900;
        statusLabel = "Implementado";
        break;

      default:
        borderColor = Colors.grey.shade300;
        bgColor = Colors.white;
        chipColor = Colors.grey;
        statusLabel = "Desconocido";
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 2),
      ),
      color: bgColor,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: chipTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Text(
              item.categoria ?? 'Sin Categoría',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_month, size: 18, color: Colors.black),
                const SizedBox(width: 6),
                Text("Liberado: ${item.fechaCortaInicio}"),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 18, color: Colors.black),
                const SizedBox(width: 6),
                Text(
                  "Fecha Límite: ${item.fechaCortaFin}",
                  style: TextStyle(
                    color: status == "caducado" ? Colors.red : Colors.black87,
                    fontWeight: status == "caducado"
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (status != "implementado")
              _buildPrimaryButton(
                  "Marcar como Implementado", item.id!, idTienda)
            else
              _buildSuccessButton("Implementado")
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String text, int id, int idTienda) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: TextButton(
            onPressed: () {
              _showConfirmDialog(id, idTienda);
            },
            child: Text(text,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16))),
      )
    );
  }

  Widget _buildSuccessButton(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _showConfirmDialog(int id, int idTienda) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Confirmar",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          content: const Text(
            "¿Deseas marcar este planograma como implementado?",
          ),
          actions: [
            TextButton(
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.black87),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Color.fromARGB(176, 255, 255, 255)),
              child: const Text("Sí", style: TextStyle(color: Colors.black87)),
              onPressed: () {
                Navigator.pop(context);
                _riBlocSet!.add(EventSetPlanogramaImplementado(id: id, idTienda: idTienda));
              },
            ),
          ],
        );
      },
    );
  }

  Widget _Loader() {
    final message = <String>[
      'Consultado información',
      'Cargando datos',
      'Procesando los datos',
      'Generando interfaz',
      'Tardando mas de lo esperado :(',
    ];

    Stream<String> getLoadingMessages() {
      return Stream<String>.periodic(const Duration(milliseconds: 800),
          (count) {
        return message[count];
      }).take(message.length);
    }

    return Column(
      mainAxisSize: MainAxisSize.min, 
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("Espere por favor..."),
        const SizedBox(height: 10),
        const CircularProgressIndicator(strokeWidth: 2),
        const SizedBox(height: 10),
        StreamBuilder<String>(
          stream: getLoadingMessages(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text('Cargando...');
            } else {
              return Text(snapshot.data!);
            }
          },
        )
      ],
    );
  }

  Widget _buildStoreDropdownWithItems(
    BuildContext context,
    List<StoreResponse> items,
    StoreResponse? selectedItem,
    String labelText,
    Function(StoreResponse?) onChanged, {
    bool enabled = true,
    String? defaultText,
  }) {
    print('Construyendo dropdown de carga con datos...');
    print('Tiendas disponibles: ${items.length}');
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: DropdownSearch<StoreResponse>(
        // 1. PopupProps se mantiene similar, pero revisa nombres internos si fallan
        popupProps: const PopupProps.menu(
          menuProps: MenuProps(backgroundColor: Colors.white, elevation: 2),
          showSearchBox: true,
        ),

        // 2. Definir cómo comparar los elementos (Evita el error de pantalla roja)
        compareFn: (item1, item2) => item1.claveTienda == item2.claveTienda,

        items: (filter, props) => items,

        // 3. Mapeo de nombres: dropdownDecoratorProps -> decoratorProps
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            labelText: labelText,
            // Esto hace que la etiqueta flote siempre arriba
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: const OutlineInputBorder(),
            // Añade un poco de padding interno si el texto se ve muy pegado
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),

        itemAsString: (StoreResponse store) => store.tienda ?? '',

        // 4. Cambio en dropdownBuilder: Ahora suele recibir (context, item, isSelected)
        // o simplemente (context, item). En v6 el parámetro item puede ser nulo si no hay selección.
        dropdownBuilder: (context, item) {
          return Text(
            item?.tienda ?? defaultText ?? 'Selecciona una tienda',
            style: TextStyle(
              color: enabled
                  ? Colors.black
                  : Colors.grey, // Opcional: mejora visual si está disabled
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          );
        },

        onChanged: onChanged,
        selectedItem: selectedItem,
        enabled: enabled,
      ),
    );
  }
}
