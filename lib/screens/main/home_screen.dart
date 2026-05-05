import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ambient_background.dart';
import 'package:provider/provider.dart';
import '../../core/providers/music_provider.dart';
import '../../core/models/track.dart';
import '../../core/services/audio_player_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/firebase_auth_service.dart';
import '../../navigation/main_scaffold.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedGenre = '';
  final List<String> _genres = ["pop", "rock", "electronic", "jazz", "hiphop", "classical"];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<MusicProvider>().loadPopularTracks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context); // Force rebuild on theme change
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: AmbientBackground(
        child: Stack(
          children: [
            CustomScrollView(
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
                    if (isWide) ...[
                      TextButton(onPressed: () {}, child: Text('Home', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
                      TextButton(onPressed: () {}, child: Text('Explore', style: TextStyle(color: AppColors.outline))),
                      TextButton(onPressed: () {}, child: Text('Library', style: TextStyle(color: AppColors.outline))),
                    ],
                    SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => MainScaffold.of(context)?.changeTab(3),
                      child: CircleAvatar(
                        backgroundColor: AppColors.surfaceContainerHighest,
                        backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCuYNhxW94PVo9l_5D4XY_bP_xSRP5vyN8_TgJnDarc7UnyLdbpSKQJ16ZwPqk46tduJLBO0Fg6tB5aVmK5KIgW96eX58yDvd-KJTrVwEgqF7WGTkHMFlDmTCO6MWvsIWx1b4VuH1WFbl-BHqA8pEU6UM581hx8VKa1SEhpfUpUmR5dcUgzmNSLv5NLO87SQm50-VufjzybxuvEBcJp8Vnw5oR3escltrJofLmeVH_fjEV9eeFLUuef8UnDJNbapk9UazqjPG38yjU'),
                      ),
                    ),
                    SizedBox(width: 24),
                  ],
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      
                      // Genre Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        child: Row(
                          children: _genres.map((genre) {
                            return Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _selectedGenre = genre);
                                  context.read<MusicProvider>().loadGenreTracks(genre);
                                },
                                child: _buildGenreChip(genre.toUpperCase(), _selectedGenre == genre),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      
                      SizedBox(height: 48),

                      // Hero Playlist Section
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: _buildHeroPlaylist(context)),
                            SizedBox(width: 32),
                            Expanded(flex: 5, child: _buildMixesGrid(context)),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildHeroPlaylist(context),
                            SizedBox(height: 24),
                            SizedBox(height: 300, child: _buildMixesGrid(context)), // Fixed height for grid in mobile view
                          ],
                        ),

                      SizedBox(height: 48),

                      // Track List
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Recent Tracks', style: Theme.of(context).textTheme.headlineMedium),
                              SizedBox(height: 4),
                              Text('Your sonic journey continues here.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              final provider = context.read<MusicProvider>();
                              if (provider.currentTracks.isEmpty) return;
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: AppColors.surface,
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                                builder: (context) => DraggableScrollableSheet(
                                  expand: false,
                                  initialChildSize: 0.7,
                                  maxChildSize: 0.9,
                                  minChildSize: 0.5,
                                  builder: (_, scrollController) => Column(
                                    children: [
                                      SizedBox(height: 16),
                                      Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2))),
                                      SizedBox(height: 16),
                                      Text('All Tracks', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                                      SizedBox(height: 16),
                                      Expanded(
                                        child: ListView.builder(
                                          controller: scrollController,
                                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                          itemCount: provider.currentTracks.length,
                                          itemBuilder: (context, index) => _buildRecentTrack(context, provider.currentTracks[index]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Consumer<MusicProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return Center(child: CircularProgressIndicator());
                          } else if (provider.currentTracks.isEmpty) {
                            return Center(child: Text("No tracks found."));
                          } else {
                            // Show tracks from index 1 to 5 as recent tracks (or any criteria)
                            final tracks = provider.currentTracks.skip(1).take(5).toList();
                            return Column(
                              children: tracks.map((track) => _buildRecentTrack(context, track)).toList(),
                            );
                          }
                        },
                      ),

                      SizedBox(height: 200), // Spacing for player and navbar
                    ]),
                  ),
                ),
              ],
            ),
            
            // Persistent Mini-Player Overlay
            Positioned(
              left: 24,
              right: 24,
              bottom: 120, // above the navbar
              child: StreamBuilder<PlayerState>(
                stream: AudioPlayerService.instance.playerStateStream,
                builder: (context, snapshot) {
                  final track = AudioPlayerService.instance.currentTrack;
                  if (track == null) return SizedBox.shrink();
                  
                  final playing = snapshot.data?.playing ?? false;
                  
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PlayerScreen()),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Linear progress indicator
                            StreamBuilder<Duration>(
                              stream: AudioPlayerService.instance.positionStream,
                              builder: (context, posSnap) {
                                return StreamBuilder<Duration?>(
                                  stream: AudioPlayerService.instance.durationStream,
                                  builder: (context, durSnap) {
                                    final pos = posSnap.data ?? Duration.zero;
                                    final dur = durSnap.data ?? Duration.zero;
                                    final fraction = dur.inMilliseconds > 0 ? pos.inMilliseconds / dur.inMilliseconds : 0.0;
                                    
                                    return Container(
                                      height: 4,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: fraction.clamp(0.0, 1.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                );
                              }
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          image: DecorationImage(
                                            image: NetworkImage(track.image.isNotEmpty ? track.image : 'https://fakeimg.pl/400x400/282828/eae0d0/?retina=1'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(track.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.onSurface), overflow: TextOverflow.ellipsis),
                                            SizedBox(height: 4),
                                            Text(track.artistName, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12), overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                Row(
                                  children: [
                                    if (isWide) IconButton(
                                      icon: Icon(Icons.shuffle, color: AudioPlayerService.instance.isShuffle ? AppColors.primary : AppColors.outline),
                                      onPressed: () {
                                        AudioPlayerService.instance.toggleShuffle();
                                        setState(() {});
                                      }
                                    ),
                                    SizedBox(width: 16),
                                    IconButton(
                                      icon: Icon(Icons.skip_previous, color: AppColors.onSurface),
                                      onPressed: () => AudioPlayerService.instance.playPrevious()
                                    ),
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                        child: IconButton(
                                          icon: Icon(playing ? Icons.pause : Icons.play_arrow, color: AppColors.onPrimaryFixed, size: 28),
                                          onPressed: () => AudioPlayerService.instance.togglePlayPause(),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.skip_next, color: AppColors.onSurface),
                                      onPressed: () => AudioPlayerService.instance.playNext()
                                    ),
                                    if (isWide) IconButton(icon: Icon(Icons.repeat, color: AppColors.outline), onPressed: () => AudioPlayerService.instance.toggleRepeat()),
                                  ],
                                ),
                                
                                if (isWide)
                                  Row(
                                    children: [
                                      SizedBox(width: 16),
                                      Icon(Icons.volume_up, color: AppColors.outline, size: 16),
                                      SizedBox(width: 8),
                                      Container(
                                        width: 100,
                                        height: 4,
                                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2)),
                                        alignment: Alignment.centerLeft,
                                        child: FractionallySizedBox(
                                          widthFactor: 0.75,
                                          child: Container(decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Icon(Icons.playlist_play, color: AppColors.outline),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    ),
                  ); // closes GestureDetector
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreChip(String label, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? null : AppColors.surfaceContainerHigh,
        gradient: isSelected ? LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.onPrimaryFixed : AppColors.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildHeroPlaylist(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    Track? featured;
    if (provider.currentTracks.isNotEmpty) {
      featured = provider.currentTracks.first;
    }

    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surfaceContainerHigh,
        image: featured != null && featured.image.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(featured.image),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
          ),
        ),
        padding: EdgeInsets.all(32),
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FEATURED PLAYLIST', style: TextStyle(color: AppColors.tertiary, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2)),
            SizedBox(height: 8),
            Text(featured?.name ?? 'Loading...', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white, height: 1.1)),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (featured != null) {
                  final playlist = Provider.of<MusicProvider>(context, listen: false).currentTracks;
                  AudioPlayerService.instance.playTrack(featured, playlist: playlist);
                }
              },
              icon: Icon(Icons.play_arrow, color: Colors.black),
              label: Text('Play Now', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMixesGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        _buildMixCard(context, 'Daily Mix', 'Curated for you', '01', _selectedGenre == 'Pop', () {
          setState(() => _selectedGenre = 'Pop');
          context.read<MusicProvider>().loadGenreTracks('pop');
        }),
        _buildMixCard(context, 'Mood Boost', 'Vibrant beats', '02', _selectedGenre == 'Electronic', () {
          setState(() => _selectedGenre = 'Electronic');
          context.read<MusicProvider>().loadGenreTracks('electronic');
        }),
        _buildMixCard(context, 'Chill Out', 'Deep focus', '03', _selectedGenre == 'Classical', () {
          setState(() => _selectedGenre = 'Classical');
          context.read<MusicProvider>().loadGenreTracks('classical');
        }),
        _buildMixCard(context, 'Jazz Flow', 'Classic soul', '04', _selectedGenre == 'Jazz', () {
          setState(() => _selectedGenre = 'Jazz');
          context.read<MusicProvider>().loadGenreTracks('jazz');
        }),
      ],
    );
  }

  Widget _buildMixCard(BuildContext context, String title, String subtitle, String number, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.15) : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : Colors.transparent,
            width: 2,
          ),
        ),
        padding: EdgeInsets.all(24),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -10,
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.onSurface.withValues(alpha: 0.05),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: isSelected ? AppColors.primary : AppColors.onSurface)),
                SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: isSelected ? AppColors.primary.withValues(alpha: 0.8) : AppColors.outline, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTrack(BuildContext context, Track track) {
    return GestureDetector(
      onTap: () {
        final playlist = Provider.of<MusicProvider>(context, listen: false).currentTracks;
        AudioPlayerService.instance.playTrack(track, playlist: playlist);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent, // add hover effect if needed
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppColors.surfaceContainerHigh,
                image: track.image.isNotEmpty ? DecorationImage(image: NetworkImage(track.image), fit: BoxFit.cover) : null,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(track.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Text(track.artistName, style: TextStyle(color: AppColors.outline, fontSize: 12), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (MediaQuery.of(context).size.width > 600)
              Expanded(
                flex: 2,
                child: Text(track.albumName, style: TextStyle(color: AppColors.outline, fontSize: 12), overflow: TextOverflow.ellipsis),
              ),
            Row(
              children: [
                StreamBuilder<List<Track>>(
                  initialData: <Track>[],
                  stream: FirebaseAuthService.instance.currentUser != null
                      ? FirestoreService.instance.favoritesStream(FirebaseAuthService.instance.currentUser!.uid)
                      : Stream.value(<Track>[]),
                  builder: (context, snapshot) {
                    final isFav = snapshot.data?.any((t) => t.id == track.id) ?? false;
                    return IconButton(
                      icon: Icon(Icons.favorite, color: isFav ? AppColors.primary : AppColors.outline),
                      onPressed: () {
                        final uid = FirebaseAuthService.instance.currentUser?.uid;
                        if (uid != null) {
                          if (isFav) {
                            // Removing favorite from home also removes it
                            FirestoreService.instance.removeFavorite(uid, track.id);
                          } else {
                            FirestoreService.instance.addFavorite(uid, track);
                          }
                        }
                      },
                    );
                  },
                ),
                SizedBox(width: 8),
                Text('--:--', style: TextStyle(color: AppColors.outline, fontSize: 12)),
                SizedBox(width: 24),
                Icon(Icons.more_vert, color: AppColors.outline),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
