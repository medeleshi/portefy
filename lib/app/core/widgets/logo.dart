import 'package:flutter/material.dart';

import '../app_images.dart';

class Logo extends StatelessWidget {
  final double? width;
  final double? height;
  const Logo({super.key, this.width = 48, this.height = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: AssetImage(AppImages.logo)),
      ),
    );
  }
}
