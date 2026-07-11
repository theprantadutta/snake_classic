import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/presentation/bloc/game/game_settings_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/game_animations.dart';
import 'package:snake_classic/widgets/gradient_button.dart';
import 'package:snake_classic/widgets/pickup_icon.dart';

class PauseOverlay extends StatefulWidget {
  final GameTheme theme;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onHome;
  /// Called from the new "How to Play" button — re-launches the gameplay
  /// tutorial route. Optional so callers that don't wire it up still build.
  final VoidCallback? onShowTutorial;

  const PauseOverlay({
    super.key,
    required this.theme,
    required this.onResume,
    required this.onRestart,
    required this.onHome,
    this.onShowTutorial,
  });

  @override
  State<PauseOverlay> createState() => _PauseOverlayState();
}

class _PauseOverlayState extends State<PauseOverlay> {
  // Audio settings live in AudioService (backed by Drift + sync outbox),
  // not in a cubit, so the overlay mirrors them in local state. The
  // service is a singleton — the same instance the Settings screen reads
  // — so flips made here are durable and show up there.
  final AudioService _audioService = AudioService();
  late bool _soundOn = _audioService.isSoundEnabled;
  late bool _musicOn = _audioService.isMusicEnabled;

  GameTheme get theme => widget.theme;
  VoidCallback get onResume => widget.onResume;
  VoidCallback get onRestart => widget.onRestart;
  VoidCallback get onHome => widget.onHome;
  VoidCallback? get onShowTutorial => widget.onShowTutorial;

  @override
  Widget build(BuildContext context) {
    // Blur the board behind the overlay so the pause visibly disengages the
    // world. Drop the opaque tint to 0.55 — at 0.8 the board was fully hidden
    // and the blur had nothing to do.
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.accentColor.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          // Stack so the top-right close button sits inside the dialog's
          // padded area, above the scrollable content.
          child: Stack(
            children: [
              // Scrollable so expanding the Game Guide on a short screen doesn't
              // overflow the dialog. shrinkWrap behaviour from SingleChildScrollView
              // means the dialog still sizes to its content when it fits.
              SingleChildScrollView(
                child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              // Pause Icon — sized down from 64 so the menu reads more
              // compact overall.
              Icon(
                Icons.pause_circle_filled,
                size: 44,
                color: theme.accentColor,
              ).gamePop(delay: 50.ms),

              const SizedBox(height: 8),

              // Pause Text
              Text(
                'PAUSED',
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ).gameEntrance(delay: 100.ms),

              const SizedBox(height: 16),

              // Store Access Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStoreButton(
                    context: context,
                    icon: Icons.star,
                    label: 'Premium',
                    colors: [Colors.purple, Colors.blue],
                    onTap: () => context.push(AppRoutes.premiumBenefits),
                  ),
                  const SizedBox(width: 12),
                  _buildStoreButton(
                    context: context,
                    icon: Icons.store,
                    label: 'Store',
                    colors: [Colors.orange, Colors.amber],
                    onTap: () => context.push(AppRoutes.store),
                  ),
                ],
              ).gameEntrance(delay: 150.ms),

              const SizedBox(height: 12),

              // Game Guide Section (moved from game screen)
              _buildGameGuideSection(),

              const SizedBox(height: 12),

              // Main Action Buttons — compact: 170w × 42h with 10px gaps
              // so the stack of five buttons fits more screens without
              // dominating the dialog.
              Column(
                children: [
                  GradientButton(
                    onPressed: onResume,
                    text: 'RESUME',
                    primaryColor: theme.accentColor,
                    secondaryColor: theme.foodColor,
                    icon: Icons.play_arrow,
                    width: 170,
                    height: 42,
                  ).gameZoomIn(delay: 200.ms),

                  const SizedBox(height: 10),

                  GradientButton(
                    onPressed: onRestart,
                    text: 'RESTART',
                    primaryColor: theme.accentColor.withValues(alpha: 0.8),
                    secondaryColor: theme.accentColor.withValues(alpha: 0.6),
                    icon: Icons.refresh,
                    width: 170,
                    height: 42,
                    outlined: true,
                  ).gameZoomIn(delay: 250.ms),

                  const SizedBox(height: 10),

                  GradientButton(
                    onPressed: onHome,
                    text: 'HOME',
                    primaryColor: theme.snakeColor.withValues(alpha: 0.8),
                    secondaryColor: theme.snakeColor.withValues(alpha: 0.6),
                    icon: Icons.home,
                    width: 170,
                    height: 42,
                    outlined: true,
                  ).gameZoomIn(delay: 300.ms),

                  const SizedBox(height: 10),

                  // D-Pad toggle. Wrapped in BlocBuilder so the label /
                  // icon flip live when the user taps it without closing
                  // the overlay. Same Cubit method the Settings screen
                  // uses, so the choice is durable across runs.
                  BlocBuilder<GameSettingsCubit, GameSettingsState>(
                    buildWhen: (prev, curr) =>
                        prev.dPadEnabled != curr.dPadEnabled,
                    builder: (context, settings) {
                      final on = settings.dPadEnabled;
                      return GradientButton(
                        onPressed: () => context
                            .read<GameSettingsCubit>()
                            .updateDPadEnabled(!on),
                        text: on ? 'D-PAD: ON' : 'D-PAD: OFF',
                        primaryColor: on
                            ? theme.accentColor.withValues(alpha: 0.8)
                            : theme.accentColor.withValues(alpha: 0.5),
                        secondaryColor: on
                            ? theme.accentColor.withValues(alpha: 0.6)
                            : theme.accentColor.withValues(alpha: 0.3),
                        icon: on
                            ? Icons.gamepad
                            : Icons.gamepad_outlined,
                        width: 170,
                        height: 42,
                        outlined: !on,
                      ).gameZoomIn(delay: 320.ms);
                    },
                  ),

                  const SizedBox(height: 10),

                  // Sound / Music toggles — same 170px footprint as the
                  // buttons above, split into two chips. Persisted through
                  // AudioService so the change is immediate (mutes the
                  // enhanced SFX channel too) and durable across runs.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAudioToggle(
                        label: 'SOUND',
                        value: _soundOn,
                        onIcon: Icons.volume_up,
                        offIcon: Icons.volume_off,
                        onChanged: (value) async {
                          setState(() => _soundOn = value);
                          await _audioService.setSoundEnabled(value);
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildAudioToggle(
                        label: 'MUSIC',
                        value: _musicOn,
                        onIcon: Icons.music_note,
                        offIcon: Icons.music_off,
                        onChanged: (value) async {
                          setState(() => _musicOn = value);
                          await _audioService.setMusicEnabled(value);
                        },
                      ),
                    ],
                  ).gameZoomIn(delay: 340.ms),

                  if (onShowTutorial != null) ...[
                    const SizedBox(height: 10),
                    GradientButton(
                      onPressed: onShowTutorial!,
                      text: 'HOW TO PLAY',
                      primaryColor:
                          theme.accentColor.withValues(alpha: 0.7),
                      secondaryColor:
                          theme.accentColor.withValues(alpha: 0.4),
                      icon: Icons.help_outline,
                      width: 170,
                      height: 42,
                      outlined: true,
                    ).gameZoomIn(delay: 350.ms),
                  ],
                ],
              ),
            ],
          ),
              ),
              // Close button — top-right corner of the dialog. Tapping it
              // resumes the game (same as the RESUME button below) so the
              // gesture matches every other modal X in the app.
              Positioned(
                top: 0,
                right: 0,
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onResume,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.close_rounded,
                        size: 22,
                        color: theme.accentColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  /// Compact 80×42 toggle chip — two of these plus the 10px gap match the
  /// 170px main-button column width. Dimmed/outlined when off, mirroring
  /// the D-Pad button's on/off treatment above.
  Widget _buildAudioToggle({
    required String label,
    required bool value,
    required IconData onIcon,
    required IconData offIcon,
    required ValueChanged<bool> onChanged,
  }) {
    final color = theme.accentColor;
    return GestureDetector(
      onTap: () {
        // Click cue fires before the flip so toggling sound OFF still
        // confirms the tap; the service gates it when sound is off.
        _audioService.playSound('button_click');
        onChanged(!value);
      },
      child: Container(
        width: 80,
        height: 42,
        decoration: BoxDecoration(
          color: value
              ? color.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: value ? 0.7 : 0.35),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              value ? onIcon : offIcon,
              size: 16,
              color: color.withValues(alpha: value ? 0.9 : 0.45),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: value ? 0.9 : 0.45),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameGuideSection() {
    // Color + border were on an outer DecoratedBox, which hid ExpansionTile's
    // (internally a ListTile) ink ripple and triggered Flutter's
    // Material-ancestor warning. Moved onto ExpansionTile's own
    // backgroundColor + shape (both states) so ripples render correctly.
    // Widened from 220 → 260 to fit the expanded section labels
    // ("PowerUp Madness", "Slow Motion", etc.) without ellipsizing.
    final guideShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: theme.accentColor.withValues(alpha: 0.3)),
    );
    return SizedBox(
      width: 260,
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          backgroundColor: theme.backgroundColor.withValues(alpha: 0.5),
          collapsedBackgroundColor:
              theme.backgroundColor.withValues(alpha: 0.5),
          shape: guideShape,
          collapsedShape: guideShape,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.help_outline,
                color: theme.accentColor.withValues(alpha: 0.8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'GAME GUIDE',
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          iconColor: theme.accentColor,
          collapsedIconColor: theme.accentColor.withValues(alpha: 0.6),
          children: [
            // FOOD
            _buildGuideSubheader('FOOD'),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFoodItem(
                    PickupIcon.food(FoodType.normal, size: 22), '10 pts'),
                _buildFoodItem(
                    PickupIcon.food(FoodType.bonus, size: 22), '25 pts'),
                _buildFoodItem(
                    PickupIcon.food(FoodType.special, size: 22), '50 pts'),
              ],
            ),

            const SizedBox(height: 12),

            // COMBO
            _buildGuideSubheader('COMBO'),
            const SizedBox(height: 4),
            _buildGuideRow('🔥', '5 bites', '1.5×'),
            _buildGuideRow('🔥', '10 bites', '2×'),
            _buildGuideRow('🔥', '20 bites', '3×'),
            const SizedBox(height: 2),
            _buildGuideHint(
              'The fire chip near your score heats up and pulses on each tier crossing.',
            ),

            const SizedBox(height: 12),

            // POWER-UPS
            _buildGuideSubheader('POWER-UPS'),
            const SizedBox(height: 4),
            _buildGuideRowIcon(
                PickupIcon.powerUp(PowerUpType.speedBoost, size: 15),
                'Speed Boost',
                '7s'),
            _buildGuideRowIcon(
                PickupIcon.powerUp(PowerUpType.invincibility, size: 15),
                'Invincibility',
                '6s'),
            _buildGuideRowIcon(
                PickupIcon.powerUp(PowerUpType.scoreMultiplier, size: 15),
                'Score 2×',
                '10s'),
            _buildGuideRowIcon(
                PickupIcon.powerUp(PowerUpType.slowMotion, size: 15),
                'Slow Motion',
                '8s'),
            const SizedBox(height: 2),
            _buildGuideHint(
              'The ring around the icon drains as it expires. Timer freezes on pause.',
            ),

            const SizedBox(height: 12),

            // CRASH FEEDBACK
            _buildGuideSubheader('CRASH'),
            const SizedBox(height: 4),
            _buildGuideHint(
              'A red shockwave fires at the cell you died on. Self-collision also highlights the body segment you hit in yellow.',
            ),

            const SizedBox(height: 12),

            // MODES
            _buildGuideSubheader('MODES'),
            const SizedBox(height: 4),
            _buildGuideRow('🐍', 'Classic', 'walls on'),
            _buildGuideRow('🌿', 'Zen', 'walls off'),
            _buildGuideRow('⚡', 'Speed', 'fast tick'),
            _buildGuideRow('🍎', 'Multi-Food', '3 foods at once'),
            _buildGuideRow('❤️', 'Survival', '3 lives, ramps up'),
            _buildGuideRow('⏱', 'TimeAttack', '3 min total'),
            _buildGuideRow('🎆', 'PowerUp Madness', 'frequent power-ups'),
            _buildGuideRow('💎', 'Perfect Game', "don't cross your trail"),
          ],
        ),
      ),
    ).gameEntrance(delay: 180.ms);
  }

  Widget _buildGuideSubheader(String label) {
    return Text(
      label,
      style: TextStyle(
        color: theme.accentColor.withValues(alpha: 0.65),
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.4,
      ),
    );
  }

  Widget _buildGuideRow(String emoji, String label, String value) {
    return _buildGuideRowIcon(
      Text(emoji, style: const TextStyle(fontSize: 12)),
      label,
      value,
    );
  }

  /// Guide row with a widget icon — used for the pickup rows so they show
  /// the same sprite art as the board.
  Widget _buildGuideRowIcon(Widget icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        children: [
          SizedBox(width: 16, child: Center(child: icon)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.85),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: theme.foodColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideHint(String text) {
    return Text(
      text,
      style: TextStyle(
        color: theme.accentColor.withValues(alpha: 0.55),
        fontSize: 10,
        height: 1.3,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildFoodItem(Widget icon, String points) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(height: 2),
        Text(
          points,
          style: TextStyle(
            color: theme.foodColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStoreButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors.map((c) => c.withValues(alpha: 0.2)).toList(),
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.first.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colors.first, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: colors.first,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
