import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/presentation/bloc/display/display_cubit.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// `59.94` and `120` should both read like a refresh rate, not like a
/// float — panels report awkward real numbers and `120.0 Hz` looks broken.
String settingsFormatHz(double hz) => hz % 1 == 0 ? '${hz.toInt()}' : hz.toStringAsFixed(1);

/// The DISPLAY section body: what the panel is refreshing at right now, the
/// explanation of the 120 Hz opt-in, and every mode the panel offers.
/// Pure read-out of [DisplayState]; the toggle itself sits in SOUND & FEEL.
class SettingsDisplayPanel extends StatelessWidget {
  const SettingsDisplayPanel({super.key, required this.display});

  final DisplayState display;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final info = display.info;
    final current = info == null ? '—' : settingsFormatHz(info.currentRate);
    final rates = info == null ? const <double>[] : ([...info.supportedRates]..sort());

    return LBBlock(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Lime only when the number is the result of our own request —
              // otherwise it is the platform default and colouring it would
              // take credit for nothing.
              Text(
                current,
                style: LBText.value(p, color: display.isLive ? p.lime : p.ink, size: 34)
                    .copyWith(height: 1),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 3),
                child: Text(l10n.settingsDisplayHz, style: LBText.button(p, color: p.inkMuted, size: 13)),
              ),
              const Spacer(),
              if (info != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    l10n.settingsDisplayUpTo(settingsFormatHz(info.maxRate)),
                    style: LBText.body(p, size: 11),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            info == null ? l10n.settingsDisplayReading : l10n.settingsDisplayCurrentCaption,
            style: LBText.body(p, size: 11),
          ),
          const SizedBox(height: 12),
          Text(l10n.settingsDisplayFooter, style: LBText.body(p, color: p.inkDim, size: 11)),
          // Only worth showing when there is more than one mode — a lone chip
          // is just the number above it again.
          if (rates.length > 1) ...[
            const SizedBox(height: 14),
            Text(l10n.settingsDisplaySupportedTitle.toUpperCase(), style: LBText.label(p)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final rate in rates)
                  // Panels report near-misses (59.94 vs 60), so match on
                  // proximity rather than equality or nothing highlights.
                  (rate - info!.currentRate).abs() < 0.5
                      ? LBChip(
                          label: '${settingsFormatHz(rate)} ${l10n.settingsDisplayHz}',
                          icon: LBIcon.check,
                        )
                      : Opacity(
                          opacity: .55,
                          child: LBChip(label: '${settingsFormatHz(rate)} ${l10n.settingsDisplayHz}'),
                        ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
