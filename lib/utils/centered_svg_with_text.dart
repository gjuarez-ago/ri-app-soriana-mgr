import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CenteredSvgWithText extends StatelessWidget {
  final String svgPath;
  final String text;
  final double widthPercentage;
  final double heightPercentage;

  const CenteredSvgWithText({
    super.key,
    required this.svgPath,
    required this.text,
    this.widthPercentage = 0.8,
    this.heightPercentage = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * widthPercentage,
          maxHeight: MediaQuery.of(context).size.height * heightPercentage,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.15,
                ),
                child: SvgPicture.asset(
                  svgPath,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 55),
              Flexible(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}