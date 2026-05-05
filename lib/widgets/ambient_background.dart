import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

class AmbientBackground extends StatefulWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Force rebuild on theme change
    
    return Stack(
      children: [
        // Background color
        Container(color: theme.scaffoldBackgroundColor),
        // Ambient glows
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final sinValue = math.sin(_controller.value * math.pi * 2);
            final cosValue = math.cos(_controller.value * math.pi * 2);
            return Stack(
              children: [
                Positioned(
                  top: -100 + (50 * sinValue),
                  left: -100 + (30 * cosValue),
                  child: Transform.scale(
                    scale: 1.0 + (0.1 * sinValue),
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: AppColors.isDarkMode ? 0.3 : 0.4),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100 + (40 * cosValue),
                  right: -100 + (60 * sinValue),
                  child: Transform.scale(
                    scale: 1.0 + (0.15 * cosValue),
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                      child: Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.secondary.withValues(alpha: AppColors.isDarkMode ? 0.3 : 0.4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        // Foreground content
        SafeArea(child: widget.child),
      ],
    );
  }
}
