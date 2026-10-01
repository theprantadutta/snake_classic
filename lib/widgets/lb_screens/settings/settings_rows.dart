import 'package:flutter/material.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// Building blocks of the Living Board Settings screen (screen 16). Only the
/// Settings screen uses these; they live here so the screen file stays about
/// behaviour, not layout.

/// Minimum row height: 2.5 cells, which keeps every row at or above the
/// 48 dp hit target while reading as the two-cell rows in the mock.
double settingsRowHeight(BuildContext context) => context.lbCell * 2.5;

/// Title + optional one-liner on the left, used by every row kind.
class _RowText extends StatelessWidget {
  const _RowText({required this.title, this.subtitle, this.color});

  final String title;
  final String? subtitle;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: LBText.button(p, color: color ?? p.head, size: 13).copyWith(letterSpacing: 1.8),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(subtitle!, style: LBText.body(p, size: 11).copyWith(height: 1.3)),
        ],
      ],
    );
  }
}

/// `MODE ………… CLASSIC ›` — a row that shows a value and opens somewhere.
/// With [onTap] null it renders muted (e.g. locked while a run is live).
class SettingsValueRow extends StatelessWidget {
  const SettingsValueRow({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.leading,
    this.kind,
    this.chevron = true,
  });

  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final Widget? leading;
  final LBBlockKind? kind;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final enabled = onTap != null;
    final k = kind ?? (enabled ? LBBlockKind.outline : LBBlockKind.muted);
    final fg = LBBlock.foregroundOf(k, p);
    final valueColor = switch (k) {
      LBBlockKind.outline => p.lime,
      _ => fg,
    };
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: settingsRowHeight(context)),
      child: LBBlock(
        kind: k,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 14)],
            Expanded(
              child: _RowText(
                title: title,
                subtitle: subtitle,
                color: k == LBBlockKind.outline ? p.head : fg,
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  value!.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: LBText.button(p, color: valueColor, size: 13).copyWith(letterSpacing: 1.6),
                ),
              ),
            ],
            if (chevron && enabled) ...[
              const SizedBox(width: 10),
              LBPixelIcon(LBIcon.next, cell: 2.4, color: valueColor),
            ],
          ],
        ),
      ),
    );
  }
}

/// `SOUND FX  crunchy, as intended  [ ][■]` — a row with an [LBToggle].
/// The whole row toggles. [onChanged] null greys it out (hardware that
/// cannot honour the setting).
class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final enabled = onChanged != null;
    return MergeSemantics(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: settingsRowHeight(context)),
        child: LBBlock(
          kind: enabled ? LBBlockKind.outline : LBBlockKind.muted,
          onTap: enabled ? () => onChanged!(!value) : null,
          padding: const EdgeInsets.fromLTRB(16, 0, 14, 0),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: _RowText(
                    title: title,
                    subtitle: subtitle,
                    color: enabled ? p.head : p.inkDim,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Taps on the row already flip the value; the toggle is the
              // read-out, so it does not take its own gesture.
              IgnorePointer(
                child: LBToggle(value: value, onChanged: enabled ? (_) {} : null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row of equal-width choice blocks for short option sets (crash replay
/// durations, d-pad position, languages in a sheet). Selected = lime fill.
class SettingsOptionStrip<T> extends StatelessWidget {
  const SettingsOptionStrip({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelect,
    this.height,
  });

  final List<T> options;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelect;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return Row(
      children: [
        for (final o in options)
          Expanded(
            child: Semantics(
              selected: o == selected,
              child: LBBlock(
                kind: o == selected ? LBBlockKind.fill : LBBlockKind.outline,
                height: height ?? context.lbCell * 2.5,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                onTap: () => onSelect(o),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    labelOf(o).toUpperCase(),
                    maxLines: 1,
                    style: LBText.button(
                      p,
                      color: LBBlock.foregroundOf(
                        o == selected ? LBBlockKind.fill : LBBlockKind.outline,
                        p,
                      ),
                      size: 12,
                    ).copyWith(letterSpacing: 1.2),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A one-option-per-line picker for sheets (languages, tutorials): each
/// option is a full-width block, the selected one lime-filled.
class SettingsSheetOption extends StatelessWidget {
  const SettingsSheetOption({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.selected = false,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final kind = selected ? LBBlockKind.fill : LBBlockKind.outline;
    final fg = LBBlock.foregroundOf(kind, p);
    return Semantics(
      selected: selected,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: settingsRowHeight(context)),
        child: LBBlock(
          kind: kind,
          onTap: onTap,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Not uppercased: endonyms (Español, हिन्दी) read wrong
                    // in caps and some scripts have none.
                    Text(title, style: LBText.button(p, color: fg, size: 13).copyWith(letterSpacing: .4)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(subtitle!, style: LBText.body(p, color: fg.withValues(alpha: .7), size: 11)),
                    ],
                  ],
                ),
              ),
              if (selected) LBPixelIcon(LBIcon.check, cell: 3, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}

/// An inline advisory under a control: the platform is overriding it, or
/// there is nothing to override.
class SettingsNote extends StatelessWidget {
  const SettingsNote({super.key, required this.text, this.icon = LBIcon.eye});

  final String text;
  final LBIcon icon;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return LBBlock(
      kind: LBBlockKind.muted,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: LBPixelIcon(icon, cell: 2.6, color: p.lime),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 11.5))),
        ],
      ),
    );
  }
}

/// A short paragraph under a group of rows.
class SettingsCaption extends StatelessWidget {
  const SettingsCaption(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 6, 4, 2),
        child: Text(text, style: LBText.body(context.lb, color: context.lb.inkDim, size: 11)),
      );
}

/// Section label with the screen's vertical rhythm: a gap above, the label,
/// then the rows.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.label,
    required this.children,
    this.aside,
    this.topGap,
  });

  final String label;
  final String? aside;
  final List<Widget> children;

  /// Space above the label; defaults to 0.8 cell.
  final double? topGap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(top: topGap ?? context.lbCell * .8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2, right: 2, bottom: 4),
              child: LBSectionLabel(label, trailing: aside),
            ),
            ...children,
          ],
        ),
      );
}

/// `REPLAY TUTORIAL · PRIVACY · v7.0.0` under the last section.
class SettingsFooterLinks extends StatelessWidget {
  const SettingsFooterLinks({
    super.key,
    required this.links,
    this.version,
  });

  /// (label, onTap) pairs.
  final List<(String, VoidCallback)> links;
  final String? version;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final style = LBText.label(p, color: p.inkDim).copyWith(fontSize: 10);
    final dot = Text('  ·  ', style: style);
    final items = <Widget>[];
    for (final (label, onTap) in links) {
      if (items.isNotEmpty) items.add(dot);
      items.add(Semantics(
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            LBFeedback.tap();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
            child: Text(label.toUpperCase(), style: style.copyWith(color: p.inkMuted)),
          ),
        ),
      ));
    }
    if (version != null) {
      if (items.isNotEmpty) items.add(dot);
      items.add(Text(version!, style: style));
    }
    return Padding(
      padding: EdgeInsets.only(top: context.lbCell * .8),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: items,
      ),
    );
  }
}
