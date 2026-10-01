import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// How to Play, on the Living Board.
///
/// The objective leads in plain text; everything below it is reference
/// material in outline blocks under section labels: controls (phone and
/// keyboard), Versus, food, rules and tips.
///
/// The reference tables lay out as two flexible columns that can both wrap.
/// The screen this grew out of put every control name in a fixed 140px pill,
/// which fit "Swipe Up" in English and nothing else — "Croix directionnelle
/// à l'écran" wrapped to three lines inside it, and at a 2.0 accessibility
/// scale the whole reference collapsed. Keep it flexible.
class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final g = context.lbGutter;

    return LBScaffold(
      title: l10n.insHowToPlay,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(g, context.lbCell * .9, g, context.lbCell * 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Objective(l10n: l10n),
            _section(context, l10n.insControls, [
              _GroupLabel(l10n.insOnPhone),
              _Row(l10n.insSwipeUp, l10n.insSwipeUpDesc),
              _Row(l10n.insSwipeDown, l10n.insSwipeDownDesc),
              _Row(l10n.insSwipeLeft, l10n.insSwipeLeftDesc),
              _Row(l10n.insSwipeRight, l10n.insSwipeRightDesc),
              _Row(l10n.insDpad, l10n.insDpadDesc),
              _Row(l10n.insTurnButtons, l10n.insTurnButtonsDesc),
              _Row(l10n.insJoystick, l10n.insJoystickDesc),
              _Row(l10n.insSnap, l10n.insSnapDesc),
              // "Tap Screen — Pause/Resume" used to be here, describing a
              // handler the game has never had. The pause button is the real
              // one.
              _Row(l10n.insHudPause, l10n.insHudPauseDesc),
              const SizedBox(height: 14),
              _GroupLabel(l10n.insOnKeyboard),
              _Row(l10n.insArrowKeys, l10n.insArrowKeysDesc),
              _Row(l10n.insWasd, l10n.insWasdDesc),
              _Row(l10n.insSpacebar, l10n.insSpacebarDesc),
              const SizedBox(height: 12),
              _Footnote(l10n.insControlsNote),
            ]),
            // Versus. Factual about Quick Match — it finds you an opponent —
            // because promising a person is a promise the matchmaker does
            // not make.
            _section(context, l10n.insVersus, [
              _Row(l10n.insVersusOnline, l10n.insVersusOnlineDesc),
              _Row(l10n.insVersusQuick, l10n.insVersusQuickDesc),
              _Row(l10n.insVersusRoom, l10n.insVersusRoomDesc),
            ]),
            _section(context, l10n.insFoodTypes, [
              _FoodRow(l10n.insNormalFood, l10n.insPoints10, context.lb.food),
              _FoodRow(l10n.insBonusFood, l10n.insPoints25, _bonusFood),
              _FoodRow(l10n.insSpecialFood, l10n.insPoints50, LB.gold),
            ]),
            _section(context, l10n.insRules, [
              for (final rule in [
                l10n.insRule1,
                l10n.insRule2,
                l10n.insRule3,
                l10n.insRule4,
                l10n.insRule5,
              ])
                _Bullet(rule, color: context.lb.inkDim),
            ]),
            _section(context, l10n.insProTips, [
              for (final tip in [l10n.insTip1, l10n.insTip2, l10n.insTip3, l10n.insTip4])
                _Bullet(tip, color: context.lb.lime),
            ]),
          ],
        ),
      ),
    );
  }

  /// The bonus food's colour on the board. Not a theme colour: it is the
  /// food itself, the same on every theme.
  static const Color _bonusFood = Color(0xFFFF9800);

  /// One reference section: a label, then an outline block of rows.
  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Padding(
      padding: EdgeInsets.only(top: context.lbCell * .9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: LBSectionLabel(title),
          ),
          LBBlock(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            // stretch, not the default centre: a bare Text shrink-wraps,
            // which is how a caption ends up centred under a table.
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ],
      ),
    );
  }
}

/// The one sentence that has to land, deliberately not in a block: it is
/// the answer to "what am I doing", not another row of documentation.
class _Objective extends StatelessWidget {
  const _Objective({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: LBSectionLabel(l10n.insObjective),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            l10n.insObjectiveBody,
            style: LBText.body(p, color: p.ink, size: 14).copyWith(height: 1.5, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// A quiet heading inside a block, for the two halves of the controls table.
class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(label.toUpperCase(), style: LBText.label(context.lb, color: context.lb.lime)),
      );
}

/// One line of reference: the thing, and what it does. Two flexible
/// columns, both of which wrap.
class _Row extends StatelessWidget {
  const _Row(this.label, this.description);

  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: LBText.body(p, color: p.ink, size: 12.5).copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(description, textAlign: TextAlign.end, style: LBText.body(p, size: 11.5)),
          ),
        ],
      ),
    );
  }
}

/// A food type: its colour as a board cell, its name, and its worth.
class _FoodRow extends StatelessWidget {
  const _FoodRow(this.name, this.points, this.color);

  final String name;
  final String points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(LB.snakeCellRadius),
                boxShadow: [BoxShadow(color: color.withValues(alpha: .5), blurRadius: 6)],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 4,
            child: Text(
              name,
              style: LBText.body(p, color: p.ink, size: 12.5).copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Text(
              points,
              textAlign: TextAlign.end,
              style: LBText.button(p, color: p.lime, size: 11.5).copyWith(letterSpacing: .4),
            ),
          ),
        ],
      ),
    );
  }
}

/// A hanging bullet (a single lit cell), so a wrapped line aligns with the
/// text above it rather than sliding back under the marker. The marker is
/// never part of the translated string.
class _Bullet extends StatelessWidget {
  const _Bullet(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1.5)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 12.5)),
          ),
        ],
      ),
    );
  }
}

class _Footnote extends StatelessWidget {
  const _Footnote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: LBText.body(context.lb, color: context.lb.inkDim, size: 11));
}
