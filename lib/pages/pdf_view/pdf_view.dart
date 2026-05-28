import 'package:ago_app/bloc/bloc.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

// Importamos el Bloc y eventos

class PdfView extends StatefulWidget {

    static String routeName = "pdf_view";

      final String? category;
      final int? store;

  const PdfView({super.key, this.category,  this.store});

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  
  String? filePath;
  RIBloc? _riBloc;

 @override
  void initState() {

    print("store: ${widget.store}, category: ${widget.category}");
    
    super.initState();
    _riBloc = BlocProvider.of<RIBloc>(context);
    _riBloc?.add(EventPdfView(store: widget.store!, category: widget.category!));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: const Text(
          'Visor PDF',
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
            if (state is ErrorPdfView) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('No existe un PDF disponible, para los filtros seleccionados')
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is IsLoadingPdfView) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SuccessPdfView) {
              return PDFView(
                filePath: state.response,
              );
            } else if (state is ErrorPdfView) {
              return Padding(
                padding: const EdgeInsets.all(50.0),
                child: Center(child: Text('No existe un PDF disponible, para los filtros seleccionados', textAlign: TextAlign.center,)),
              );
            } else {
              return const Center(child: Text('Esperando...'));
            }
          },
        ),
      ),
    );
  }
}
