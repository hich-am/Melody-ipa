import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool border;
  final double blur;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    this.borderRadius = 16.0,
    this.border = true,
    this.blur = 40.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            gradient: color == null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.surfaceVariant.withValues(alpha: AppColors.isDarkMode ? 0.6 : 0.8),
                      AppColors.surfaceVariant.withValues(alpha: AppColors.isDarkMode ? 0.2 : 0.4),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border
                ? Border.all(
                    color: AppColors.isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                spreadRadius: -5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
