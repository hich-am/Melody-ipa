import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ambient_background.dart';
import '../../widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _highQualityAudio = false;
  bool _downloadOverWifi = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _highQualityAudio = prefs.getBool('highQualityAudio') ?? false;
      _downloadOverWifi = prefs.getBool('downloadOverWifi') ?? true;
    });
  }

  Future<void> _updateSetting(String key, bool value, Function(bool) updater) async {
    updater(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        content: SingleChildScrollView(
          child: Text(content, style: TextStyle(color: AppColors.onSurfaceVariant)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text('SETTINGS', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text('Preferences', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          'Push Notifications',
                          'Receive updates about new releases and mixes',
                          Icons.notifications_outlined,
                          _notificationsEnabled,
                          (val) => _updateSetting('notificationsEnabled', val, (v) => setState(() => _notificationsEnabled = v)),
                        ),
                        Divider(color: AppColors.outlineVariant, height: 32),
                        _buildSwitchTile(
                          'High Quality Audio',
                          'Stream music in maximum quality (uses more data)',
                          Icons.high_quality,
                          _highQualityAudio,
                          (val) => _updateSetting('highQualityAudio', val, (v) => setState(() => _highQualityAudio = v)),
                        ),
                        Divider(color: AppColors.outlineVariant, height: 32),
                        _buildSwitchTile(
                          'Download Over Wi-Fi Only',
                          'Save cellular data by downloading only on Wi-Fi',
                          Icons.wifi,
                          _downloadOverWifi,
                          (val) => _updateSetting('downloadOverWifi', val, (v) => setState(() => _downloadOverWifi = v)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text('About', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildListTile(
                          'Terms of Service', 
                          Icons.description_outlined, 
                          () => _showInfoDialog('Terms of Service', 'These are the dummy terms of service for Melody. By using this app, you agree to enjoy high-quality music.')
                        ),
                        Divider(color: AppColors.outlineVariant, height: 32),
                        _buildListTile(
                          'Privacy Policy', 
                          Icons.privacy_tip_outlined, 
                          () => _showInfoDialog('Privacy Policy', 'Your privacy is important to us. We only use your data to recommend better music and track your listening goals.')
                        ),
                        Divider(color: AppColors.outlineVariant, height: 32),
                        _buildListTile(
                          'App Version', 
                          Icons.info_outline, 
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Melody is up to date!'), behavior: SnackBarBehavior.floating),
                            );
                          }, 
                          trailing: Text('1.0.0', style: TextStyle(color: AppColors.outline))
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: AppColors.outline, fontSize: 12)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildListTile(String title, IconData icon, VoidCallback onTap, {Widget? trailing}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.outline, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            if (trailing != null) trailing else Icon(Icons.arrow_forward_ios, color: AppColors.outline, size: 16),
          ],
        ),
      ),
    );
  }
}
