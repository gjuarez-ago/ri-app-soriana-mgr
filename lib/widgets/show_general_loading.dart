import 'package:flutter/material.dart';

void showGeneralLoading(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
                            backgroundColor: Colors.white,

        child: Container(
          margin: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 20.0),
              Text("Cargando...", style: TextStyle(fontSize: 16.0)),
            ],
          ),
        ),
      );
    },
  );
}