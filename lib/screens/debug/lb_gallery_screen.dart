import 'package:flutter/material.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// Debug-only page showing every Living Board component, for checking the
/// system on a device without walking through the app. Not reachable in
/// release builds (the route is registered behind kDebugMode).
class LBGalleryScreen extends StatefulWidget {
  const LBGalleryScreen({super.key});

  @override
  State<LBGalleryScreen> createState() => _LBGalleryScreenState();
}

class _LBGalleryScreenState extends State<LBGalleryScreen> {
  bool _toggle = true;
  int _score = 1403;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final g = context.lbGutter;
    return Scaffold(
      body: LBGridBackground(
        child: SafeArea(
          child: ListView(
            children: [
              const LBHeader(title: 'GALLERY', subtitle: 'Every Living Board component.'),
              Padding(
                padding: EdgeInsets.fromLTRB(g, 20, g, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const LBSectionLabel('Cell text', trailing: 'cell 6 · 7 · 20'),
                    const LBCellText('SNAKE', cell: 6, glow: true),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(() => _score += 9),
                      child: LBAnimatedCellText('$_score', cell: 20, color: LB.gold.withValues(alpha: .35)),
                    ),
                    const SizedBox(height: 8),
                    LBCellText('0123456789', cell: 5, offColor: p.cellOff),
                    const SizedBox(height: 8),
                    const LBCellText('ABCDEFGHIJKLMNOPQRSTUVWXYZ!?:+%×#', cell: 3),
                    const SizedBox(height: 8),
                    const LBCellText('ИГРАТЬ', cell: 6),
                    const SizedBox(height: 20),
                    const LBSectionLabel('Pixel icons', trailing: '36'),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final i in LBIcon.values)
                          LBPixelIcon(i, cell: 4, accent: LB.apple, semanticLabel: i.name),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const LBSectionLabel('Blocks'),
                    for (final k in LBBlockKind.values)
                      LBBlock(
                        kind: k,
                        height: 58,
                        onTap: () {},
                        child: Row(
                          children: [
                            const LBPixelIcon(LBIcon.star, cell: 4),
                            const SizedBox(width: 12),
                            Text(k.name.toUpperCase(), style: LBText.button(p, color: LBBlock.foregroundOf(k, p))),
                          ],
                        ),
                      ),
                    LBBlock(
                      kind: LBBlockKind.fill,
                      height: 98,
                      onTap: () {},
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LBCellText('PLAY', cell: 7, color: p.onLime),
                          const SizedBox(height: 8),
                          Text('CLASSIC · 20×20', style: LBText.label(p, color: p.onLime)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const LBSectionLabel('Cells bar · toggle · chips'),
                    const LBCellsBar(count: 18, value: .66),
                    const SizedBox(height: 8),
                    LBCellsBar(count: 5, value: .8, cell: 14, color: LB.gold, offColor: LB.gold.withValues(alpha: .15)),
                    Row(
                      children: [
                        LBToggle(value: _toggle, onChanged: (v) => setState(() => _toggle = v)),
                        const SizedBox(width: 16),
                        const LBToggle(value: false, onChanged: null),
                      ],
                    ),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        LBChip(label: '×3 HOT · KEEP EATING', kind: LBChipKind.gold, icon: LBIcon.flame),
                        LBChip(label: 'SLOW-MO · 4s', icon: LBIcon.hourglass),
                        LBChip(label: 'EAT SOMETHING. NOW.', kind: LBChipKind.danger),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const LBSectionLabel('Logo'),
                    const Row(
                      children: [
                        LBCellSMark(size: 120),
                        SizedBox(width: 16),
                        LBCellSMark(size: 46),
                      ],
                    ),
                  ],
                ),
              ),
              const LBBannerSlot(),
            ],
          ),
        ),
      ),
    );
  }
}
