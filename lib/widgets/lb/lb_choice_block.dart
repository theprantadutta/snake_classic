import 'package:flutter/material.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/widgets/lb/lb_block.dart';
import 'package:snake_classic/widgets/lb/lb_grid_background.dart';

/// A selectable block: uppercase title + one-liner. Selected = lime fill.
class LBChoiceBlock extends StatelessWidget {
  const LBChoiceBlock({
    super.key,
    required this.title,
    required this.line,
    required this.selected,
    required this.onTap,
    this.centered = false,
  });

  final String title;
  final String line;
  final bool selected;
  final VoidCallback onTap;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final kind = selected ? LBBlockKind.fill : LBBlockKind.outline;
    final fg = LBBlock.foregroundOf(kind, p);
    return Semantics(
      selected: selected,
      child: LBBlock(
        kind: kind,
        height: context.lbCell * 3.5,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: centered ? Alignment.center : AlignmentDirectional.centerStart,
              child: Text(
                title.toUpperCase(),
                maxLines: 1,
                style: LBText.button(p, color: fg, size: 13).copyWith(letterSpacing: 1.8),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              line,
              maxLines: 2,
              textAlign: centered ? TextAlign.center : TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: LBText.body(p, color: fg.withValues(alpha: selected ? .75 : .6), size: 10.5)
                  .copyWith(height: 1.25),
            ),
          ],
        ),
      ),
    );
  }
}

