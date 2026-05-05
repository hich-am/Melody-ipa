import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ambient_background.dart';
import '../../widgets/glass_card.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/firebase_auth_service.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/audio_player_service.dart';
import '../../core/models/track.dart';
import '../../navigation/main_scaffold.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _uid = FirebaseAuthService.instance.currentUser?.uid;

  Future<void> _deleteWithBiometric(String trackId) async {
    final success = await BiometricService.instance.authenticate(
      reason: 'Please authenticate to delete this favorite',
    );
    if (success && _uid != null) {
      await FirestoreService.instance.removeFavorite(_uid, trackId);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication failed. Cannot delete track.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context); // Force rebuild on theme change
    final isWide = MediaQuery.of(context).size.width > 800;

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
                if (isWide) Center(child: Text('Favorites', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
                SizedBox(width: 24),
                CircleAvatar(
                  backgroundColor: AppColors.surfaceContainerHighest,
                  backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBvZfVA1CR3-w7dNtU2wXcxRaOoPdjp1FlWAZO6kQw5UkT5VREof2lB68gshy_RUqdVrqTidz6SZOXa2xFG8t9stpX0wpT140BrSpZIo0oJVdfXjbe9_VKQJRJTP4KCjtFQc6pkRWcZFC3YRGb-zo93b0NHAXmvtrwljLnApABg8VHmYjwwuXarg_Q5ngeUGnzomOUq3RnLYmE4wNDj1TwblDuFsT-1OGeuOqpiC5aNmH0WF2CbSzWHqncaWb3ZRsVIQdV03drYbc4'),
                ),
                SizedBox(width: 24),
              ],
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  
                  // Header section
                  Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: isWide ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('YOUR COLLECTION', style: TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                          SizedBox(height: 8),
                          Text('Favorites', style: Theme.of(context).textTheme.displayLarge),
                        ],
                      ),
                      if (!isWide) SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fingerprint, color: AppColors.primary),
                            SizedBox(width: 12),
                            Text('Biometric auth required\nfor track removal', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      )
                    ],
                  ),
                  
                  SizedBox(height: 48),

                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildTrackList(context)),
                        SizedBox(width: 32),
                        Expanded(flex: 1, child: _buildStatsSidebar(context)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildTrackList(context),
                        SizedBox(height: 48),
                        _buildStatsSidebar(context),
                      ],
                    ),

                  SizedBox(height: 120), // nav bar padding
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackList(BuildContext context) {
    if (_uid == null) return Center(child: Text("Please log in."));
    
    return StreamBuilder<List<Track>>(
      initialData: <Track>[],
      stream: FirestoreService.instance.favoritesStream(_uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        final tracks = snapshot.data ?? [];
        if (tracks.isEmpty) {
           return Text("No favorites added yet.");
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(flex: 2, child: Text('TRACK', style: TextStyle(color: AppColors.outline, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2))),
                if (MediaQuery.of(context).size.width > 600)
                  Expanded(flex: 1, child: Text('GENRE', style: TextStyle(color: AppColors.outline, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2))),
                Text('DURATION', style: TextStyle(color: AppColors.outline, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                SizedBox(width: 48), // Padding for delete icon space
              ],
            ),
            SizedBox(height: 16),
            ...tracks.map((track) => _buildTrackItem(context, track)),
          ],
        );
      }
    );
  }

  Widget _buildTrackItem(BuildContext context, Track track) {
    return GestureDetector(
      onTap: () => AudioPlayerService.instance.playTrack(track),
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(4),
                      image: track.image.isNotEmpty ? DecorationImage(image: NetworkImage(track.image), fit: BoxFit.cover) : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(track.name, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                        Text(track.artistName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (MediaQuery.of(context).size.width > 600)
              Expanded(
                flex: 1,
                child: Text('Unknown Genre', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant, fontStyle: FontStyle.italic)),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('--:--', style: Theme.of(context).textTheme.labelSmall),
                SizedBox(width: 24),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: AppColors.outline),
                  onPressed: () => _deleteWithBiometric(track.id),
                  hoverColor: AppColors.error.withValues(alpha: 0.1),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSidebar(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Playlist Stats', style: Theme.of(context).textTheme.headlineMedium),
          SizedBox(height: 4),
          Text('Curated over 6 months', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
          SizedBox(height: 32),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Tracks', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
              Text('128', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
            ],
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Listening Time', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
              Text('8h 42m', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
            ],
          ),
          
          SizedBox(height: 32),
          Divider(color: AppColors.outlineVariant),
          SizedBox(height: 32),
          
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.shuffle, color: AppColors.onPrimaryFixed),
              label: Text('Shuffle Collection', style: TextStyle(color: AppColors.onPrimaryFixed, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          
          SizedBox(height: 48),
          Text('SECURITY NOTICE', style: TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_user, color: AppColors.tertiary),
                SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                      children: [
                        TextSpan(text: 'To protect your curated collection, deleting any track requires active '),
                        TextSpan(text: 'Fingerprint Authentication', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                        TextSpan(text: '. Ensure your device sensor is clean.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
