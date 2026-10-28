import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../theme/app_theme.dart';

Color get _brand => AppTheme.brand;
Color get _accent => AppTheme.accent;
Color get _bg => AppTheme.bg;
Color get _card => AppTheme.card;
Color get _ink => AppTheme.ink;

class TapTargetScreen extends StatefulWidget {
  const TapTargetScreen({super.key});

  @override
  State<TapTargetScreen> createState() => _TapTargetScreenState();
}

class _TapTargetScreenState extends State<TapTargetScreen> {
  final Random _random = Random();
  Offset _targetPosition = Offset.zero;
  int _score = 0;
  int _timeLeft = 10;
  Timer? _timer;
  bool _gameStarted = false;
  bool _gameFinished = false;
  int _earnedCoins = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _moveTarget());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 10;
      _gameStarted = true;
      _gameFinished = false;
      _earnedCoins = 0;
    });
    _moveTarget();

    context.read<GameProvider>().recordMinigamePlayed();

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _finishGame();
      }
    });
  }

  void _moveTarget() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    final maxX = size.width - 80;
    final maxY = size.height - 200;

    setState(() {
      _targetPosition = Offset(
        _random.nextDouble() * maxX,
        100 + _random.nextDouble() * maxY,
      );
    });
  }

  void _onTap() {
    if (!_gameStarted || _gameFinished) return;
    setState(() => _score++);
    _moveTarget();
  }

  void _finishGame() {
    _timer?.cancel();
    setState(() {
      _gameStarted = false;
      _gameFinished = true;
      if (_score >= 15)
        _earnedCoins = 120;
      else if (_score >= 10)
        _earnedCoins = 90;
      else if (_score >= 5)
        _earnedCoins = 50;
      else
        _earnedCoins = 15;
    });

    final game = context.read<GameProvider>();
    game.addMinigameCoins(_earnedCoins);
    game.recordArcadeGameWon(10, _earnedCoins, won: _score >= 5);
  }

  @override
  Widget build(BuildContext context) {
    context.select<GameProvider, String>(
      (g) => g.currentTheme.id,
    ); // rebuild on theme change
    return ThemedScaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'TAP TARGET',
          style: TextStyle(
            color: _ink,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _ink),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_timeLeft s',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _accent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_gameStarted && !_gameFinished)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app_rounded, size: 80, color: _ink),
                  SizedBox(height: 24),
                  Text(
                    'Tap the target as fast as you can!',
                    style: TextStyle(fontSize: 16, color: AppTheme.dim(54)),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brand,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _startGame,
                    child: Text(
                      'START',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (_gameStarted)
            Positioned(
              left: _targetPosition.dx,
              top: _targetPosition.dy,
              child: GestureDetector(
                onTap: _onTap,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: _accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.gps_fixed_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),

          if (_gameStarted)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Score: $_score',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _ink,
                    ),
                  ),
                ),
              ),
            ),

          if (_gameFinished)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(32),
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        size: 64,
                        color: Colors.amber,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Time Up!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _ink,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'You hit $_score targets.',
                        style: TextStyle(color: AppTheme.dim(54)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '+$_earnedCoins Coins',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.amber,
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brand,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Back to Arcade',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
