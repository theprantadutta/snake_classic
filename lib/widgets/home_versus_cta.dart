import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/typography.dart';

/// The secondary Home action: open the Versus lobby.
///
/// Deliberately quiet next to PLAY — an outlined pill, not a second hero
/// button — because there is exactly one primary action on this screen and it
/// is still Play. But persistent, because Versus was previously the eighth
/// tile of a two-row nav grid, absent from the Home tour and absent from
/// Help, which made a whole online mode effectively invisible to anyone who
/// had not gone looking.
///
/// [onOpen] opens the lobby and stops there. No queue is joined from Home:
/// the player picks Find Match, Join or Create once they can see the options.
/// And no connectivity pre-flight gates the tap — the lobby's own request is
/// the source of truth about the network and already reports being offline
/// properly, whereas a local pre-check can only guess, and guesses wrong in a
/// way the player cannot argue with.
///
/// The copy says Quick Match finds an opponent. It does not say who the
/// opponent is, because that is not something the matchmaker promises.
class HomeVersusCta extends StatelessWidget {
  const HomeVersusCta({
    super.key,
    required this.theme,
    required this.onOpen,
    this.isCompact = false,
  });

  final GameTheme theme;
  final VoidCallback onOpen;

  /// Tighter type and padding for short screens, where this sits between the
  /// play button and the stats row.
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // onTap is not decoration here. `excludeSemantics` drops the
    // GestureDetector's own semantics along with everything else beneath,
    // so without an action on this node a screen reader would announce a
    // button and then have nothing to activate — a control that says "button"
    // and cannot be pressed is worse than an unlabelled one.
    return Semantics(
      button: true,
      label: '${l10n.homeVersusCta}. ${l10n.homeVersusSubtitle}',
      onTap: onOpen,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onOpen,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 16 : 20,
            vertical: isCompact ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: theme.backgroundColor.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.45),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sports_esports,
                color: theme.accentColor,
                size: isCompact ? 20 : 24,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeVersusCta,
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: isCompact ? 14 : 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: context.letterSpacing(1.5),
                        height: 1.1,
                      ),
                    ),
                    Text(
                      l10n.homeVersusSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.accentColor.withValues(alpha: 0.7),
                        fontSize: isCompact ? 10 : 11,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
