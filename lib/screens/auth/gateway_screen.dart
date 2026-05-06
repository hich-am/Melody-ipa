import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ambient_background.dart';
import '../../widgets/glass_card.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class GatewayScreen extends StatefulWidget {
  const GatewayScreen({super.key});

  @override
  State<GatewayScreen> createState() => _GatewayScreenState();
}

class _GatewayScreenState extends State<GatewayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isAuthenticating = false;
  String _statusMessage = 'Touch to Start';
  String _statusSub = 'TAP TO CONTINUE';
  Color _ringColor = AppColors.primary;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8),
    )..repeat();

    // Auto-proceed on screen open without biometric gating.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enterApp();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _enterApp() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _statusMessage = 'Opening…';
      _statusSub = 'PREPARING YOUR SESSION';
    });

    if (!mounted) return;
    SystemSound.play(SystemSoundType.click);
    setState(() {
      _statusMessage = 'Ready ✓';
      _statusSub = 'WELCOME BACK';
      _ringColor = AppColors.secondary;
    });
    await Future.delayed(Duration(milliseconds: 500));
    _navigateAfterAuth();
  }

  void _navigateAfterAuth() {
    if (!mounted) return;
    try {
      final user = FirebaseAuth.instance.currentUser;
      Navigator.pushReplacementNamed(
        context,
        user != null ? '/main' : '/login',
      );
    } catch (e) {
      debugPrint('⚠️ Firebase auth check failed: $e');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 80),
            // Header
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuARS3P3V3RnTR4MDqDZg89Zk0BMamfjP_fmRTLE0pGF3oAJ5gHge6MtOoWNVuEEcPlRUB-fNXepgsRc429Hl_ULTdLMvJUxt9GFB8JCW0NEJbCsKJXVL6Zgb_8DxIBpLtS_whpGjDE0eLey5Gxna8_FZjwRi2uj7cqlgt3Mtfsr8p1_rPTK_yvH9kle_8JD6mMMg2mDIy5L46Ad-UVwlx9JaOFUA_KAk_d8RRR9X6tVXtrOIGIYWh58nURuB00d302VojEmwROf0Do',
                fit: BoxFit.cover,
                opacity: AlwaysStoppedAnimation(0.8),
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: AppColors.surfaceContainerHighest),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'MELODY',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 4.0,
                  ),
            ),
            SizedBox(height: 8),
            Text(
              'SECURE GATEWAY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[400],
                  ),
            ),

            Spacer(),

            // Biometric Fingerprint Section
            GestureDetector(
              onTap: _enterApp,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Outer Glow / Glass
                  Container(
                    width: 192,
                    height: 192,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _ringColor.withValues(alpha: 0.2),
                          blurRadius: 80,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: GlassCard(
                      blur: 40,
                      borderRadius: 100,
                      padding: EdgeInsets.zero,
                      child: Center(
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: _ringColor.withValues(alpha: 0.2)),
                          ),
                          child: Center(
                            child: Container(
                              width: 128,
                              height: 128,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.secondary.withValues(alpha: 0.1)),
                              ),
                              child: Center(
                                child: _isAuthenticating
                                    ? CircularProgressIndicator(
                                        color: _ringColor,
                                        strokeWidth: 2,
                                      )
                                    : Icon(
                                        Icons.fingerprint,
                                        size: 72,
                                        color: _ringColor,
                                        shadows: [
                                          Shadow(
                                            color: _ringColor.withValues(alpha: 0.6),
                                            blurRadius: 15,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Spinner
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, child) {
                      return Transform.rotate(
                        angle: _controller.value * 2 * math.pi,
                        child: SizedBox(
                          width: 192,
                          height: 192,
                          child: CustomPaint(
                            painter: _ArcPainter(
                              color: _ringColor.withValues(alpha: 0.4),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  Positioned(
                    bottom: -60,
                    child: Column(
                      children: [
                        Text(
                          _statusMessage,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 4),
                        Text(
                          _statusSub,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Spacer(),

            // Footer
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  Container(
                    height: 4,
                    width: 128,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 4,
                      width: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primaryContainer
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Text('Enter with Pin',
                            style: TextStyle(
                                color: AppColors.onPrimaryFixed,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                          child: Divider(color: AppColors.outlineVariant)),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'OR CONNECT WITH',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(fontSize: 10),
                        ),
                      ),
                      Expanded(
                          child: Divider(color: AppColors.outlineVariant)),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.g_mobiledata,
                                  size: 24,
                                  color: AppColors.onSurfaceVariant),
                              SizedBox(width: 8),
                              Text('Google',
                                  style: TextStyle(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: GlassCard(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.apple,
                                  size: 24,
                                  color: AppColors.onSurfaceVariant),
                              SizedBox(width: 8),
                              Text('Apple ID',
                                  style: TextStyle(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _ArcPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    // Draw a quarter-circle arc
    canvas.drawArc(rect, -math.pi / 2, math.pi / 2, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}
