import 'package:flutter/material.dart';

import '../../../theme/hikey_theme.dart';

class RecenterButton extends StatelessWidget {
  const RecenterButton({
    super.key,
    required this.visible,
    required this.onPressed,
    this.size = 44,
  });

  final bool visible;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedScale(
        scale: visible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        curve: visible ? Curves.easeOutBack : Curves.easeIn,
        child: SizedBox.square(
          dimension: size,
          child: IconButton(
            tooltip: 'Recenter',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: HikeyTheme.primaryGreen,
              elevation: 2,
              shadowColor: Colors.black45,
            ),
            iconSize: 22,
            onPressed: onPressed,
            icon: const Icon(Icons.my_location_rounded),
          ),
        ),
      ),
    );
  }
}
