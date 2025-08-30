import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/gradient_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioService _audioService = AudioService();
  bool _soundEnabled = true;
  bool _musicEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _audioService.initialize();
    setState(() {
      _soundEnabled = _audioService.isSoundEnabled;
      _musicEnabled = _audioService.isMusicEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Scaffold(
          backgroundColor: theme.backgroundColor,
          appBar: AppBar(
            title: Text(
              'SETTINGS',
              style: TextStyle(
                color: theme.accentColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: theme.accentColor),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.backgroundColor,
                  theme.backgroundColor.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Theme Section
                    _buildSection(
                      'VISUAL THEME',
                      [
                        _buildThemeSelector(themeProvider, theme),
                      ],
                      theme,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Audio Section
                    _buildSection(
                      'AUDIO SETTINGS',
                      [
                        _buildAudioSwitch(
                          'Sound Effects',
                          _soundEnabled,
                          (value) async {
                            setState(() {
                              _soundEnabled = value;
                            });
                            await _audioService.setSoundEnabled(value);
                          },
                          theme,
                        ),
                        const SizedBox(height: 16),
                        _buildAudioSwitch(
                          'Background Music',
                          _musicEnabled,
                          (value) async {
                            setState(() {
                              _musicEnabled = value;
                            });
                            await _audioService.setMusicEnabled(value);
                          },
                          theme,
                        ),
                      ],
                      theme,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Controls Section
                    _buildSection(
                      'CONTROLS',
                      [
                        _buildControlInfo(theme),
                      ],
                      theme,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Back Button
                    Center(
                      child: GradientButton(
                        onPressed: () => Navigator.of(context).pop(),
                        text: 'BACK TO GAME',
                        primaryColor: theme.accentColor,
                        secondaryColor: theme.foodColor,
                        icon: Icons.arrow_back,
                        width: 200,
                      ),
                    ),
                  ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children, GameTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: theme.accentColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.backgroundColor.withValues(alpha: 0.3),
            border: Border.all(color: theme.accentColor.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector(ThemeProvider themeProvider, GameTheme theme) {
    return Column(
      children: [
        Text(
          'Current Theme: ${theme.name}',
          style: TextStyle(
            color: theme.accentColor.withValues(alpha: 0.8),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: GameTheme.values.map((themeOption) {
            final isSelected = themeOption == theme;
            return GestureDetector(
              onTap: () => themeProvider.setTheme(themeOption),
              child: Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: themeOption.backgroundColor,
                  border: Border.all(
                    color: isSelected 
                        ? themeOption.accentColor
                        : themeOption.accentColor.withValues(alpha: 0.3),
                    width: isSelected ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: themeOption.snakeColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: themeOption.foodColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      themeOption.name,
                      style: TextStyle(
                        color: themeOption.accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAudioSwitch(
    String title,
    bool value,
    Function(bool) onChanged,
    GameTheme theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: theme.accentColor.withValues(alpha: 0.8),
            fontSize: 16,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: theme.accentColor,
          activeTrackColor: theme.accentColor.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildControlInfo(GameTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildControlItem('Swipe Up/Down/Left/Right', 'Change direction', theme),
        _buildControlItem('Tap screen', 'Pause/Resume game', theme),
        _buildControlItem('Arrow Keys / WASD', 'Change direction (Desktop)', theme),
        _buildControlItem('Spacebar', 'Pause/Resume (Desktop)', theme),
      ],
    );
  }

  Widget _buildControlItem(String control, String action, GameTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.keyboard_arrow_right,
            color: theme.accentColor.withValues(alpha: 0.6),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  control,
                  style: TextStyle(
                    color: theme.accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  action,
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.7),
                    fontSize: 12,
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