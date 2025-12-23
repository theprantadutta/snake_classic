import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/screens/theme_selector_screen.dart';
import 'package:snake_classic/screens/cosmetics_screen.dart';
import 'package:snake_classic/screens/battle_pass_screen.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/services/username_service.dart';
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/gradient_button.dart';
import 'package:snake_classic/widgets/app_background.dart';

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
  bool _dPadEnabled = false;
  bool _screenShakeEnabled = false;
  DPadPosition _dPadPosition = DPadPosition.bottomCenter;
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
    final dPadEnabled = await _storageService.isDPadEnabled();
    final screenShakeEnabled = await _storageService.isScreenShakeEnabled();
    final dPadPosition = await _storageService.getDPadPosition();
    setState(() {
      _soundEnabled = _audioService.isSoundEnabled;
      _musicEnabled = _audioService.isMusicEnabled;
      _dPadEnabled = dPadEnabled;
      _screenShakeEnabled = screenShakeEnabled;
      _dPadPosition = dPadPosition;
      _selectedBoardSize = boardSize;
      _selectedCrashFeedbackDuration = crashFeedbackDuration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<GameCubit, GameCubitState>(
          builder: (context, gameState) {
            return BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                return BlocBuilder<PremiumCubit, PremiumState>(
                  builder: (context, premiumState) {
                    final theme = themeState.currentTheme;

                    return Scaffold(
                      extendBodyBehindAppBar: true,
                      appBar: AppBar(
                        title: Text(
                          'SETTINGS',
                          style: TextStyle(
                            color: theme.accentColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black.withValues(alpha: 0.3),
                              ),
                            ],
                          ),
                        ),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        iconTheme: IconThemeData(color: theme.accentColor),
                      ),
                      body: AppBackground(
                        theme: theme,
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 1. Controls Section (most frequently adjusted during gameplay)
                                  _buildSection(
                                    'CONTROLS',
                                    [
                                      _buildAudioSwitch(
                                        'D-Pad Controls',
                                        _dPadEnabled,
                                        (value) async {
                                          setState(() {
                                            _dPadEnabled = value;
                                          });
                                          await context.read<GameSettingsCubit>().updateDPadEnabled(value);
                                        },
                                        theme,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Show on-screen directional buttons during gameplay',
                                        style: TextStyle(
                                          color: theme.accentColor.withValues(alpha: 0.6),
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      // D-Pad Position Selector (only show when D-Pad is enabled)
                                      if (_dPadEnabled) ...[
                                        const SizedBox(height: 16),
                                        _buildDPadPositionSelector(gameState, theme),
                                      ],
                                      const SizedBox(height: 16),
                                      _buildControlInfo(theme),
                                    ],
                                    theme,
                                  ),

                                  const SizedBox(height: 32),

                                  // 2. Gameplay Section (board size + crash feedback + effects)
                                  _buildSection(
                                    'GAMEPLAY',
                                    [
                                      _buildBoardSizeSelector(gameState, theme),
                                      const SizedBox(height: 24),
                                      const Divider(height: 1),
                                      const SizedBox(height: 24),
                                      _buildCrashFeedbackDurationSelector(gameState, theme),
                                      const SizedBox(height: 24),
                                      const Divider(height: 1),
                                      const SizedBox(height: 24),
                                      _buildAudioSwitch(
                                        'Screen Shake',
                                        _screenShakeEnabled,
                                        (value) async {
                                          setState(() {
                                            _screenShakeEnabled = value;
                                          });
                                          await context.read<GameSettingsCubit>().setScreenShakeEnabled(value);
                                        },
                                        theme,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Shake the screen on collisions and game events',
                                        style: TextStyle(
                                          color: theme.accentColor.withValues(alpha: 0.6),
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                    theme,
                                  ),

                                  const SizedBox(height: 32),

                                  // 3. Audio Section
                                  _buildSection(
                                    'AUDIO',
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

                                  // 4. Visual Section (theme + trail effects)
                                  _buildSection(
                                    'VISUAL',
                                    [
                                      _buildThemeSelector(themeState, theme),
                                      const SizedBox(height: 24),
                                      const Divider(height: 1),
                                      const SizedBox(height: 24),
                                      _buildAudioSwitch(
                                        'Snake Trail Effects',
                                        themeState.isTrailSystemEnabled,
                                        (value) async {
                                          await context.read<ThemeCubit>().setTrailSystemEnabled(value);
                                        },
                                        theme,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Enable particle trails behind the snake',
                                        style: TextStyle(
                                          color: theme.accentColor.withValues(alpha: 0.6),
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                    theme,
                                  ),

                                  const SizedBox(height: 32),

                                  // 5. User Profile Section
                                  _buildSection(
                                    'USER PROFILE',
                                    [
                                      _buildUserProfileSettings(authState, theme),
                                    ],
                                    theme,
                                  ),

                                  const SizedBox(height: 32),

                                  // 6. Premium Section (if available)
                                  if (premiumState.isInitialized)
                                    _buildSection(
                                      'PREMIUM FEATURES',
                                      [
                                        _buildPremiumStatusCard(premiumState, theme),
                                        if (!premiumState.hasPremium)
                                          _buildUpgradeButton(premiumState, theme),
                                        _buildRestorePurchasesButton(premiumState, theme),
                                        _buildPurchaseHistoryButton(premiumState, theme),
                                        if (premiumState.hasPremium || premiumState.ownedSkins.isNotEmpty)
                                          _buildCosmeticsButton(premiumState, theme),
                                        if (premiumState.hasBattlePass)
                                          _buildBattlePassButton(premiumState, theme),
                                      ],
                                      theme,
                                    ),

                                  if (premiumState.isInitialized)
                                    const SizedBox(height: 32),

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
              },
            );
          },
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

  Widget _buildThemeSelector(ThemeState themeState, GameTheme theme) {
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

  Widget _buildDPadPositionSelector(GameCubitState gameState, GameTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.gamepad,
              color: theme.accentColor.withValues(alpha: 0.8),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'D-Pad Position',
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.backgroundColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: DPadPosition.values.map((position) {
              final isSelected = _dPadPosition == position;
              return Expanded(
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      _dPadPosition = position;
                    });
                    await context.read<GameSettingsCubit>().updateDPadPosition(position);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.accentColor.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? Border.all(color: theme.accentColor, width: 1.5)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          position.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          position.displayName,
                          style: TextStyle(
                            color: isSelected
                                ? theme.accentColor
                                : theme.accentColor.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildControlInfo(GameTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Platform-specific controls
        if (kIsWeb || (!defaultTargetPlatform.toString().contains('android') && !defaultTargetPlatform.toString().contains('ios'))) ...[
          // Desktop/Web controls
          Text(
            'Desktop/Web Controls',
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildControlItem('Arrow Keys', 'Change direction', theme),
          _buildControlItem('WASD Keys', 'Change direction', theme),
          _buildControlItem('Spacebar', 'Pause/Resume game', theme),
          _buildControlItem('Mouse Click', 'Pause/Resume game', theme),
          if (!kIsWeb) ...[
            const SizedBox(height: 16),
            Text(
              'Touch Controls (if available)',
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildControlItem('Swipe Gestures', 'Change direction', theme),
            _buildControlItem('Tap Screen', 'Pause/Resume game', theme),
          ],
        ] else ...[
          // Mobile controls
          Text(
            'Touch Controls',
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildControlItem('Swipe Up ↑', 'Move snake up', theme),
          _buildControlItem('Swipe Down ↓', 'Move snake down', theme),
          _buildControlItem('Swipe Left ←', 'Move snake left', theme),
          _buildControlItem('Swipe Right →', 'Move snake right', theme),
          _buildControlItem('Tap Screen', 'Pause/Resume game', theme),
        ],
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

  Widget _buildBoardSizeSelector(GameCubitState gameState, GameTheme theme) {
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
            final isCurrentlyPlaying = gameState.isPlaying;

            return GestureDetector(
              onTap: isCurrentlyPlaying ? null : () async {
                setState(() {
                  _selectedBoardSize = boardSize;
                });
                await context.read<GameSettingsCubit>().updateBoardSize(boardSize);
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
        
        if (gameState.isPlaying) ...[
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

  Widget _buildCrashFeedbackDurationSelector(GameCubitState gameState, GameTheme theme) {
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
                    GameConstants.getCrashFeedbackLabel(_selectedCrashFeedbackDuration),
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
                await context.read<GameSettingsCubit>().updateCrashFeedbackDuration(duration);
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
                  GameConstants.getCrashFeedbackLabel(duration),
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

  Widget _buildUserProfileSettings(AuthState authState, GameTheme theme) {
    return Column(
      children: [
        // Current username display
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Username',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        authState.isGuestUser ? Icons.person_outline : Icons.verified_user,
                        color: authState.isGuestUser ? Colors.orange : Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          authState.displayName,
                          style: TextStyle(
                            color: theme.accentColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    authState.isGuestUser ? 'Guest Account' : 'Authenticated Account',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Profile type indicator
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                border: Border.all(
                  color: (authState.isGuestUser ? Colors.orange : Colors.green).withValues(alpha: 0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                authState.isGuestUser ? Icons.person_outline : Icons.account_circle,
                color: authState.isGuestUser ? Colors.orange : Colors.green,
                size: 24,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Username actions
        if (authState.isGuestUser) ...[
          // For guest users, allow username change
          GradientButton(
            onPressed: () => _showUsernameDialog(authState, theme),
            text: 'CHANGE USERNAME',
            primaryColor: Colors.orange,
            secondaryColor: Colors.deepOrange,
            icon: Icons.edit,
            width: double.infinity,
            outlined: true,
          ),
          const SizedBox(height: 12),
          Text(
            'Sign in to keep your progress and play with friends',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ] else ...[
          // For authenticated users
          GradientButton(
            onPressed: () => _showUsernameDialog(authState, theme),
            text: 'CHANGE USERNAME',
            primaryColor: theme.accentColor,
            secondaryColor: theme.primaryColor,
            icon: Icons.edit,
            width: double.infinity,
            outlined: true,
          ),
          const SizedBox(height: 12),
          Text(
            'Your username is visible to friends and on leaderboards',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  void _showUsernameDialog(AuthState authState, GameTheme theme) {
    final TextEditingController usernameController = TextEditingController();
    final UsernameService usernameService = UsernameService();
    String? errorMessage;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              backgroundColor: theme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.accentColor.withValues(alpha: 0.3)),
              ),
              title: Text(
                'Change Username',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Choose a unique username that represents you in the game.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: theme.accentColor.withValues(alpha: 0.7)),
                      hintText: 'Enter new username',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                      filled: true,
                      fillColor: theme.backgroundColor.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.accentColor.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.accentColor.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.accentColor),
                      ),
                      errorText: errorMessage,
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                    style: TextStyle(color: Colors.white),
                    maxLength: 20,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '• 3-20 characters\n• Must start with a letter\n• Letters, numbers, and underscores only',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: theme.accentColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    final newUsername = usernameController.text.trim();
                    if (newUsername.isEmpty) return;

                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });

                    bool success = false;
                    final authCubit = context.read<AuthCubit>();

                    if (authState.isGuestUser) {
                      success = await authCubit.updateGuestUsername(newUsername);
                      if (!success) {
                        final validation = usernameService.validateUsername(newUsername);
                        setState(() {
                          errorMessage = validation.error ?? 'Failed to update username';
                        });
                      }
                    } else {
                      // For authenticated users
                      success = await authCubit.updateAuthenticatedUsername(newUsername);
                      if (!success) {
                        final validation = await UsernameService().validateUsernameComplete(newUsername);
                        setState(() {
                          errorMessage = validation.error ?? 'Failed to update username';
                        });
                      }
                    }

                    if (success && dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Username updated to "$newUsername"'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }

                    setState(() {
                      isLoading = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Update',
                        style: TextStyle(color: Colors.white),
                      ),
                ),
              ],
            );
          },
        );
      },
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

// Premium UI Components
extension _SettingsPremium on _SettingsScreenState {
  Widget _buildPremiumStatusCard(PremiumState premiumState, GameTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: premiumState.hasPremium
            ? const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              )
            : LinearGradient(
                colors: [
                  theme.accentColor.withValues(alpha: 0.1),
                  theme.backgroundColor.withValues(alpha: 0.05),
                ],
              ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: premiumState.hasPremium
              ? Colors.amber
              : theme.accentColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            premiumState.hasPremium ? Icons.diamond : Icons.lock,
            color: premiumState.hasPremium ? Colors.black : theme.accentColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  premiumState.hasPremium ? 'Snake Classic Pro' : 'Premium Status',
                  style: TextStyle(
                    color: premiumState.hasPremium ? Colors.black : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  premiumState.hasPremium
                      ? 'Active subscription'
                      : 'Unlock premium features',
                  style: TextStyle(
                    color: premiumState.hasPremium
                        ? Colors.black.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                if (premiumState.hasPremium && premiumState.subscriptionExpiry != null)
                  Text(
                    'Renews ${premiumState.subscriptionExpiry!.day}/${premiumState.subscriptionExpiry!.month}',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (premiumState.hasPremium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton(PremiumState premiumState, GameTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GradientButton(
        onPressed: () => _showPremiumDialog(),
        text: 'Upgrade to Pro',
        primaryColor: const Color(0xFFFFD700),
        secondaryColor: const Color(0xFFFFA500),
        icon: Icons.star,
      ),
    );
  }

  Widget _buildRestorePurchasesButton(PremiumState premiumState, GameTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextButton(
        onPressed: () => _restorePurchases(),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: theme.accentColor.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.accentColor.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restore, color: theme.accentColor),
            const SizedBox(width: 8),
            Text(
              'Restore Purchases',
              style: TextStyle(
                color: theme.accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseHistoryButton(PremiumState premiumState, GameTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextButton(
        onPressed: () => _showPurchaseHistory(),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: theme.accentColor.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.accentColor.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, color: theme.accentColor),
            const SizedBox(width: 8),
            Text(
              'Purchase History',
              style: TextStyle(
                color: theme.accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCosmeticsButton(PremiumState premiumState, GameTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextButton(
        onPressed: () => _openCosmeticsSelector(),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: theme.accentColor.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.accentColor.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.palette, color: theme.accentColor),
            const SizedBox(width: 8),
            Text(
              'Snake Cosmetics',
              style: TextStyle(
                color: theme.accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            if (premiumState.ownedSkins.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${premiumState.ownedSkins.length}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBattlePassButton(PremiumState premiumState, GameTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.withValues(alpha: 0.3),
              Colors.blue.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purple.withValues(alpha: 0.5)),
        ),
        child: TextButton(
          onPressed: () => _openBattlePass(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.military_tech, color: Colors.purple),
              const SizedBox(width: 8),
              const Text(
                'Battle Pass',
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Tier ${premiumState.battlePassTier}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        title: const Row(
          children: [
            Icon(Icons.diamond, color: Colors.amber),
            SizedBox(width: 8),
            Text('Snake Classic Pro', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upgrade to Pro and unlock:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 16),
            Text('✓ All premium themes', style: TextStyle(color: Colors.white)),
            Text('✓ Exclusive snake skins', style: TextStyle(color: Colors.white)),
            Text('✓ Premium power-ups', style: TextStyle(color: Colors.white)),
            Text('✓ Battle Pass included', style: TextStyle(color: Colors.white)),
            Text('✓ Priority support', style: TextStyle(color: Colors.white)),
            SizedBox(height: 16),
            Text(
              '\$4.99/month',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _purchasePro();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }

  void _purchasePro() {
    final purchaseService = PurchaseService();
    final product = purchaseService.getProduct(ProductIds.snakeClassicProMonthly);
    
    if (product != null) {
      purchaseService.buyProduct(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Initiating Pro subscription...'),
          backgroundColor: Colors.amber,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subscription not available. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _restorePurchases() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Restoring purchases...'),
          backgroundColor: Colors.blue,
        ),
      );
      
      final purchaseService = PurchaseService();
      await purchaseService.restorePurchases();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchases restored successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to restore purchases. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPurchaseHistory() async {
    try {
      final premiumCubit = context.read<PremiumCubit>();
      final history = await premiumCubit.getPurchaseHistory();
      
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Purchase History'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: history.isEmpty
                ? const Center(
                    child: Text(
                      'No purchases found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final purchase = history[index];
                      // Purchase is already a Map<String, dynamic>
                      try {
                        final productId = purchase['productId']?.toString() ?? 'Unknown';
                        final transactionDate = purchase['transactionDate']?.toString() ?? '';
                        final status = purchase['status']?.toString() ?? 'Unknown';

                        return Card(
                          child: ListTile(
                            leading: Icon(_getPurchaseIcon(_getTypeFromProductId(productId))),
                            title: Text(_formatProductName(productId)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Status: $status'),
                                Text('Date: ${_formatDate(transactionDate)}'),
                              ],
                            ),
                          ),
                        );
                      } catch (e) {
                        return ListTile(
                          title: Text('Purchase #${index + 1}'),
                          subtitle: const Text('Data parsing error'),
                        );
                      }
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load purchase history'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getPurchaseIcon(String type) {
    switch (type) {
      case 'subscription':
        return Icons.star;
      case 'theme':
        return Icons.palette;
      case 'skin':
        return Icons.pets;
      case 'trail':
        return Icons.auto_awesome;
      case 'bundle':
        return Icons.shopping_bag;
      case 'battlepass':
        return Icons.emoji_events;
      case 'tournament':
        return Icons.sports_esports;
      default:
        return Icons.shopping_cart;
    }
  }

  String _formatDate(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown date';
    }
  }

  String _getTypeFromProductId(String productId) {
    if (productId.contains('pro_monthly') || productId.contains('pro_yearly')) {
      return 'subscription';
    } else if (productId.contains('theme')) {
      return 'theme';
    } else if (productId.contains('skin')) {
      return 'skin';
    } else if (productId.contains('trail')) {
      return 'trail';
    } else if (productId.contains('bundle')) {
      return 'bundle';
    } else if (productId.contains('battle_pass')) {
      return 'battlepass';
    } else if (productId.contains('tournament')) {
      return 'tournament';
    }
    return 'unknown';
  }

  String _formatProductName(String productId) {
    // Convert product ID to human-readable name
    return productId
        .replaceAll('snake_classic_', '')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  void _openCosmeticsSelector() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CosmeticsScreen(),
      ),
    );
  }

  void _openBattlePass() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BattlePassScreen(),
      ),
    );
  }
}