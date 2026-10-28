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

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final List<IconData> _allIcons = [
    Icons.star_rounded,
    Icons.favorite_rounded,
    Icons.bolt_rounded,
    Icons.cloud_rounded,
    Icons.local_fire_department_rounded,
    Icons.emoji_emotions_rounded,
    Icons.pets_rounded,
    Icons.rocket_launch_rounded,
    Icons.water_drop_rounded,
    Icons.music_note_rounded,
    Icons.thumb_up_rounded,
    Icons.lightbulb_rounded,
    Icons.anchor_rounded,
    Icons.cake_rounded,
  ];

  late List<Map<String, dynamic>> _cards;
  int? _firstFlippedIndex;
  int? _secondFlippedIndex;
  bool _isChecking = false;
  int _matchesFound = 0;

  int _seconds = 0;
  Timer? _timer;
  bool _gameFinished = false;
  int _earnedCoins = 0;

  @override
  void initState() {
    super.initState();
    _setupBoard();
  }

  void _setupBoard() {
    _cards = [];
    final List<IconData> randomIcons = List.from(_allIcons)..shuffle(Random());
    final selectedIcons = randomIcons.take(6).toList();

    for (int i = 0; i < selectedIcons.length; i++) {
      _cards.add({
        'icon': selectedIcons[i],
        'isFlipped': false,
        'isMatched': false,
        'id': i,
      });
      _cards.add({
        'icon': selectedIcons[i],
        'isFlipped': false,
        'isMatched': false,
        'id': i,
      });
    }
    _cards.shuffle(Random());

    _firstFlippedIndex = null;
    _secondFlippedIndex = null;
    _isChecking = false;
    _matchesFound = 0;
    _seconds = 0;
    _gameFinished = false;
    _earnedCoins = 0;
    _timer?.cancel();
    _timer = null;
  }

  void _startGame() {
    setState(() {
      _setupBoard();
    });

    context.read<GameProvider>().recordMinigamePlayed();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_gameFinished) {
        setState(() => _seconds++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onCardTap(int index) {
    if (_timer == null ||
        _isChecking ||
        _cards[index]['isFlipped'] ||
        _cards[index]['isMatched'] ||
        _gameFinished)
      return;

    setState(() {
      _cards[index]['isFlipped'] = true;
    });

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
    } else if (_secondFlippedIndex == null && _firstFlippedIndex != index) {
      _secondFlippedIndex = index;
      _checkMatch();
    }
  }

  void _checkMatch() {
    _isChecking = true;
    if (_cards[_firstFlippedIndex!]['id'] ==
        _cards[_secondFlippedIndex!]['id']) {
      setState(() {
        _cards[_firstFlippedIndex!]['isMatched'] = true;
        _cards[_secondFlippedIndex!]['isMatched'] = true;
        _firstFlippedIndex = null;
        _secondFlippedIndex = null;
        _isChecking = false;
        _matchesFound++;
      });

      if (_matchesFound == 6) {
        _finishGame();
      }
    } else {
      Future.delayed(Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _cards[_firstFlippedIndex!]['isFlipped'] = false;
          _cards[_secondFlippedIndex!]['isFlipped'] = false;
          _firstFlippedIndex = null;
          _secondFlippedIndex = null;
          _isChecking = false;
        });
      });
    }
  }

  void _finishGame() {
    _timer?.cancel();
    setState(() {
      _gameFinished = true;
      if (_seconds <= 15)
        _earnedCoins = 150;
      else if (_seconds <= 25)
        _earnedCoins = 100;
      else if (_seconds <= 40)
        _earnedCoins = 50;
      else
        _earnedCoins = 25;
    });

    final game = context.read<GameProvider>();
    game.addMinigameCoins(_earnedCoins);
    game.recordArcadeGameWon(_seconds, _earnedCoins);
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
          'MEMORY MATCH',
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
                  '$_seconds s',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _timer != null && !_gameFinished ? _accent : _brand,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Matches: $_matchesFound / 6',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _ink,
                    ),
                  ),
                  SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _cards.length,
                      itemBuilder: (context, index) {
                        final card = _cards[index];
                        final isFlipped =
                            card['isFlipped'] || card['isMatched'];
                        return GestureDetector(
                          onTap: () => _onCardTap(index),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: isFlipped ? _card : _brand,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: isFlipped
                                  ? Icon(
                                      card['icon'] as IconData,
                                      size: 36,
                                      color: card['isMatched']
                                          ? Colors.green
                                          : _accent,
                                    )
                                  : Icon(
                                      Icons.help_outline_rounded,
                                      color: Colors.white24,
                                      size: 36,
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_timer == null && !_gameFinished)
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _brand,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _startGame,
                          child: Text(
                            'START GAME',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
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
                        'Well Played!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _ink,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'You matched all pairs in $_seconds seconds.',
                        style: TextStyle(color: AppTheme.dim(54)),
                        textAlign: TextAlign.center,
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
