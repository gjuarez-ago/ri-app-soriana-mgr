import 'dart:io';
import 'package:ago_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PdfViewByURL extends StatefulWidget {
  const PdfViewByURL({super.key, required this.url});

  final String? url;

  @override
  State<PdfViewByURL> createState() => _PdfViewByURLState();
}

class _PdfViewByURLState extends State<PdfViewByURL> {
  String? pdfFilePath;
  bool isLoading = true; // Indica si el archivo está descargando
  String? errorMessage; // Mensaje de error, si ocurre

  @override
  void initState() {
    super.initState();
    if (widget.url != null && widget.url!.isNotEmpty) {
      downloadAndStorePdf(widget.url!);
    } else {
      setState(() {
        errorMessage = 'URL no válida';
        isLoading = false;
      });
    }
  }

  Future<void> downloadAndStorePdf(String pdfUrl) async {
    try {
      final response = await http.get(
        Uri.parse(pdfUrl),
        headers: {
          'Authorization': 'Bearer ${Constants.token}', // Agregando el header
        },
      );

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/temp.pdf');
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          pdfFilePath = file.path;
          isLoading = false; // Descarga completa
        });
      } else {
        throw Exception('Error al descargar el archivo: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'No se pudo descargar el PDF. Error: $e';
        isLoading = false;
      });
    }
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : (errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : SafeArea(
                child: PDFView(
                    filePath: pdfFilePath,
                  ),
                )
            ),
    );
  }
}
