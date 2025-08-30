import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/providers/game_provider.dart';
import 'package:snake_classic/screens/theme_selector_screen.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/gradient_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioService _audioService = AudioService();
  final StorageService _storageService = StorageService();
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  BoardSize _selectedBoardSize = GameConstants.availableBoardSizes[1]; // Default to Classic
  Duration _selectedCrashFeedbackDuration = GameConstants.defaultCrashFeedbackDuration;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _audioService.initialize();
    final boardSize = await _storageService.getBoardSize();
    final crashFeedbackDuration = await _storageService.getCrashFeedbackDuration();
    setState(() {
      _soundEnabled = _audioService.isSoundEnabled;
      _musicEnabled = _audioService.isMusicEnabled;
      _selectedBoardSize = boardSize;
      _selectedCrashFeedbackDuration = crashFeedbackDuration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, GameProvider>(
      builder: (context, themeProvider, gameProvider, child) {
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
                    
                    // Board Size Section
                    _buildSection(
                      'BOARD SIZE',
                      [
                        _buildBoardSizeSelector(gameProvider, theme),
                      ],
                      theme,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Crash Feedback Duration Section
                    _buildSection(
                      'CRASH FEEDBACK',
                      [
                        _buildCrashFeedbackDurationSelector(gameProvider, theme),
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
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Theme',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    theme.name,
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Theme preview
            Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                border: Border.all(
                  color: theme.accentColor.withValues(alpha: 0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: theme.snakeColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.foodColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        GradientButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ThemeSelectorScreen(),
              ),
            );
          },
          text: 'BROWSE THEMES',
          primaryColor: theme.accentColor,
          secondaryColor: theme.primaryColor,
          icon: Icons.palette,
          width: double.infinity,
          outlined: true,
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

  Widget _buildBoardSizeSelector(GameProvider gameProvider, GameTheme theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Size',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedBoardSize.name,
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_selectedBoardSize.width} × ${_selectedBoardSize.height}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Board size preview
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                border: Border.all(
                  color: theme.accentColor.withValues(alpha: 0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: _BoardSizePainter(theme, _selectedBoardSize),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Text(
          _selectedBoardSize.description,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        // Board size selection buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: GameConstants.availableBoardSizes.map((boardSize) {
            final isSelected = _selectedBoardSize == boardSize;
            final isCurrentlyPlaying = gameProvider.isPlaying;
            
            return GestureDetector(
              onTap: isCurrentlyPlaying ? null : () async {
                setState(() {
                  _selectedBoardSize = boardSize;
                });
                await gameProvider.updateBoardSize(boardSize);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? theme.accentColor.withValues(alpha: 0.2)
                    : Colors.transparent,
                  border: Border.all(
                    color: isSelected 
                      ? theme.accentColor
                      : theme.accentColor.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${boardSize.name}\n${boardSize.width}×${boardSize.height}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isCurrentlyPlaying
                      ? theme.accentColor.withValues(alpha: 0.5)
                      : (isSelected ? theme.accentColor : Colors.white.withValues(alpha: 0.8)),
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        
        if (gameProvider.isPlaying) ...[
          const SizedBox(height: 12),
          Text(
            'Complete current game to change board size',
            style: TextStyle(
              color: Colors.orange.withValues(alpha: 0.8),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildCrashFeedbackDurationSelector(GameProvider gameProvider, GameTheme theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Duration',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_selectedCrashFeedbackDuration.inSeconds} seconds',
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Timer icon preview
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                border: Border.all(
                  color: theme.accentColor.withValues(alpha: 0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.timer,
                color: theme.accentColor,
                size: 24,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'How long to show crash explanation',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        // Duration selection buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: GameConstants.availableCrashFeedbackDurations.map((duration) {
            final isSelected = _selectedCrashFeedbackDuration == duration;
            
            return GestureDetector(
              onTap: () async {
                setState(() {
                  _selectedCrashFeedbackDuration = duration;
                });
                await gameProvider.updateCrashFeedbackDuration(duration);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? theme.accentColor.withValues(alpha: 0.2)
                    : Colors.transparent,
                  border: Border.all(
                    color: isSelected 
                      ? theme.accentColor
                      : theme.accentColor.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${duration.inSeconds}s',
                  style: TextStyle(
                    color: isSelected ? theme.accentColor : Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BoardSizePainter extends CustomPainter {
  final GameTheme theme;
  final BoardSize boardSize;

  _BoardSizePainter(this.theme, this.boardSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw a grid representation
    final cellSize = size.width / boardSize.width.toDouble();
    
    // Draw vertical lines
    for (int i = 0; i <= boardSize.width; i++) {
      if (i % 5 == 0) { // Only draw every 5th line to avoid clutter
        canvas.drawLine(
          Offset(i * cellSize, 0),
          Offset(i * cellSize, size.height),
          paint,
        );
      }
    }
    
    // Draw horizontal lines  
    for (int i = 0; i <= boardSize.height; i++) {
      if (i % 5 == 0) { // Only draw every 5th line to avoid clutter
        canvas.drawLine(
          Offset(0, i * cellSize),
          Offset(size.width, i * cellSize),
          paint,
        );
      }
    }
    
    // Draw a small snake representation
    final snakePaint = Paint()..color = theme.snakeColor;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, 2, snakePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}