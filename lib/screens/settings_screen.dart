import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../services/audio_manager.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';
import '../services/tutorial_manager.dart';

Color get _brand => AppTheme.brand;
Color get _accent => AppTheme.accent;
Color get _card => AppTheme.card;
Color get _ink => AppTheme.ink;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final audio = AudioManager();

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'SETTINGS',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _ink,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Customize your game experience.',
            style: TextStyle(color: AppTheme.dim(54), fontSize: 14),
          ),
          SizedBox(height: 32),

          // AUDIO SECTION
          Text(
            'AUDIO',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.dim(45),
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 10),

          _buildSettingItem(
            icon: Icons.music_note_rounded,
            title: 'Background Music',
            subtitle: 'Play soothing music in menus',
            trailing: Switch(
              value: audio.isMusicEnabled,
              onChanged: (val) async {
                await audio.toggleMusic(val);
                if (mounted) setState(() {});
              },
              activeColor: _brand,
            ),
          ),
          SizedBox(height: 12),

          _buildSettingItem(
            icon: Icons.volume_up_rounded,
            title: 'Sound Effects',
            subtitle: 'Arrow swoosh and error sounds',
            trailing: Switch(
              value: audio.isSfxEnabled,
              onChanged: (val) async {
                await audio.toggleSfx(val);
                if (mounted) setState(() {});
              },
              activeColor: _brand,
            ),
          ),

          SizedBox(height: 32),

          // HELP SECTION
          Text(
            'HELP',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.dim(45),
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 10),

          _buildSettingItem(
            icon: Icons.help_outline_rounded,
            title: 'How to Play',
            subtitle: 'Replay the guided tutorial',
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.grey(500),
            ),
            onTap: () => _startHowToPlay(context, game),
          ),

          SizedBox(height: 32),

          // DATA SECTION
          Text(
            'DATA & ACCOUNT',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.dim(45),
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 10),

          _buildSettingItem(
            icon: Icons.delete_forever_rounded,
            title: 'Reset Progress',
            subtitle: 'Delete all levels and coins',
            textColorOverride: Colors.red,
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.red,
            ),
            onTap: () => _showResetDialog(context, game),
          ),
          SizedBox(height: 12),

          _buildSettingItem(
            icon: Icons.info_outline_rounded,
            title: 'About Game',
            subtitle: 'Arrowrift v1.0.0',
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.grey(500),
            ),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Arrowrift',
                applicationVersion: 'v1.0.0',
                applicationIcon: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _brand,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.arrow_upward_rounded, color: _accent),
                ),
                children: [
                  Text(
                    'A relaxing puzzle game where every arrow leads somewhere. Find your way through hundreds of complex mazes!',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // TUTORIAL: reset tutorial flags and send the player to Level 1 (Game Screen).
  void _startHowToPlay(BuildContext context, GameProvider game) {
    game.restartTutorialFromSettings();
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: TutorialManager.gameRouteName),
        builder: (_) => const GameScreen(),
      ),
    );
  }

  void _showResetDialog(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Progress?',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: Text(
          'Are you sure you want to delete all your progress? You will lose all unlocked levels and coins. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.grey(500))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await game.resetProgress();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Progress Reset Successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color? textColorOverride,
    VoidCallback? onTap,
  }) {
    final Color textColor = textColorOverride ?? _brand;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor, size: 24),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: AppTheme.dim(54)),
          ),
          trailing: trailing,
        ),
      ),
    );
  }
}
