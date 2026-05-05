import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ambient_background.dart';
import '../../widgets/glass_card.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: Stack(
          children: [
            // Side illustration for wide screens
            if (MediaQuery.of(context).size.width > 800)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAhBMuKz_vvw6sJdWp6CyIfoj2bNppJgTxFy9VQzbKjwEQxD2ERpmk68BugYp70FFr6L1VKG3ziTywS3KhHFP713tmGlx4fdYWFM__y6e_lOKVDryQALewJ-RKiWO8EzHmBhQ4sQIhYHShbOPfDZlZ8JEJMeYHrFuYhqrLvyByI2nVylbULF63RMKzGYG3m1jUNH3cfgH61fV0vjF_jisLLr_abiRqy_-8s2Ye-D7UDCXGOiclBwucrWnk8StdP3sRtOWtHw-YYLew'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
                    ),
                  ),
                ),
              ),

            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('MELODY', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 2)),
                        const SizedBox(height: 48),
                        
                        GlassCard(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.2),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.lock_reset, size: 64, color: AppColors.primary),
                              ),
                              const SizedBox(height: 32),
                              Text('Lost your rhythm?', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              Text(
                                "Enter your email and we'll send you a link to get back to the music.",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 40),
                              
                              TextField(
                                style: TextStyle(color: AppColors.onSurface),
                                decoration: InputDecoration(
                                  hintText: 'Email address',
                                  hintStyle: TextStyle(color: AppColors.outline.withValues(alpha: 0.5)),
                                  prefixIcon: Icon(Icons.mail_outline, color: AppColors.outline),
                                  filled: true,
                                  fillColor: AppColors.surfaceContainerHigh,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: AppColors.secondary.withValues(alpha: 0.3))),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer]),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: Text('Send Reset Link', style: TextStyle(color: AppColors.onPrimaryFixed, fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
                                label: Text('Back to login', style: TextStyle(color: AppColors.onSurfaceVariant)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
