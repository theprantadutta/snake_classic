import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/services/telemetry/design_feedback.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';

/// Ask "How's the game feeling?" if this install is due the question
/// (DesignFeedbackPolicy), and record the answer. Returns whether the dialog
/// was shown, so a prompt queue can call it a visit's interruption.
///
/// The classic design's version of the Living Board feedback sheet: the same
/// question, the same rules and the same strings, in the AlertDialog style of
/// the other Home prompts (notification soft-ask, free power-up offer).
///
/// Never during a run: callers are screens outside gameplay (Home), and the
/// check below refuses anyway while a run is live.
Future<bool> maybeShowDesignFeedback(BuildContext context) async {
  if (!getIt.isRegistered<DesignFeedbackService>()) return false;
  if (_runIsLive(context)) return false;
  final service = getIt<DesignFeedbackService>();
  if (!await service.claimOffer()) return false;
  if (!context.mounted) return false;

  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  final theme = context.read<ThemeCubit>().state.currentTheme;
  final answer = await showDialog<DesignFeedbackAnswer>(
    context: context,
    builder: (_) => DesignFeedbackDialog(theme: theme),
  );

  if (answer == null) {
    // NOT NOW, the back button and a tap on the scrim are all the same answer.
    await service.dismiss();
    return true;
  }
  await service.submit(rating: answer.rating, comment: answer.comment);
  messenger.showSnackBar(
    arcadeSnackBarFor(
      theme,
      message: l10n.dfThanks,
      tone: ArcadeSnackTone.success,
    ),
  );
  return true;
}

bool _runIsLive(BuildContext context) {
  try {
    final status = context.read<GameCubit>().state.status;
    return status == GamePlayStatus.playing ||
        status == GamePlayStatus.paused ||
        status == GamePlayStatus.crashed;
  } catch (_) {
    // No GameCubit above this context: nothing can be running.
    return false;
  }
}

/// What the dialog hands back when the player sends an answer.
class DesignFeedbackAnswer {
  const DesignFeedbackAnswer(this.rating, this.comment);
  final int rating;
  final String? comment;
}

/// The feedback dialog: five numbered tiles for 1–5, an optional comment,
/// NOT NOW and SEND. Pops a [DesignFeedbackAnswer], or null.
class DesignFeedbackDialog extends StatefulWidget {
  const DesignFeedbackDialog({super.key, required this.theme});

  final GameTheme theme;

  @override
  State<DesignFeedbackDialog> createState() => _DesignFeedbackDialogState();
}

class _DesignFeedbackDialogState extends State<DesignFeedbackDialog> {
  final _comment = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = widget.theme;
    final dim = theme.accentColor.withValues(alpha: 0.6);

    return AlertDialog(
      // Scrolls the comment field and the buttons clear of the keyboard.
      scrollable: true,
      backgroundColor: theme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.accentColor.withValues(alpha: 0.4)),
      ),
      title: Row(
        children: [
          Icon(Icons.rate_review_rounded, color: theme.accentColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.dfTitle,
              style: TextStyle(
                color: theme.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.dfBody,
            style: TextStyle(
              color: theme.accentColor.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: i == 1 ? 0 : 6),
                    child: _RatingTile(
                      value: i,
                      lit: i <= _rating,
                      selected: i == _rating,
                      theme: theme,
                      semanticLabel: l10n.dfRatingOption(i),
                      onTap: () => setState(() => _rating = i),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.dfLow,
                  style: TextStyle(color: dim, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  l10n.dfHigh,
                  textAlign: TextAlign.end,
                  style: TextStyle(color: dim, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _comment,
            minLines: 2,
            maxLines: 4,
            maxLength: DesignFeedbackService.maxCommentLength,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            cursorColor: theme.accentColor,
            decoration: InputDecoration(
              labelText: l10n.dfCommentLabel,
              labelStyle: TextStyle(color: dim),
              counterStyle: TextStyle(color: dim),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.04),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.accentColor.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.accentColor),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dfNotNow, style: TextStyle(color: dim)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.accentColor,
            foregroundColor: theme.backgroundColor,
            disabledBackgroundColor: theme.accentColor.withValues(alpha: 0.2),
            disabledForegroundColor: theme.backgroundColor.withValues(
              alpha: 0.6,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _rating == 0
              ? null
              : () =>
                    Navigator.of(context)
                        .pop(DesignFeedbackAnswer(_rating, _comment.text)),
          child: Text(
            l10n.dfSend,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

/// One of the five rating tiles, filled up to and including the chosen
/// rating so the row reads like a filling bar.
class _RatingTile extends StatelessWidget {
  const _RatingTile({
    required this.value,
    required this.lit,
    required this.selected,
    required this.theme,
    required this.semanticLabel,
    required this.onTap,
  });

  final int value;
  final bool lit;
  final bool selected;
  final GameTheme theme;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: lit
            ? theme.accentColor
            : theme.accentColor.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.accentColor.withValues(alpha: lit ? 1 : 0.35),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            height: 48 * context.uiScale,
            child: Center(
              child: Text(
                '$value',
                style: TextStyle(
                  color: lit
                      ? theme.backgroundColor
                      : theme.accentColor.withValues(alpha: 0.85),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
