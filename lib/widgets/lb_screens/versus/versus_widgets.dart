import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// Living Board pieces for the Versus screens (renders 17–20). Specific to
/// `multiplayer_lobby_screen.dart` and `multiplayer_game_screen.dart`; the
/// generic building blocks stay in `lib/widgets/lb/`.

/// Three cells lighting one after another: the Living Board's "working on
/// it" indicator, used where a spinner used to sit.
class VersusBusyCells extends StatefulWidget {
  const VersusBusyCells({super.key, this.count = 3, this.cell = 6, this.color});

  final int count;
  final double cell;
  final Color? color;

  @override
  State<VersusBusyCells> createState() => _VersusBusyCellsState();
}

class _VersusBusyCellsState extends State<VersusBusyCells> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final color = widget.color ?? p.lime;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final lit = (_c.value * widget.count).floor() % widget.count;
          return LBCellsBar(
            count: widget.count,
            value: 1,
            cell: widget.cell,
            colorAt: (i) => i == lit ? color : color.withValues(alpha: .25),
          );
        },
      ),
    );
  }
}

/// Four small cells in a row: a player's colour swatch (lime = you,
/// red = rival) in the room rows and the match header.
class VersusPlayerCells extends StatelessWidget {
  const VersusPlayerCells({super.key, required this.color, this.cell = 7, this.dim = false});

  final Color color;
  final double cell;

  /// Crashed / disconnected: the swatch fades.
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final c = dim ? color.withValues(alpha: .3) : color;
    return ExcludeSemantics(
      child: LBCellsBar(
        count: 4,
        value: 1,
        cell: cell,
        // The head cell is a touch brighter, like a snake heading right.
        colorAt: (i) => i == 3 ? Color.lerp(c, Colors.white, .25)! : c,
      ),
    );
  }
}

/// The gold `VS` tag between the two player rows.
class VersusVsChip extends StatelessWidget {
  const VersusVsChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: LB.gold,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [BoxShadow(color: LB.gold.withValues(alpha: .35), blurRadius: 10)],
      ),
      child: Text(
        label,
        style: LBText.button(context.lb, color: const Color(0xFF1E1600), size: 12)
            .copyWith(letterSpacing: 2),
      ),
    );
  }
}

/// A quiet uppercase text action (`LEAVE ROOM`), with a 48 dp hit target.
class VersusTextLink extends StatelessWidget {
  const VersusTextLink({super.key, required this.label, required this.onTap, this.color});

  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return Semantics(
      button: true,
      child: InkResponse(
        onTap: () {
          LBFeedback.back();
          onTap();
        },
        highlightShape: BoxShape.rectangle,
        radius: 120,
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              label.toUpperCase(),
              style: LBText.button(p, color: color ?? p.inkMuted, size: 12.5)
                  .copyWith(letterSpacing: 3),
            ),
          ),
        ),
      ),
    );
  }
}

/// One tile of the lifetime record strip. [value] null = still loading:
/// the tile keeps its shape and breathes a placeholder, so nothing below it
/// moves when the fetch lands.
class VersusRecordTile extends StatelessWidget {
  const VersusRecordTile({super.key, required this.label, required this.value, this.color});

  final String label;
  final String? value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return LBBlock(
      height: context.lbCell * 3.6,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      alignment: Alignment.center,
      semanticLabel: value == null ? label : '$label $value',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label.toUpperCase(), maxLines: 1, style: LBText.label(p)),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 28,
              child: Center(
                child: value == null
                    ? Container(
                        width: 30,
                        height: 16,
                        decoration: BoxDecoration(
                          color: p.cellOff,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .fade(begin: .45, end: 1, duration: 700.ms)
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          value!,
                          maxLines: 1,
                          style: LBText.value(p, color: color ?? p.ink, size: 22),
                        ),
                      ).animate().fadeIn(duration: 220.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Room code drawn as letter cells (render 18). Pure display.
class VersusCodeCells extends StatelessWidget {
  const VersusCodeCells({super.key, required this.code, this.length = 6, this.cellHeight});

  final String code;
  final int length;
  final double? cellHeight;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final h = cellHeight ?? context.lbCell * 2.5;
    final chars = code.toUpperCase().characters.toList();
    final n = chars.length > length ? chars.length : length;
    return Semantics(
      label: code,
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < n; i++)
            Flexible(
              child: LBBlock(
                width: h * .66,
                height: h,
                padding: EdgeInsets.zero,
                alignment: Alignment.center,
                child: Text(
                  i < chars.length ? chars[i] : '',
                  style: LBText.value(p, color: p.lime, size: h * .42),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// `GOT A CODE?` input (render 17): six letter cells over an invisible
/// text field, and a go block at the end. Tapping a cell opens the keyboard;
/// the field owns the text, so paste, IME and accessibility all still work.
class VersusCodeInput extends StatefulWidget {
  const VersusCodeInput({
    super.key,
    required this.controller,
    required this.onGo,
    required this.hint,
    required this.goLabel,
    this.length = 6,
  });

  final TextEditingController controller;

  /// Null = the go block is disabled (empty code, or a request in flight).
  final VoidCallback? onGo;
  final String hint;
  final String goLabel;
  final int length;

  @override
  State<VersusCodeInput> createState() => _VersusCodeInputState();
}

class _VersusCodeInputState extends State<VersusCodeInput> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_rebuild);
    widget.controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(VersusCodeInput old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_rebuild);
      widget.controller.addListener(_rebuild);
    }
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final text = widget.controller.text.toUpperCase();
    final h = context.lbCell * 2.5;
    final focused = _focus.hasFocus;
    return SizedBox(
      height: h,
      child: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                // The real input. Invisible, but focusable and announced.
                Positioned.fill(
                  child: Opacity(
                    opacity: 0,
                    alwaysIncludeSemantics: true,
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focus,
                      showCursor: false,
                      autocorrect: false,
                      enableSuggestions: false,
                      textCapitalization: TextCapitalization.characters,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.go,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                        LengthLimitingTextInputFormatter(widget.length),
                      ],
                      onSubmitted: (_) => widget.onGo?.call(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: widget.hint,
                        counterText: '',
                      ),
                    ),
                  ),
                ),
                ExcludeSemantics(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (_focus.hasFocus) {
                        SystemChannels.textInput.invokeMethod<void>('TextInput.show');
                      } else {
                        _focus.requestFocus();
                      }
                    },
                    child: Row(
                      children: [
                        for (var i = 0; i < widget.length; i++)
                          Expanded(
                            child: LBBlock(
                              height: h - LB.inset * 2,
                              padding: EdgeInsets.zero,
                              alignment: Alignment.center,
                              selected: focused && i == text.length.clamp(0, widget.length - 1),
                              child: Text(
                                i < text.length ? text[i] : '',
                                style: LBText.value(p, color: p.lime, size: 20),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: h * .9,
            child: LBBlock(
              kind: widget.onGo == null ? LBBlockKind.muted : LBBlockKind.fill,
              height: h - LB.inset * 2,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              semanticLabel: widget.goLabel,
              onTap: widget.onGo,
              child: LBPixelIcon(
                LBIcon.next,
                cell: 3.4,
                color: widget.onGo == null ? p.inkDim : p.onLime,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One player in the room (render 18): colour cells, name, `YOU` tag and a
/// status line. A ready rival goes gold, as the mock shows.
class VersusPlayerRow extends StatelessWidget {
  const VersusPlayerRow({
    super.key,
    required this.name,
    required this.status,
    required this.isYou,
    required this.youLabel,
    required this.ready,
    required this.height,
    this.dim = false,
  });

  final String name;
  final String status;
  final bool isYou;
  final String youLabel;
  final bool ready;
  final double height;

  /// Crashed / disconnected.
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final swatch = isYou ? p.lime : LB.rival;
    final kind = ready && !isYou ? LBBlockKind.gold : LBBlockKind.outline;
    final statusColor = ready ? (isYou ? p.lime : LB.gold) : p.inkMuted;
    return LBBlock(
      kind: kind,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          VersusPlayerCells(color: swatch, dim: dim),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LBText.button(p, color: dim ? p.inkDim : p.ink, size: 14)
                            .copyWith(letterSpacing: .6),
                      ),
                    ),
                    if (isYou) ...[
                      const SizedBox(width: 8),
                      Text(youLabel, style: LBText.label(p, color: p.lime).copyWith(fontSize: 10)),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LBText.body(p, color: statusColor, size: 11.5)
                      .copyWith(fontWeight: ready ? FontWeight.w700 : FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          LBPixelIcon(
            ready ? LBIcon.check : LBIcon.hourglass,
            cell: 2.6,
            color: ready ? (isYou ? p.lime : LB.gold) : p.inkDim,
          ),
        ],
      ),
    );
  }
}

/// The empty second slot of a room.
class VersusEmptySlot extends StatelessWidget {
  const VersusEmptySlot({super.key, required this.label, required this.height});

  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return LBBlock(
      kind: LBBlockKind.dashed,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          VersusPlayerCells(color: p.inkDim, dim: true),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LBText.body(p, color: p.inkDim, size: 12),
            ),
          ),
          const VersusBusyCells(cell: 5),
        ],
      ),
    );
  }
}

/// `READY CHECK ▮▮▮▮▯▯ 24s` (render 18). The cells and the number turn gold
/// in the last ten seconds; the number is always there, so colour is never
/// the only signal.
class VersusReadyCheck extends StatelessWidget {
  const VersusReadyCheck({
    super.key,
    required this.label,
    required this.seconds,
    required this.total,
    required this.secondsLabel,
    required this.semanticLabel,
  });

  final String label;
  final int seconds;
  final int total;
  final String secondsLabel;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final urgent = seconds <= 10;
    final color = urgent ? LB.gold : p.lime;
    return LBBlock(
      kind: LBBlockKind.dashed,
      height: context.lbCell * 2.5,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      semanticLabel: semanticLabel,
      child: ExcludeSemantics(
        child: Row(
          children: [
            LBPixelIcon(LBIcon.hourglass, cell: 2.6, color: color),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LBText.button(p, color: color, size: 11.5).copyWith(letterSpacing: 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 130),
                  child: LBCellsBar(
                    count: 12,
                    value: total <= 0 ? 0 : seconds / total,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 34,
              child: Text(
                secondsLabel,
                textAlign: TextAlign.end,
                style: LBText.button(p, color: urgent ? LB.gold : p.ink, size: 13)
                    .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A one-line status note in the room (waiting on the opponent / host).
class VersusStatusNote extends StatelessWidget {
  const VersusStatusNote({super.key, required this.text, this.busy = true});

  final String text;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return LBBlock(
      kind: LBBlockKind.muted,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Semantics(
        liveRegion: true,
        child: Row(
          children: [
            if (busy) ...[const VersusBusyCells(cell: 5), const SizedBox(width: 12)],
            Expanded(
              child: Text(text, style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

/// The pre-match countdown scrim (`3 · 2 · 1 · GO!`) as big cell digits.
class VersusCountdownOverlay extends StatelessWidget {
  const VersusCountdownOverlay({
    super.key,
    required this.seconds,
    required this.goLabel,
    required this.getReadyLabel,
  });

  final int seconds;
  final String goLabel;
  final String getReadyLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    // Seconds come from the GameStarting payload so a server-side tuning
    // change can't drift from this animation.
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: seconds, end: 0),
      duration: Duration(seconds: seconds),
      builder: (context, value, child) {
        final text = value > 0 ? '$value' : goLabel;
        return ColoredBox(
          color: p.board.withValues(alpha: .92),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Semantics(
                    key: ValueKey<int>(value),
                    liveRegion: true,
                    child: LBCellText(
                      text,
                      cell: (value > 0 ? 24 : 16) * context.uiScale,
                      color: value > 0 ? p.head : p.lime,
                      glow: true,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  value > 0 ? getReadyLabel.toUpperCase() : '',
                  style: LBText.button(p, color: p.inkMuted, size: 14).copyWith(letterSpacing: 3),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
