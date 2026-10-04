import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppCrest extends StatelessWidget {
  final double size;
  final bool showBadge;

  const AppCrest({
    super.key,
    this.size = 80,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFFFAF2E1),
            Color(0xFFF6E7C8),
          ],
        ),
        border: Border.all(
          color: AppTheme.goldAccent,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldAccent.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.76,
          height: size * 0.76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryCrimson,
            border: Border.all(
              color: Colors.white,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.apartment_rounded,
              color: AppTheme.goldAccent,
              size: size * 0.42,
            ),
          ),
        ),
      ),
    );
  }
}
