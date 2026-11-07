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

class ColorReflexScreen extends StatefulWidget {
  const ColorReflexScreen({super.key});

  @override
  State<ColorReflexScreen> createState() => _ColorReflexScreenState();
}

class _ColorReflexScreenState extends State<ColorReflexScreen> {
  final Random _random = Random();

  final Map<String, Color> _colorMap = {
    'RED': Colors.red,
    'BLUE': Colors.blue,
    'GREEN': Colors.green,
    'YELLOW': Colors.amber.shade700,
    'PURPLE': Colors.purple,
    'ORANGE': Colors.orange,
    'PINK': Colors.pink,
    'TEAL': Colors.teal,
  };

  late String _correctColorName;
  late String _displayText;
  late List<String> _options;
  bool _hasQuestion = false;

  int _score = 0;
  int _timeLeft = 15;
  Timer? _timer;
  bool _gameStarted = false;
  bool _gameFinished = false;
  int _earnedCoins = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 15;
      _gameStarted = true;
      _gameFinished = false;
      _earnedCoins = 0;
      _hasQuestion = false;
    });
    _generateNewQuestion();

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

  // Stroop-style question:
  //  * the WORD on screen is written in one colour (the INK colour = answer),
  //  * the word itself NAMES a different colour (the "trap"),
  //  * BOTH the ink colour and the colour named by the word are always among
  //    the 4 options, so the player really has to choose (confusing on purpose),
  //  * the 2 remaining options are random other colours.
  void _generateNewQuestion() {
    final allNames = _colorMap.keys.toList();

    // Ink colour = correct answer. Avoid repeating the previous answer.
    String ink;
    do {
      ink = allNames[_random.nextInt(allNames.length)];
    } while (_hasQuestion && allNames.length > 1 && ink == _correctColorName);

    // The written word always names a DIFFERENT colour than its ink.
    final others = allNames.where((n) => n != ink).toList()..shuffle(_random);
    final String wordName = others.first;

    // Options: ink colour + the colour the word names + 2 fillers.
    final options = <String>[ink, wordName, ...others.skip(1).take(2)]
      ..shuffle(_random);

    _hasQuestion = true;
    setState(() {
      _correctColorName = ink;
      _displayText = wordName;
      _options = options;
    });
  }

  void _onOptionTap(String selectedName) {
    if (!_gameStarted || _gameFinished) return;
    if (_timeLeft <= 0) return;

    if (selectedName == _correctColorName) {
      setState(() => _score++);
      _generateNewQuestion();
    } else {
      setState(() => _timeLeft = max(0, _timeLeft - 1));
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wrong! -1 Second'),
          duration: Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _finishGame() {
    _timer?.cancel();
    setState(() {
      _gameStarted = false;
      _gameFinished = true;
      if (_score >= 10)
        _earnedCoins = 100;
      else if (_score >= 7)
        _earnedCoins = 70;
      else if (_score >= 4)
        _earnedCoins = 40;
      else
        _earnedCoins = 10;
    });

    final game = context.read<GameProvider>();
    game.addMinigameCoins(_earnedCoins);
    game.recordArcadeGameWon(
      15,
      _earnedCoins,
      won: _score >= 4,
      gameId: 'color_reflex',
    );
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
          'COLOR REFLEX',
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
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.psychology_rounded, size: 80, color: _ink),
                    SizedBox(height: 24),
                    Text(
                      'Tap the box matching the INK COLOR of the word, not what it says!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.dim(54),
                        fontWeight: FontWeight.w600,
                      ),
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
            ),

          if (_gameStarted)
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SCORE: $_score',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: _accent,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Tap the INK COLOR of this word',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.dim(54),
                    ),
                  ),
                  SizedBox(height: 18),
                  Text(
                    _displayText,
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: _colorMap[_correctColorName],
                      letterSpacing: 4,
                    ),
                  ),
                  SizedBox(height: 48),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: _options.length,
                    itemBuilder: (context, index) {
                      final colorName = _options[index];
                      return GestureDetector(
                        onTap: () => _onOptionTap(colorName),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _colorMap[colorName],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _colorMap[colorName]!.withOpacity(0.4),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
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
                        'You matched $_score colors.',
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
