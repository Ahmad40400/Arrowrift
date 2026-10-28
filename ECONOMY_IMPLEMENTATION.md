🎯 GOAL
Metric	Before	After (Target)
3★ Net Profit (600 levels)	~20,11,452 coins	~8,00,000 coins
2★ Net Profit (600 levels)	~1,22,635 coins	~3,85,000 coins
1★ Net Profit (600 levels)	-17,40,864 coins	~-5,00,000 coins
Arcade Max/Day	3,000 coins	750 coins
Future Levels Support	❌ Nahi	✅ 10,000+ tak
📝 CHANGES SUMMARY
#	File	Change	Priority
1	game_provider.dart	Multiplier update (1.15 / 1.05 / 0.90)	🔴 HIGH
2	game_provider.dart	+100 flat bonus remove	🔴 HIGH
3	game_provider.dart	Pro mode bonus 1.25 → 1.35	🔴 HIGH
4	game_provider.dart	Fee formulas extend (L501+, L101+)	🟡 MED
5	game_provider.dart	Daily minigame limit 10 → 5	🔴 HIGH
6	memory_game_screen.dart	Rewards reduce (300 → 150 max)	🔴 HIGH
7	tap_target_screen.dart	Rewards reduce (200 → 120 max)	🔴 HIGH
8	color_reflex_screen.dart	Rewards reduce (150 → 100 max)	🔴 HIGH
🔧 CHANGE #1, #2, #3 — Level Reward Formula
File: lib/providers/game_provider.dart
Location: _checkWin() method ke andar
Dhoondo: // ---------- FULL REWARD ----------

❌ PURANA CODE (Remove karo):
dart
// ---------- FULL REWARD ----------
// = (agle level ki fee x multiplier) + 100.  3 stars 1.3x, 2 stars 1.0x, 1 star 0.7x
// => 2 stars par fee wapas (break-even), 3 stars par profit, 1 star par thora loss
int fullReward;
if (isDailyChallenge) {
  fullReward = 1000;
} else {
  final int nextFee = getLevelCost(currentLevel + 1);
  final double mult = levelStars == 3
      ? 1.3
      : (levelStars == 2 ? 1.0 : 0.7);
  fullReward = (nextFee * mult).round() + 100;
  if (isProMode) fullReward = (fullReward * 1.25).round();
}
✅ NAYA CODE (Replace karo):
dart
// ---------- FULL REWARD ----------
// Multiplier: 3★ = 1.15 (+15%), 2★ = 1.05 (+5%), 1★ = 0.90 (-10%)
// Pro mode: extra 1.35x (mushkil hai, reward zyada)
// +100 flat bonus hata diya — economy ko phoolne se rokne ke liye
int fullReward;
if (isDailyChallenge) {
  fullReward = 1000;
} else {
  final int nextFee = getLevelCost(currentLevel + 1);
  final double mult = levelStars == 3
      ? 1.15
      : (levelStars == 2 ? 1.05 : 0.90);
  fullReward = (nextFee * mult).round();
  if (isProMode) fullReward = (fullReward * 1.35).round();
}
🔧 CHANGE #4 — Fee Formulas Extend (Future Levels)
File: lib/providers/game_provider.dart
Location: getLevelCost() method
Dhoondo: int getLevelCost(int level, {bool? pro})

❌ PURANA CODE:
dart
int getLevelCost(int level, {bool? pro}) {
  final bool isPro = pro ?? isProMode;
  if (level <= 1) return 0;
  if (isPro) {
    if (level <= 40) return 100 + ((level - 2) * 40);
    if (level <= 80) return 1620 + ((level - 40) * 80);
    return 4820 + ((level - 80) * 120);
  }
  if (level <= 50) return 50 + ((level - 2) * 30);
  if (level <= 200) return 1490 + ((level - 50) * 60);
  return 10490 + ((level - 200) * 40);
}
✅ NAYA CODE:
dart
int getLevelCost(int level, {bool? pro}) {
  final bool isPro = pro ?? isProMode;
  if (level <= 1) return 0;
  if (isPro) {
    if (level <= 40) return 100 + ((level - 2) * 40);
    if (level <= 80) return 1620 + ((level - 40) * 80);
    if (level <= 100) return 4820 + ((level - 80) * 120);
    // NEW: Level 101+ (future Pro levels)
    return 7220 + ((level - 100) * 100);
  }
  if (level <= 50) return 50 + ((level - 2) * 30);
  if (level <= 200) return 1490 + ((level - 50) * 60);
  if (level <= 500) return 10490 + ((level - 200) * 40);
  // NEW: Level 501+ (future Classic levels)
  return 22490 + ((level - 500) * 30);
}
Note: Agar aap aage levels add karte hain (jaise maxClassicLevel = 1000), to yeh formula automatically kaam karega. Aapko sirf maxClassicLevel aur maxProLevel change karna hoga.

🔧 CHANGE #5 — Daily Minigame Limit
File: lib/providers/game_provider.dart
Location: Class ke top par constants
Dhoondo: static const int maxMinigamesPerDay

❌ PURANA:
dart
static const int maxMinigamesPerDay = 10;
✅ NAYA:
dart
static const int maxMinigamesPerDay = 5;
🔧 CHANGE #6 — Memory Match Rewards
File: lib/screens/memory_game_screen.dart
Location: _finishGame() method
Dhoondo: if (_seconds <= 15)

❌ PURANA:
dart
setState(() {
  _gameFinished = true;
  if (_seconds <= 15)
    _earnedCoins = 300;
  else if (_seconds <= 25)
    _earnedCoins = 200;
  else if (_seconds <= 40)
    _earnedCoins = 100;
  else
    _earnedCoins = 50;
});
✅ NAYA:
dart
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
🔧 CHANGE #7 — Tap Target Rewards
File: lib/screens/tap_target_screen.dart
Location: _finishGame() method
Dhoondo: if (_score >= 15)

❌ PURANA:
dart
setState(() {
  _gameStarted = false;
  _gameFinished = true;
  if (_score >= 15)
    _earnedCoins = 200;
  else if (_score >= 10)
    _earnedCoins = 150;
  else if (_score >= 5)
    _earnedCoins = 75;
  else
    _earnedCoins = 20;
});
✅ NAYA:
dart
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
🔧 CHANGE #8 — Color Reflex Rewards
File: lib/screens/color_reflex_screen.dart
Location: _finishGame() method
Dhoondo: if (_score >= 10)

❌ PURANA:
dart
setState(() {
  _gameStarted = false;
  _gameFinished = true;
  if (_score >= 10)
    _earnedCoins = 150;
  else if (_score >= 7)
    _earnedCoins = 100;
  else if (_score >= 4)
    _earnedCoins = 50;
  else
    _earnedCoins = 10;
});
✅ NAYA:
dart
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
📊 EXPECTED RESULTS (After All Changes)
Level Economy (600 Levels Complete):
Scenario	Classic Profit	Pro Profit	Total Profit
All 1★ (0.90)	~-4.7 lakh	~-0.3 lakh	~-5.0 lakh
All 2★ (1.05)	~+2.9 lakh	~+0.95 lakh	~+3.85 lakh
All 3★ (1.15)	~+6.8 lakh	~+1.5 lakh	~+8.3 lakh
Arcade Economy:
Game	Old Max	New Max
Memory Match	300	150
Tap Target	200	120
Color Reflex	150	100
Daily Limit	10 games	5 games
Max/Day	3,000	750
Power-Up Affordability (2★ Player, 600 levels):
Item	Cost	Player Afford Kar Sakta Hai?
Time Freeze	1,500	✅ ~250 baar (3.85 lakh se)
Extra Life	400	✅ ~960 baar
Auto-Solve (coins)	100,000	✅ ~3-4 baar
Auto-Solve (diamonds)	2,500 💎	✅ ~5 baar (12,500 💎 se)
Matlab: Player ke paas kaafi paisa hai power-ups ke liye, lekin infinite nahi hai. Economy balanced hai.

✅ TESTING CHECKLIST
Changes karne ke baad yeh test karo:

Test 1: Level 2 Complete Karo (3★)
Expected: ~92 coins mile (80 × 1.15 = 92)

Check: game.levelPointsEarned = 92

Test 2: Level 2 Complete Karo (2★)
Expected: ~84 coins mile (80 × 1.05 = 84)

Check: game.levelPointsEarned = 84

Test 3: Level 2 Complete Karo (1★)
Expected: ~72 coins mile (80 × 0.90 = 72)

Check: game.levelPointsEarned = 72

Test 4: Pro Level 2 Complete Karo (3★)
Expected: ~124 coins mile (100 × 1.15 × 1.35 = 124)

Check: game.levelPointsEarned = 124

Test 5: Memory Match (15s ke andar)
Expected: 150 coins

Check: _earnedCoins = 150

Test 6: Daily Minigame Limit
5 games khelne ke baad 6th game block ho

Check: game.canPlayMinigame = false

Test 7: Future Level (Level 501)
game.getLevelCost(501) = 22,520 (22,490 + 30)

Check: Function crash nahi kare

Test 8: Future Pro Level (Level 101)
game.getLevelCost(101, pro: true) = 7,320 (7,220 + 100)

Check: Function crash nahi kare

🚀 FUTURE-PROOFING NOTES
Aage Levels Add Karne Ke Liye:
maxClassicLevel badhao (e.g., 500 → 1000)

dart
static const int maxClassicLevel = 1000;
Fee formula automatically Level 501+ ke liye kaam karega.

maxProLevel badhao (e.g., 100 → 200)

dart
static const int maxProLevel = 200;
Fee formula automatically Level 101+ ke liye kaam karega.

Grid Size Formula Check Karo (_setupLevel mein):

dart
if (isProMode) {
  gridSize = min(20, 15 + (level ~/ 20));
} else {
  gridSize = getGridSizeForLevel(level);
}
Level 1000 tak grid size 14 (Classic) aur 20 (Pro) par cap ho jayega. Agar aage badhana hai to getGridSizeForLevel update karo.

Time Formula Check Karo:

Classic: getLevelTime(level) + 2 + (currentLevel ~/ 100) — Level 1000 par 27+2+10 = 39s milega

Pro: (arrows.length × 0.55).ceil() + 3 — grid size 20 par arrows ~88, time ~51s

📈 ECONOMY HEALTH MONITORING (After Launch)
Launch ke baad yeh metrics track karo:

Metric	Target	Action if Off
Average stars per level	2.0 - 2.5	Agar < 2.0, time badhao
Player coins after 50 levels	15,000 - 25,000	Agar < 10,000, reward badhao
Player coins after 200 levels	80,000 - 1,20,000	Agar > 2,00,000, reward kam karo
Arcade games/day (average)	2-3	Agar > 5, limit aur kam karo
Power-up purchase rate	15-25% levels	Agar < 10%, cost kam karo
🏁 FINAL SUMMARY
8 changes, 4 files, ~30 minutes ka kaam.

Before: Economy broken (20 lakh profit / 17 lakh loss)
After: Balanced (8 lakh profit / -5 lakh loss), future-proof, famous games ke standard par

Sabse important: game_provider.dart mein multiplier aur +100 removal — yeh 80% impact dega. Baaki changes polish hain.

Document Version: 1.0
Last Updated: Implementation ke liye ready
Compatibility: Arrowrift v1.0.0+

