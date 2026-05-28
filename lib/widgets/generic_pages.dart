import 'package:flutter/material.dart';

class CenteredImageWithText extends StatelessWidget {

  final String assetPath;
  final String title;
  final String description;

  const CenteredImageWithText({
    Key? key,
    required this.assetPath,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 25), // Espacio entre el título y la descripción

        // Imagen centrada

        Image.asset(
          assetPath,
          height: 150, // Ajusta el tamaño de la imagen según tu necesidad
          width: 150,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 20), // Espacio entre la imagen y el título

        // Título debajo de la imagen
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10), // Espacio entre el título y la descripción

        // Descripción debajo del título
        Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class CenteredImageWithTextAndButton extends StatelessWidget {
  final String assetPath;
  final String title;
  final String description;
  final String buttonTitle; // Título del botón
  final VoidCallback onPressed; // Función para manejar el evento del botón
  final showButton;

  const CenteredImageWithTextAndButton({
    Key? key,
    required this.assetPath,
    required this.title,
    required this.description,
    required this.buttonTitle, // Botón requerido
    required this.onPressed, // Función requerida
    required this.showButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 25), // Espacio entre el título y la descripción

        // Imagen centrada
        Image.asset(
          assetPath,
          height: 150, // Ajusta el tamaño de la imagen según tu necesidad
          width: 150,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 20), // Espacio entre la imagen y el título

        // Título debajo de la imagen
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10), // Espacio entre el título y la descripción

        // Descripción debajo del título
        Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20), // Espacio entre la descripción y el botón

        // Botón debajo de la descripción
        if (showButton)
          ElevatedButton.icon(
            onPressed: onPressed, // Llamada a la función proporcionada
            icon: const Icon(
                Icons.arrow_forward), // Ícono a la izquierda del texto
            label: Text(buttonTitle), // Texto del botón
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                // Esquinas redondeadas
                borderRadius: BorderRadius.circular(
                    12), // Ajusta el valor para más o menos redondeo
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12), // Padding opcional para más espacio
            ),
          )
      ],
    );
  }
}

Widget errorWidget = Stack(
  children: [
    Positioned(
      top: 24,
      bottom: 350,
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Image.asset('assets/images/planet.png'),
      ),
    ),
    Positioned(
      top: 120,
      bottom: 0,
      left: 24,
      right: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text(
            'Uy, un error ',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 30,
                letterSpacing: 2,
                color: Color(0xff2f3640),
                fontFamily: 'Anton',
                fontWeight: FontWeight.bold),
          ),
          Text(
            'Ha ocurrido un error, contacte al administrador.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Color(0xff2f3640),
            ),
          ),
        ],
      ),
    )
  ],
);

Widget comingSoonWidget = Stack(
  children: [
    Positioned(
      top: 24,
      bottom: 350,
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Image.asset('assets/images/coming-soon.png'),
      ),
    ),
    Positioned(
      top: 120,
      bottom: 0,
      left: 24,
      right: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text(
            'Próximamente',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 30,
                letterSpacing: 2,
                color: Color(0xff2f3640),
                fontFamily: 'Anton',
                fontWeight: FontWeight.bold),
          ),
          Text(
            'Nos encontramos trabajando en ello',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Color(0xff2f3640),
            ),
          ),
        ],
      ),
    )
  ],
);
