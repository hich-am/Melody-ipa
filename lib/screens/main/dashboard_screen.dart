import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ambient_background.dart';
import '../../widgets/glass_card.dart';
import '../../core/services/stats_service.dart';
import '../../core/services/firebase_auth_service.dart';
import 'package:provider/provider.dart';
import '../../core/providers/music_provider.dart';
import '../../navigation/main_scaffold.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalSeconds = 0;
  int _thisMonthSeconds = 0;
  int _goalHours = 20;
  Map<DateTime, double> _last30DaysMinutes = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Widget _buildStaggeredEntry({required Widget child, required int index}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 150)),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Future<void> _loadStats() async {
    try {
      final total = await StatsService.instance.getTotalListeningSeconds();
      final thisMonthTotal = await StatsService.instance.getThisMonthTotalSeconds();
      final goal = await StatsService.instance.getMonthlyGoalHours();
      final last30Days = await StatsService.instance.getLast30DaysMinutes();
      if (mounted) {
        setState(() {
          _totalSeconds = total;
          _thisMonthSeconds = thisMonthTotal;
          _goalHours = goal;
          _last30DaysMinutes = last30Days;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Stats loading failed (offline?): $e');
    }
  }

  void _editProfile() {
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) return;
    
    final nameCtrl = TextEditingController(text: user.displayName);
    
    showDialog(
      context: context,
      builder: (context) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceContainerHigh,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Edit Profile', style: Theme.of(context).textTheme.titleLarge),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    style: TextStyle(color: AppColors.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: AppColors.outline.withValues(alpha: 0.8)),
                      filled: true,
                      fillColor: AppColors.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: AppColors.outline)),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    setDialogState(() => isSaving = true);
                    try {
                      await user.updateDisplayName(nameCtrl.text.trim());
                      if (mounted) {
                        setState(() {}); // refresh Dashboard UI
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Profile updated successfully'),
                            backgroundColor: AppColors.primary.withValues(alpha: 0.9),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      setDialogState(() => isSaving = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isSaving 
                      ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimaryFixed)) 
                      : Text('Save', style: TextStyle(color: AppColors.onPrimaryFixed, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context); // Force rebuild on theme change
    
    return Scaffold(
      body: AmbientBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                icon: Icon(Icons.menu, color: AppColors.primary), 
                onPressed: () => MainScaffold.of(context)?.openDrawer(),
              ),
              title: Text('MELODY', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, letterSpacing: 2)),
              actions: [
                CircleAvatar(
                  backgroundColor: AppColors.surfaceContainerHighest,
                  backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuD2RUf0361taIWjap8pCT6E9xx_aPCETtzPol369lfjNcA-cgOMVGcJFkU7R7cNKPR0U28Yfy-xSZI2yWO32Sukd7lBT4q2-kXnQQ0Qo9ZKtbyFuPOhpKEkKPbSZn8iPLxfOiQEOLlLowfTG6-38AUKi0k860xkkLCNP7ULg9aigjg0KsjKB3It2166Ods4-JM4NNVUkbcJzqMNgY8occF9FiK0KTFaVASMo_98dTU_eYqmcMQAL0bK9xLZeSv4Fk5erAybwrjH5e0'),
                ),
                SizedBox(width: 24),
              ],
            ),
            SliverPadding(
              padding: EdgeInsets.all(24.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: 8),
                  _buildStaggeredEntry(
                    index: 0,
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: -5,
                              )
                            ],
                            image: DecorationImage(
                              image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuD2RUf0361taIWjap8pCT6E9xx_aPCETtzPol369lfjNcA-cgOMVGcJFkU7R7cNKPR0U28Yfy-xSZI2yWO32Sukd7lBT4q2-kXnQQ0Qo9ZKtbyFuPOhpKEkKPbSZn8iPLxfOiQEOLlLowfTG6-38AUKi0k860xkkLCNP7ULg9aigjg0KsjKB3It2166Ods4-JM4NNVUkbcJzqMNgY8occF9FiK0KTFaVASMo_98dTU_eYqmcMQAL0bK9xLZeSv4Fk5erAybwrjH5e0'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(FirebaseAuthService.instance.currentUser?.displayName ?? 'Melody User', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text(FirebaseAuthService.instance.currentUser?.email ?? 'user@melody.app', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: AppColors.outline),
                          onPressed: _editProfile,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 48),

                  // Stats Grid Let's make it responsive
                  if (MediaQuery.of(context).size.width > 800)
                    _buildStaggeredEntry(
                      index: 1,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 1, child: _buildListeningTimeCard(context)),
                            SizedBox(width: 24),
                            Expanded(flex: 2, child: _buildActivityChartCard(context)),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        _buildStaggeredEntry(index: 1, child: _buildListeningTimeCard(context)),
                        SizedBox(height: 24),
                        _buildStaggeredEntry(index: 2, child: _buildActivityChartCard(context)),
                      ],
                    ),
                  
                  SizedBox(height: 24),
                  _buildStaggeredEntry(index: 3, child: _buildGoalCard(context)),

                  SizedBox(height: 48),
                  
                  // Most played tracks
                  _buildStaggeredEntry(
                    index: 4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Most Played Tracks', style: Theme.of(context).textTheme.headlineMedium),
                        TextButton(
                          onPressed: () {
                            MainScaffold.of(context)?.changeTab(0);
                          }, 
                          child: Text('SEE ALL', style: TextStyle(color: AppColors.primary, letterSpacing: 2, fontSize: 12))
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  _buildStaggeredEntry(
                    index: 5,
                    child: Consumer<MusicProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return Center(child: CircularProgressIndicator());
                        }
                        
                        final tracks = provider.currentTracks.take(4).toList();
                        if (tracks.isEmpty) {
                          return Text('No tracks available yet.', style: TextStyle(color: AppColors.outlineVariant));
                        }
                        
                        return GridView.count(
                          crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.8,
                          children: tracks.map((track) {
                            return _buildTrackCard(
                              context,
                              track.name,
                              track.artistName,
                              track.image.isNotEmpty ? track.image : 'https://fakeimg.pl/400x400/282828/eae0d0/'
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  
                  SizedBox(height: 120), // Bottom padding for nav bar
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListeningTimeCard(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL LISTENING TIME', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary)),
              Icon(Icons.schedule, color: AppColors.outlineVariant, size: 48),
            ],
          ),
          SizedBox(height: 16),
          Text(StatsService.formatSeconds(_totalSeconds), style: Theme.of(context).textTheme.displayMedium),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.secondary, size: 16),
              SizedBox(width: 8),
              Text('Keep it up!', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.secondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChartCard(BuildContext context) {
    // Convert daily stats to normalized heights for the histogram (max 60 mins)
    final last30Days = List.generate(30, (index) {
      final date = DateTime.now().subtract(Duration(days: 29 - index));
      final dateKey = DateTime(date.year, date.month, date.day);
      return _last30DaysMinutes[dateKey] ?? 0.0;
    });
    
    final maxMins = last30Days.reduce((a, b) => a > b ? a : b);
    final normalizationFactor = maxMins > 0 ? maxMins : 60.0;
    final heights = last30Days.map((m) => (m / normalizationFactor).clamp(0.0, 1.0)).toList();
    
    return GlassCard(
      padding: EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Activity', style: Theme.of(context).textTheme.headlineSmall),
              Text('LAST 30 DAYS', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          SizedBox(height: 32),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(heights.length, (index) {
                final isPeak = heights[index] > 0.9;
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: heights[index].toDouble()),
                  duration: Duration(milliseconds: 1000 + (index * 30)),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Container(
                      width: 4, // thin bars for 30 items
                      height: (120 * value).clamp(2.0, 120.0),
                      decoration: BoxDecoration(
                        color: isPeak ? AppColors.primary : AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                        boxShadow: isPeak ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: -2,
                          )
                        ] : null,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context) {
    final progress = _thisMonthSeconds / (_goalHours * 3600);
    final percentage = (progress * 100).clamp(0, 100).toInt();

    return GlassCard(
      padding: EdgeInsets.all(32),
      child: Flex(
        direction: MediaQuery.of(context).size.width > 600 ? Axis.horizontal : Axis.vertical,
        children: [
          Flexible(
            flex: MediaQuery.of(context).size.width > 600 ? 1 : 0,
            fit: MediaQuery.of(context).size.width > 600 ? FlexFit.tight : FlexFit.loose,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Monthly Goal ', style: Theme.of(context).textTheme.headlineSmall),
                    DropdownButton<int>(
                      value: _goalHours,
                      dropdownColor: AppColors.surfaceContainerHigh,
                      underline: SizedBox(),
                      icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
                      items: [10, 20, 30, 50].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('${value}h', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _goalHours = newValue;
                          });
                          StatsService.instance.setMonthlyGoalHours(newValue);
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(percentage >= 100 ? "Goal Met!" : "Keep listening!", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width > 600 ? 0 : 24, width: 24),
          Flexible(
            flex: MediaQuery.of(context).size.width > 600 ? 2 : 0,
            fit: MediaQuery.of(context).size.width > 600 ? FlexFit.tight : FlexFit.loose,
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.centerLeft,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: progress.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutQuart,
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: -2,
                          )
                        ],
                      ),
                    ),
                  );
                }
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width > 600 ? 0 : 24, width: 24),
          Text('$percentage%', style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }

  Widget _buildTrackCard(BuildContext context, String title, String subtitle, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
          ),
        ),
        SizedBox(height: 12),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}
