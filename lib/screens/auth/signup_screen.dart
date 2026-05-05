import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ambient_background.dart';
import '../../widgets/glass_card.dart';
import '../../core/services/firebase_auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _birthdateCtrl = TextEditingController();

  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _birthdateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimaryFixed,
            surface: AppColors.surfaceContainer,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthdateCtrl.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _signUp() async {
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        _selectedDate == null) {
      _showError('Please fill in all fields.');
      return;
    }

    if (password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuthService.instance.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        birthDate: _selectedDate!,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Sign-up failed.');
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: AmbientBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              title: Text('MELODY',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2)),
              actions: [
                if (isWide) ...[
                  TextButton(
                      onPressed: () {},
                      child: Text('EXPLORE',
                          style: TextStyle(color: AppColors.outline))),
                  TextButton(
                      onPressed: () {},
                      child: Text('PREMIUM',
                          style: TextStyle(color: AppColors.outline))),
                  TextButton(
                      onPressed: () {},
                      child: Text('SUPPORT',
                          style: TextStyle(color: AppColors.outline))),
                ],
                SizedBox(width: 16),
                CircleAvatar(
                  backgroundColor: AppColors.surfaceContainerHighest,
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
                SizedBox(width: 24),
              ],
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: 24.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildHero(context)),
                        SizedBox(width: 48),
                        Expanded(child: _buildForm(context)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildHero(context),
                        SizedBox(height: 48),
                        _buildForm(context),
                        SizedBox(height: 48),
                      ],
                    )
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('EXCLUSIVE ACCESS',
                  style: TextStyle(
                      color: AppColors.tertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              SizedBox(width: 8),
              Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.tertiary)),
            ],
          ),
        ),
        SizedBox(height: 24),
        Text('Your Sound,\nReimagined.',
            style: Theme.of(context).textTheme.displayMedium),
        SizedBox(height: 16),
        Text(
          'Join the sanctuary of high-fidelity audio. Experience music with the editorial depth it deserves.',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        SizedBox(height: 32),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBBgRo9Pk14lvTUFoMNHrwEDIXqGThFgIujmuMq8fPn4SdmHKYItO15gDofeCzaKHVc1xW2yXQQgHoXZk14-ag2Ops8NLHfVvtmeg1M0qNskKBi--nmLKYwDWdaRAekSDzw04gF3yatvzadACPw6ijp4C_62E5FwOyH4qF6JktpNzOfAHdWIMlGpnEULkFvHhEBXXLOaRLFDD4Zl14s1XDwWSoGuTp732ahpMf3i7bHVDoPzBDVaeFG6fb-8l9hNmjcjwcL5tjlT_c'),
              fit: BoxFit.cover,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create Account',
                        style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: 8),
                    Text('Step 1 of 1: Personal Profile',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor: AppColors.surfaceContainerHigh,
                child:
                    Icon(Icons.music_note, color: AppColors.secondary),
              ),
            ],
          ),
          SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                  child: _buildInput('NAME', 'John',
                      controller: _firstNameCtrl)),
              SizedBox(width: 16),
              Expanded(
                  child: _buildInput('SURNAME', 'Doe',
                      controller: _lastNameCtrl)),
            ],
          ),
          SizedBox(height: 16),
          _buildInput('EMAIL ADDRESS', 'john.doe@example.com',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress),
          SizedBox(height: 16),
          // Birthdate (tap to open picker)
          GestureDetector(
            onTap: _pickDate,
            child: AbsorbPointer(
              child: _buildInput('BIRTHDATE', 'MM/DD/YYYY',
                  controller: _birthdateCtrl, suffix: Icons.calendar_month),
            ),
          ),
          SizedBox(height: 16),
          _buildInput('PASSWORD', '••••••••',
              controller: _passwordCtrl,
              suffix: _obscurePassword
                  ? Icons.visibility
                  : Icons.visibility_off,
              obscure: _obscurePassword,
              onSuffixTap: () =>
                  setState(() => _obscurePassword = !_obscurePassword)),
          SizedBox(height: 32),

          // Join Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(
                      color: AppColors.onPrimaryFixed, strokeWidth: 2)
                  : Text('JOIN MELODY',
                      style: TextStyle(
                          color: AppColors.onPrimaryFixed,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
            ),
          ),
          SizedBox(height: 32),
          Center(
            child: Text(
              'By joining Melody, you confirm you are 13+ years of age and agree to our Terms of Sound and Privacy Policy.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.outline, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    String label,
    String hint, {
    TextEditingController? controller,
    IconData? suffix,
    bool obscure = false,
    TextInputType? keyboardType,
    VoidCallback? onSuffixTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: AppColors.outline)),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: TextStyle(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: AppColors.outline.withValues(alpha: 0.5)),
            suffixIcon: suffix != null
                ? IconButton(
                    icon: Icon(suffix, color: AppColors.outline),
                    onPressed: onSuffixTap,
                  )
                : null,
            filled: true,
            fillColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
            contentPadding:
                EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
