import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _bgMusicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isMusicInitialized = false;
  bool _wasPlayingBeforeGame = false;
  bool _isAppInForeground = true;

  // Settings Variables
  bool isMusicEnabled = true;
  bool isSfxEnabled = true;

  // App start hote hi settings load karo
  Future<void> initSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isMusicEnabled = prefs.getBool('music_enabled') ?? true;
      isSfxEnabled = prefs.getBool('sfx_enabled') ?? true;
    } catch (e) {
      debugPrint('AudioManager initSettings Error: $e');
    }
  }

  Future<void> toggleMusic(bool value) async {
    isMusicEnabled = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('music_enabled', value);
    } catch (e) {
      debugPrint('AudioManager toggleMusic prefs Error: $e');
    }

    if (value) {
      // Only play if app is in foreground
      if (_isAppInForeground) {
        await playBackgroundMusic();
      }
    } else {
      try {
        await _bgMusicPlayer.pause();
      } catch (e) {
        debugPrint('AudioManager toggleMusic pause Error: $e');
      }
    }
  }

  Future<void> toggleSfx(bool value) async {
    isSfxEnabled = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sfx_enabled', value);
    } catch (e) {
      debugPrint('AudioManager toggleSfx prefs Error: $e');
    }
  }

  /// Called when app goes to background - pauses music
  Future<void> pauseForBackground() async {
    _isAppInForeground = false;
    try {
      if (_bgMusicPlayer.state == PlayerState.playing) {
        _wasPlayingBeforeGame = true;
        await _bgMusicPlayer.pause();
      } else {
        _wasPlayingBeforeGame = false;
      }
    } catch (e) {
      debugPrint('AudioManager pauseForBackground Error: $e');
    }
  }

  /// Called when app comes to foreground - resumes music if enabled
  Future<void> resumeFromBackground() async {
    _isAppInForeground = true;
    if (!isMusicEnabled) return;
    try {
      if (_wasPlayingBeforeGame &&
          _bgMusicPlayer.state != PlayerState.playing) {
        await _bgMusicPlayer.resume();
      } else if (!_isMusicInitialized) {
        await playBackgroundMusic();
      }
    } catch (e) {
      debugPrint('AudioManager resumeFromBackground Error: $e');
    }
  }

  /// Background Music start karne ke liye
  Future<void> playBackgroundMusic() async {
    if (!isMusicEnabled) return;
    if (!_isAppInForeground) return;
    try {
      if (!_isMusicInitialized) {
        await _bgMusicPlayer.setAudioContext(
          AudioContext(
            android: const AudioContextAndroid(
              contentType: AndroidContentType.music,
              usageType: AndroidUsageType.media,
              audioFocus: AndroidAudioFocus.none,
            ),
            iOS: AudioContextIOS(
              category: AVAudioSessionCategory.playback,
              options: const {AVAudioSessionOptions.mixWithOthers},
            ),
          ),
        );

        await _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
        await _bgMusicPlayer.setVolume(0.6);

        await _bgMusicPlayer.play(
          AssetSource('sounds/bg_music.mp3'),
          mode: PlayerMode.mediaPlayer,
        );
        _isMusicInitialized = true;
      } else {
        await _bgMusicPlayer.setVolume(0.6);
        if (_bgMusicPlayer.state != PlayerState.playing) {
          await _bgMusicPlayer.resume();
        }
      }
    } catch (e) {
      debugPrint('AudioManager BG Music Error: $e');
    }
  }

  Future<void> lowerMusicVolume() async {
    if (!isMusicEnabled) return;
    try {
      _wasPlayingBeforeGame = _bgMusicPlayer.state == PlayerState.playing;
      await _bgMusicPlayer.setVolume(0.15);
    } catch (e) {
      debugPrint('AudioManager Lower Volume Error: $e');
    }
  }

  Future<void> restoreMusicVolume() async {
    if (!isMusicEnabled) return;
    try {
      await _bgMusicPlayer.setVolume(0.6);
      if (_bgMusicPlayer.state != PlayerState.playing && _isAppInForeground) {
        await _bgMusicPlayer.resume();
      }
    } catch (e) {
      debugPrint('AudioManager Restore Volume Error: $e');
    }
  }

  Future<void> playArrowEscapeSound() async {
    if (!isSfxEnabled) return;
    if (!_isAppInForeground) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setVolume(0.7);
      await _sfxPlayer.play(AssetSource('sounds/arrow_escape.mp3'));
    } catch (e) {
      debugPrint('AudioManager Arrow SFX Error: $e');
    }
  }

  Future<void> playWrongTapSound() async {
    if (!isSfxEnabled) return;
    if (!_isAppInForeground) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setVolume(0.8);
      await _sfxPlayer.play(AssetSource('sounds/wrong_tap.mp3'));
    } catch (e) {
      debugPrint('AudioManager Wrong Tap SFX Error: $e');
    }
  }
}
