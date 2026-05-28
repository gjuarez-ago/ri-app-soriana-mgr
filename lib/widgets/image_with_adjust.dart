import 'package:flutter/material.dart';
class ImageWithAutoAdjust extends StatefulWidget {
  final ImageProvider imageProvider;
  final double width;
  final double height;

  const ImageWithAutoAdjust({
    super.key,
    required this.imageProvider,
    this.width = 40,
    this.height = 40,
  });

  @override
  State<ImageWithAutoAdjust> createState() => _ImageWithAutoAdjustState();
}

class _ImageWithAutoAdjustState extends State<ImageWithAutoAdjust> {
  bool _rotate = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() {
    final imageStream =
        widget.imageProvider.resolve(const ImageConfiguration());
    imageStream.addListener(
      ImageStreamListener((imageInfo, _) {
        final width = imageInfo.image.width;
        final height = imageInfo.image.height;
        if (mounted) {
          setState(() {
            _rotate = width > height;
          });
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget image = Image(
      image: widget.imageProvider,
      fit: BoxFit.cover,
      width: widget.width,
      height: widget.height,
    );

    if (_rotate) {
      image = RotatedBox(quarterTurns: 1, child: image);
    }

    return image;
  }
}
