import 'package:flutter/material.dart';

class SimpleAlertDialog extends StatelessWidget {
  final String title;
  final String description;
  final String acceptText;
  final String closeText;
  final VoidCallback onAccept;
  final VoidCallback onClose;
  // REMOVE THIS: final BuildContext context; // ← Elimina esta línea

  const SimpleAlertDialog({
    Key? key,
    required this.title,
    required this.description,
    this.acceptText = 'Aceptar',
    this.closeText = 'Cerrar',
    required this.onAccept,
    required this.onClose,
    // REMOVE THIS: required this.context, // ← Elimina esta línea
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ← Este context es el correcto
    return Dialog(
               backgroundColor: const Color.fromARGB(255, 255, 255, 255), // 👈 Fondo del diálogo

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 25),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 300) {
                  return Column(
                    children: [
                      _buildButton(acceptText, Colors.green, onAccept),
                      const SizedBox(height: 10),
                      _buildButton(
                        closeText,
                        const Color.fromARGB(255, 255, 0, 0),
                        onClose,
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildButton(acceptText, Colors.green, onAccept),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildButton(
                          closeText,
                          const Color.fromARGB(255, 255, 0, 0),
                          onClose,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal:10 ),
      
    fixedSize: const Size.fromWidth(200), // 👈 Solo ancho fijo
    ),
    onPressed: onPressed,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );
}
}
