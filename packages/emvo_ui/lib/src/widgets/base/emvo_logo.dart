import 'package:flutter/material.dart';

import '../../theme/emvo_colors.dart';

class EmvoLogo extends StatelessWidget {
  final double size;
  final bool showTagline;

  const EmvoLogo({
    super.key,
    this.size = 48,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: EmvoColors.primaryGradient,
            borderRadius: BorderRadius.circular(size * 0.25),
          ),
          child: Center(
            child: Text(
              'E',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 8),
          Text(
            'Emvo',
            style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.bold,
              color: EmvoColors.primary,
            ),
          ),
        ],
      ],
    );
  }
}
