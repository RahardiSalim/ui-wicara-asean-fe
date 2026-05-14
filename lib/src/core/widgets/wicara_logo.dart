import 'package:flutter/material.dart';

class WicaraLogo extends StatelessWidget {
  const WicaraLogo({
    this.width = 220,
    this.height,
    this.alignment = Alignment.center,
    super.key,
  });

  static const assetPath = 'lib/src/assets/iconText.png';

  final double width;
  final double? height;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'WICARA',
      child: Align(
        alignment: alignment,
        child: Image.asset(
          assetPath,
          width: width,
          height: height,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
