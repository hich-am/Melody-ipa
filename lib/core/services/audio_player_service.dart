import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_service/audio_service.dart';
import '../models/track.dart';
import 'stats_service.dart';

class AudioPlayerService {
  AudioPlayerService._();
  static final AudioPlayerService instance = AudioPlayerService._();

  final AudioPlayer _player = AudioPlayer();

  Track? _currentTrack;
  DateTime? _playStartedAt;
  bool _isRepeat = false;
  bool _isShuffle = false;
  
  List<Track> _playlist = [];
  int _currentIndex = -1;


  Track? get currentTrack => _currentTrack;
  List<Track> get currentPlaylist => _playlist;
  bool get isRepeat => _isRepeat;
  bool get isShuffle => _isShuffle;
  bool get isPlaying => _player.playing;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  // ─────────────────────────────────────────────────────
  // Initialise (call once in main.dart)
  // ─────────────────────────────────────────────────────

  Future<void> init() async {
    // When a track finishes naturally, handle repeat or stop
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        if (_isRepeat) {
          _player.seek(Duration.zero);
          _player.play();
        } else {
          _recordListeningTime();
          playNext(); // Auto-play next track when finished
        }
      }
    });
  }

  // ─────────────────────────────────────────────────────
  // Playback control
  // ─────────────────────────────────────────────────────

  Future<void> playTrack(Track track, {List<Track>? playlist}) async {
    // Record time for previous track before switching
    _recordListeningTime();

    if (playlist != null) {
      _playlist = playlist;
    }
    _currentIndex = _playlist.indexWhere((t) => t.id == track.id);
    _currentTrack = track;
    _playStartedAt = DateTime.now();

    final audioSource = AudioSource.uri(
      Uri.parse(track.audioUrl),
      tag: MediaItem(
        id: track.id,
        album: track.albumName,
        title: track.name,
        artist: track.artistName,
        artUri: track.image.isNotEmpty ? Uri.parse(track.image) : null,
      ),
    );

    await _player.setAudioSource(audioSource);
    await _player.play();
  }
  
  Future<void> playNext() async {
    if (_playlist.isEmpty) return;
    
    int nextIndex;
    if (_isShuffle) {
      final listWithoutCurrent = List<int>.generate(_playlist.length, (i) => i)..remove(_currentIndex);
      listWithoutCurrent.shuffle();
      nextIndex = listWithoutCurrent.isNotEmpty ? listWithoutCurrent.first : _currentIndex;
    } else {
      nextIndex = (_currentIndex + 1) % _playlist.length;
    }
    
    await playTrack(_playlist[nextIndex]);
  }

  Future<void> playPrevious() async {
    if (_playlist.isEmpty) {
      await _player.seek(Duration.zero);
      return;
    }
    
    // If we've played more than 3 seconds, previous goes to start of current track
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    
    int prevIndex = (_currentIndex - 1) % _playlist.length;
    if (prevIndex < 0) prevIndex = _playlist.length - 1;
    await playTrack(_playlist[prevIndex]);
  }

  Future<void> pause() async {
    _recordListeningTime();
    await _player.pause();
  }

  Future<void> resume() async {
    _playStartedAt = DateTime.now();
    await _player.play();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  void toggleRepeat() {
    _isRepeat = !_isRepeat;
    _player.setLoopMode(_isRepeat ? LoopMode.one : LoopMode.off);
  }
  
  void toggleShuffle() {
    _isShuffle = !_isShuffle;
  }

  Future<void> dispose() async {
    _recordListeningTime();
    await _player.dispose();
  }

  // ─────────────────────────────────────────────────────
  // Stats recording
  // ─────────────────────────────────────────────────────

  void _recordListeningTime() {
    if (_playStartedAt == null || _currentTrack == null) return;
    final seconds = DateTime.now().difference(_playStartedAt!).inSeconds;
    if (seconds > 0) {
      StatsService.instance.recordPlay(_currentTrack!.id, seconds);
    }
    _playStartedAt = null;
  }
}
