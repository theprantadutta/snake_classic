import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/services/telemetry/design_feedback.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/auth/lb_auth_widgets.dart';

/// Ask "How's the game feeling?" if this install is due the question
/// (DesignFeedbackPolicy), and record the answer. Returns whether the sheet
/// was shown, so a prompt queue can call it a visit's interruption.
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
  final snackTheme = context.read<ThemeCubit>().state.currentTheme;
  final answer = await showLBSheet<DesignFeedbackAnswer>(
    context: context,
    title: l10n.dfTitle,
    builder: (_) => const DesignFeedbackSheet(),
  );

  if (answer == null) {
    // NOT NOW, a swipe down and a tap on the scrim are all the same answer.
    await service.dismiss();
    return true;
  }
  await service.submit(rating: answer.rating, comment: answer.comment);
  messenger.showSnackBar(
    arcadeSnackBarFor(
      snackTheme,
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

/// What the sheet hands back when the player sends an answer.
class DesignFeedbackAnswer {
  const DesignFeedbackAnswer(this.rating, this.comment);
  final int rating;
  final String? comment;
}

/// The body of the feedback sheet: five cell blocks for 1–5, an optional
/// comment, SEND and NOT NOW. Pops a [DesignFeedbackAnswer], or null.
class DesignFeedbackSheet extends StatefulWidget {
  const DesignFeedbackSheet({super.key});

  @override
  State<DesignFeedbackSheet> createState() => _DesignFeedbackSheetState();
}

class _DesignFeedbackSheetState extends State<DesignFeedbackSheet> {
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
    final p = context.lb;
    final scale = context.uiScale;

    return SingleChildScrollView(
      // Lifts the comment field and the buttons above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.dfBody,
            style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 12.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                Expanded(
                  child: _RatingCell(
                    value: i,
                    lit: i <= _rating,
                    height: 56 * scale,
                    semanticLabel: l10n.dfRatingOption(i),
                    selected: i == _rating,
                    onTap: () => setState(() => _rating = i),
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
                  style: LBText.label(p, color: p.inkDim),
                ),
              ),
              Expanded(
                child: Text(
                  l10n.dfHigh,
                  textAlign: TextAlign.end,
                  style: LBText.label(p, color: p.inkDim),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _comment,
            minLines: 2,
            maxLines: 4,
            maxLength: DesignFeedbackService.maxCommentLength,
            textCapitalization: TextCapitalization.sentences,
            style: LBText.body(p, color: p.ink, size: 13),
            cursorColor: p.lime,
            decoration: lbInputDecoration(context, label: l10n.dfCommentLabel),
          ),
          const SizedBox(height: 14),
          LBPrimaryBlock(
            label: l10n.dfSend,
            height: 52 * scale,
            onTap: _rating == 0
                ? null
                : () => Navigator.of(context).pop(
                      DesignFeedbackAnswer(_rating, _comment.text),
                    ),
          ),
          LBBlock(
            kind: LBBlockKind.muted,
            height: 48 * scale,
            alignment: Alignment.center,
            onTap: () => Navigator.of(context).pop(),
            child: Text(
              l10n.dfNotNow.toUpperCase(),
              style: LBText.button(p, color: p.inkMuted, size: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// One of the five rating blocks: the number in cell type, lit up to and
/// including the chosen rating so the row reads like a filling bar.
class _RatingCell extends StatelessWidget {
  const _RatingCell({
    required this.value,
    required this.lit,
    required this.selected,
    required this.height,
    required this.semanticLabel,
    required this.onTap,
  });

  final int value;
  final bool lit;
  final bool selected;
  final double height;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return Semantics(
      selected: selected,
      child: LBBlock(
        kind: LBBlockKind.outline,
        selected: lit,
        height: height,
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        semanticLabel: semanticLabel,
        onTap: onTap,
        child: LBCellText(
          '$value',
          cell: 4,
          glow: lit,
          color: lit ? p.lime : p.inkDim,
        ),
      ),
    );
  }
}
