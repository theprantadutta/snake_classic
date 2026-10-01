import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// Full-screen viewer for a bundled legal document (Privacy Policy or Terms of
/// Use). Loads the markdown asset and renders it scrollable. Used from the
/// Settings screen and the first-run legal notice so both documents are
/// reachable in-app.
class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.assetPath,
    required this.icon,
    this.fallbackUrl,
  });

  final String title;
  final String assetPath;

  /// Kept for callers; the Living Board header carries no icon, so it is
  /// not drawn.
  final IconData icon;

  /// Shown as a hint if the bundled asset can't be loaded.
  final String? fallbackUrl;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> with SingleTickerProviderStateMixin {
  String _content = '';

  // Set when the bundled asset can't be loaded — the localized fallback
  // message is resolved at render time (no context/l10n in the async load).
  bool _loadFailed = false;

  /// Sweeps the loading cells while the asset is read.
  late final AnimationController _loading = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _loading.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final content = await rootBundle.loadString(widget.assetPath);
      if (mounted) setState(() => _content = content);
    } catch (_) {
      if (mounted) {
        setState(() => _loadFailed = true);
      }
    }
    _loading.stop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final l10n = AppLocalizations.of(context)!;
    final g = context.lbGutter;
    final content = _loadFailed
        ? (widget.fallbackUrl != null ? l10n.lgAvailableAt(widget.fallbackUrl!) : l10n.lgUnavailable)
        : _content;

    return LBScaffold(
      title: widget.title,
      // The documents never carried a banner; a legal text is not an ad slot.
      banner: false,
      body: Padding(
        padding: EdgeInsets.fromLTRB(g, context.lbCell * .9, g, context.lbCell * .5),
        child: LBBlock(
          padding: EdgeInsets.zero,
          child: content.isEmpty
              ? Center(
                  child: ExcludeSemantics(
                    child: SizedBox(
                      width: 60,
                      child: AnimatedBuilder(
                        animation: _loading,
                        builder: (context, _) => LBCellsBar(
                          count: 5,
                          value: (_loading.value * 6).floor() / 5,
                          cell: 12,
                        ),
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    content,
                    style: LBText.body(p, color: p.ink.withValues(alpha: .88), size: 12.5).copyWith(height: 1.5),
                  ),
                ),
        ),
      ),
    );
  }
}
