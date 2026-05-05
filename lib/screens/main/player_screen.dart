import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart'; // <--- Ajout de l'import ici
import '../../theme/app_theme.dart';
import '../../widgets/ambient_background.dart';
import '../../widgets/glass_card.dart';
import '../../core/services/audio_player_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/firebase_auth_service.dart';
import '../../core/models/track.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final _uid = FirebaseAuthService.instance.currentUser?.uid;

  String _formatDuration(Duration? duration) {
    if (duration == null) return "0:00";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context); // Force complete rebuild on theme change
    
    return Scaffold(
      body: AmbientBackground(
        child: StreamBuilder<Duration>(
          stream: AudioPlayerService.instance.positionStream,
          builder: (context, positionSnapshot) {
            final track = AudioPlayerService.instance.currentTrack;
            
            if (track == null) {
              return Center(
                child: Text(
                  'No track is currently playing.',
                  style: TextStyle(color: AppColors.outlineVariant),
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  title: Text('NOW PLAYING', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  centerTitle: true,
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Album Art
                        Hero(
                          tag: 'album_art_${track.id}',
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.width * 0.8,
                            constraints: BoxConstraints(maxHeight: 400, maxWidth: 400),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryContainer.withValues(alpha: 0.3),
                                  blurRadius: 40,
                                  offset: Offset(0, 20),
                                ),
                              ],
                              image: DecorationImage(
                                image: NetworkImage(track.image.isNotEmpty ? track.image : 'https://fakeimg.pl/400x400/282828/eae0d0/'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 48),

                        // Track Info & Favorite Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track.name,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    track.artistName,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.onSurfaceVariant),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            if (_uid != null)
                              StreamBuilder<List<Track>>(
                                initialData: <Track>[],
                                stream: FirestoreService.instance.favoritesStream(_uid),
                                builder: (context, favSnapshot) {
                                  final isFavorite = favSnapshot.data?.any((t) => t.id == track.id) ?? false;
                                  return IconButton(
                                    icon: Icon(
                                      isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: isFavorite ? AppColors.primary : AppColors.outline,
                                      size: 32,
                                    ),
                                    onPressed: () {
                                      if (isFavorite) {
                                        FirestoreService.instance.removeFavorite(_uid, track.id);
                                      } else {
                                        FirestoreService.instance.addFavorite(_uid, track);
                                      }
                                    },
                                  );
                                }
                              ),
                          ],
                        ),

                        SizedBox(height: 32),

                        // Progress Bar
                        StreamBuilder<Duration?>(
                          stream: AudioPlayerService.instance.durationStream,
                          builder: (context, durationSnapshot) {
                            final duration = durationSnapshot.data ?? Duration.zero;
                            final position = positionSnapshot.data ?? Duration.zero;
                            
                            double progress = 0.0;
                            if (duration.inMilliseconds > 0) {
                              progress = position.inMilliseconds / duration.inMilliseconds;
                            }

                            return Column(
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: AppColors.primary,
                                    inactiveTrackColor: AppColors.surfaceContainerHighest,
                                    thumbColor: AppColors.onPrimaryFixed,
                                    trackHeight: 4.0,
                                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
                                    overlayShape: RoundSliderOverlayShape(overlayRadius: 14.0),
                                  ),
                                  child: Slider(
                                    value: progress.clamp(0.0, 1.0),
                                    onChanged: (value) {
                                      final newPosition = Duration(milliseconds: (duration.inMilliseconds * value).round());
                                      AudioPlayerService.instance.seek(newPosition);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_formatDuration(position), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
                                      Text(_formatDuration(duration), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                        ),

                        SizedBox(height: 32),

                        // Playback Controls
                        StreamBuilder<PlayerState>(
                          stream: AudioPlayerService.instance.playerStateStream,
                          builder: (context, stateSnapshot) {
                            final playing = stateSnapshot.data?.playing ?? false;
                            final isRepeat = AudioPlayerService.instance.isRepeat;
                            final isShuffle = AudioPlayerService.instance.isShuffle;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.shuffle, color: isShuffle ? AppColors.primary : AppColors.outline),
                                  onPressed: () {
                                    AudioPlayerService.instance.toggleShuffle();
                                    setState(() {}); // refresh shuffle icon
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.skip_previous, color: AppColors.onSurface, size: 40),
                                  onPressed: () {
                                    AudioPlayerService.instance.playPrevious();
                                  },
                                ),
                                GestureDetector(
                                  onTap: () => AudioPlayerService.instance.togglePlayPause(),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [AppColors.primary, AppColors.primaryContainer],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryContainer.withValues(alpha: 0.5),
                                          blurRadius: 20,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      playing ? Icons.pause : Icons.play_arrow,
                                      color: AppColors.onPrimaryFixed,
                                      size: 40,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.skip_next, color: AppColors.onSurface, size: 40),
                                  onPressed: () {
                                    AudioPlayerService.instance.playNext();
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.repeat, color: isRepeat ? AppColors.primary : AppColors.outline),
                                  onPressed: () {
                                    AudioPlayerService.instance.toggleRepeat();
                                    setState(() {}); // refresh repeat icon
                                  },
                                ),
                              ],
                            );
                          }
                        ),

                        SizedBox(height: 32),
                        
                        // Playlist / Queue Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('UP NEXT', style: TextStyle(color: AppColors.outline, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                            IconButton(
                              icon: Icon(Icons.queue_music, color: AppColors.primary),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: AppColors.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                  ),
                                  builder: (context) {
                                    final playlist = AudioPlayerService.instance.currentPlaylist;
                                    return Container(
                                      padding: EdgeInsets.symmetric(vertical: 24),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 24),
                                            child: Text('Playing List', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                          ),
                                          SizedBox(height: 16),
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: playlist.length,
                                              itemBuilder: (context, index) {
                                                final t = playlist[index];
                                                final isCurrent = t.id == track.id;
                                                return ListTile(
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                                  leading: Container(
                                                    width: 48,
                                                    height: 48,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(8),
                                                      image: DecorationImage(
                                                        image: NetworkImage(t.image.isNotEmpty ? t.image : 'https://fakeimg.pl/400x400/282828/eae0d0/'),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  title: Text(t.name, style: TextStyle(fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal, color: isCurrent ? AppColors.primary : AppColors.onSurface)),
                                                  subtitle: Text(t.artistName, style: TextStyle(color: AppColors.outline, fontSize: 12)),
                                                  trailing: isCurrent ? Icon(Icons.volume_up, color: AppColors.primary) : null,
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    AudioPlayerService.instance.playTrack(t, playlist: playlist);
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: 100), // Spacer for nav bar
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}
