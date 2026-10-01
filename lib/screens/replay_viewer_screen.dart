import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/game_replay.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/profile/lb_profile_parts.dart';

class ReplayViewerScreen extends StatefulWidget {
  /// The replay ID for deep link support.
  final String replayId;

  /// Optional replay object (for instant display when navigating with object).
  final GameReplay? replay;

  const ReplayViewerScreen({
    super.key,
    required this.replayId,
    this.replay,
  });

  @override
  State<ReplayViewerScreen> createState() => _ReplayViewerScreenState();
}

class _ReplayViewerScreenState extends State<ReplayViewerScreen> {
  final StorageService _storageService = StorageService();

  static const List<double> _speeds = [0.25, 0.5, 1.0, 2.0, 4.0];

  GameReplay? _replay;
  int _currentFrameIndex = 0;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  Timer? _playbackTimer;
  bool _isLoadingReplay = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _replay = widget.replay;

    if (_replay == null) {
      // Deep link: need to load replay from storage
      _loadReplayFromId();
    }
  }

  Future<void> _loadReplayFromId() async {
    setState(() {
      _isLoadingReplay = true;
      _loadError = null;
    });

    try {
      final replayJson = await _storageService.getReplay(widget.replayId);
      if (mounted) {
        if (replayJson != null) {
          final data = json.decode(replayJson) as Map<String, dynamic>;
          setState(() {
            _replay = GameReplay.fromJson(data);
            _isLoadingReplay = false;
          });
        } else {
          setState(() {
            // Stable error codes — resolved to localized text at render time.
            _loadError = 'not_found';
            _isLoadingReplay = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = 'load_failed';
          _isLoadingReplay = false;
        });
      }
    }
  }

  String _loadErrorText(AppLocalizations l10n) {
    switch (_loadError) {
      case 'load_failed':
        return l10n.rvLoadFailed;
      case 'not_found':
      default:
        return l10n.rvNotFound;
    }
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  GameFrame? get _currentFrame {
    final replay = _replay;
    if (replay == null) return null;
    return replay.frames.isNotEmpty && _currentFrameIndex < replay.frames.length
        ? replay.frames[_currentFrameIndex]
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final replay = _replay;
    return LBScaffold(
      title: l10n.lbReplayTitle,
      subtitle: replay != null
          ? '${replay.playerName} · ${context.formatDate(replay.createdAt)}'
          : l10n.rvLoadingTitle,
      onBack: () => Navigator.pop(context),
      body: _buildContent(l10n),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    final g = context.lbGutter;
    final cell = context.lbCell;

    // Show loading state when fetching replay from deep link
    if (_isLoadingReplay) return LBLoadingCells(label: l10n.rvLoading);

    // Show error state
    if (_loadError != null || _replay == null) {
      return LBCenteredScroll(
        child: LBEmptyBlock(
          icon: LBIcon.x,
          title: _loadErrorText(l10n),
          action: LBBlock(
            height: cell * 2.4,
            alignment: Alignment.center,
            onTap: () => Navigator.of(context).pop(),
            child: Text(l10n.rvGoBack.toUpperCase(), style: LBText.button(context.lb, size: 12.5)),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(g, cell * .9, g, cell * .6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGameInfo(l10n),
          SizedBox(height: cell * .4),
          Expanded(child: Center(child: _buildGameBoard(l10n))),
          SizedBox(height: cell * .4),
          _buildPlaybackControls(l10n),
        ],
      ),
    );
  }

  Widget _buildGameInfo(AppLocalizations l10n) {
    final p = context.lb;
    final replay = _replay!;
    final frame = _currentFrame;

    Widget info(String label, String value, {Color? color}) => Expanded(
          child: Semantics(
            label: '$label $value',
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), maxLines: 1, style: LBText.label(p).copyWith(fontSize: 8.5)),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(value, style: LBText.value(p, color: color, size: 15)),
                ),
              ],
            ),
          ),
        );

    // Resolve the caption BEFORE deciding to render: a frame can carry a
    // gameEvent that _formatGameEvent cannot describe (an unknown or
    // malformed type from an older recording), and an empty chip is worse
    // than no chip.
    final event = frame?.gameEvent == null ? '' : _formatGameEvent(frame!.gameEvent!);

    return LBBlock(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              info(l10n.rvScore, context.formatInt(frame?.score ?? 0), color: LB.gold),
              info(l10n.rvLevel, context.formatInt(frame?.level ?? 1)),
              info(
                l10n.rvFrame,
                '${context.formatInt(_currentFrameIndex + 1)}/${context.formatInt(replay.totalFrames)}',
              ),
              info(l10n.rvTime, lbDuration(l10n, replay.gameTimeSeconds)),
            ],
          ),
          // Reserve a fixed slot for the event chip so the block doesn't
          // grow/shrink each time a frame has (or stops having) a gameEvent.
          const SizedBox(height: 8),
          SizedBox(
            height: 24,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                child: event.isNotEmpty
                    ? Semantics(
                        key: ValueKey('event-${frame!.frameNumber}'),
                        liveRegion: true,
                        child: LBChip(label: event, kind: LBChipKind.gold),
                      )
                    : const SizedBox.shrink(key: ValueKey('event-empty')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard(AppLocalizations l10n) {
    final p = context.lb;
    final frame = _currentFrame;
    final settings = _replay!.gameSettings;
    // Recordings carry their board size; older ones (and malformed rows)
    // fall back to the classic 20×20 the viewer always assumed.
    final cols = (settings['boardWidth'] as num?)?.toInt() ?? 20;
    final rows = (settings['boardHeight'] as num?)?.toInt() ?? 20;
    final boardW = cols > 0 ? cols : 20;
    final boardH = rows > 0 ? rows : 20;

    // Size the board to the available area so it scales up on tablets —
    // mirroring the main game board's min(w,h) approach.
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = math.min(constraints.maxWidth / boardW, constraints.maxHeight / boardH);
        final w = cellSize * boardW;
        final h = cellSize * boardH;

        if (frame == null) {
          return SizedBox(
            width: w,
            height: h,
            child: LBBlock(
              kind: LBBlockKind.dashed,
              alignment: Alignment.center,
              child: Text(l10n.rvNoFrameData, style: LBText.body(p, size: 12)),
            ),
          );
        }

        return Semantics(
          image: true,
          label: '${l10n.rvFrame} ${_currentFrameIndex + 1}',
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size(w, h),
              painter: ReplayBoardPainter(
                frame: frame,
                palette: p,
                cellSize: cellSize,
                columns: boardW,
                rows: boardH,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaybackControls(AppLocalizations l10n) {
    final p = context.lb;
    final cell = context.lbCell;
    final replay = _replay!;
    final last = replay.totalFrames - 1;
    final canBack = _currentFrameIndex > 0;
    final canForward = _currentFrameIndex < last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(context.formatInt(_currentFrameIndex + 1), style: LBText.body(p, color: p.ink, size: 11)),
            const SizedBox(width: 10),
            Expanded(
              child: _CellScrubber(
                index: _currentFrameIndex,
                max: math.max(0, last),
                label: l10n.rvFrame,
                onChanged: (value) => setState(() => _currentFrameIndex = value),
              ),
            ),
            const SizedBox(width: 10),
            Text(context.formatInt(replay.totalFrames), style: LBText.body(p, color: p.ink, size: 11)),
          ],
        ),
        SizedBox(height: cell * .4),
        Row(
          children: [
            LBIconBlock(
              icon: LBIcon.back,
              size: cell * 3,
              semanticLabel: l10n.lbReplayPrevFrame,
              color: canBack ? p.lime : p.inkDim,
              kind: canBack ? LBBlockKind.outline : LBBlockKind.muted,
              onTap: canBack ? _previousFrame : null,
            ),
            Expanded(
              child: LBBlock(
                kind: LBBlockKind.fill,
                height: cell * 3 - LB.inset * 2,
                alignment: Alignment.center,
                semanticLabel: _isPlaying ? l10n.lbPause : l10n.lbPlay,
                onTap: _togglePlayback,
                child: ExcludeSemantics(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LBPixelIcon(_isPlaying ? LBIcon.pause : LBIcon.play, cell: 3.4, color: p.onLime),
                      const SizedBox(width: 12),
                      Text(
                        _isPlaying ? l10n.lbPause : l10n.lbPlay,
                        style: LBText.button(p, color: p.onLime, size: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            LBIconBlock(
              icon: LBIcon.next,
              size: cell * 3,
              semanticLabel: l10n.lbReplayNextFrame,
              color: canForward ? p.lime : p.inkDim,
              kind: canForward ? LBBlockKind.outline : LBBlockKind.muted,
              onTap: canForward ? _nextFrame : null,
            ),
          ],
        ),
        SizedBox(height: cell * .3),
        Row(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Text(
                l10n.rvSpeedLabel.trim().replaceAll(RegExp(r'[:：]$'), '').toUpperCase(),
                style: LBText.label(p),
              ),
            ),
            for (final speed in _speeds)
              Expanded(
                child: Semantics(
                  selected: _playbackSpeed == speed,
                  child: LBBlock(
                    selected: _playbackSpeed == speed,
                    height: cell * 2 - LB.inset * 2,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                    onTap: () {
                      setState(() => _playbackSpeed = speed);
                      if (_isPlaying) _startPlayback();
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        l10n.lbSpeedX(_speedText(speed)),
                        style: LBText.button(
                          p,
                          color: _playbackSpeed == speed ? p.head : p.inkMuted,
                          size: 11,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _speedText(double speed) {
    final locale = Localizations.localeOf(context);
    return speed == speed.roundToDouble()
        ? AppFormats.decimal(speed.round(), locale)
        : AppFormats.decimal(speed, locale);
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _pausePlayback();
    } else {
      _startPlayback();
    }
  }

  void _startPlayback() {
    final replay = _replay;
    if (replay == null) return;

    if (_currentFrameIndex >= replay.totalFrames - 1) {
      _currentFrameIndex = 0;
    }

    setState(() {
      _isPlaying = true;
    });

    _playbackTimer?.cancel();
    final interval = (100 / _playbackSpeed).round(); // Base 100ms interval

    _playbackTimer = Timer.periodic(Duration(milliseconds: interval), (_) {
      if (_currentFrameIndex < replay.totalFrames - 1) {
        setState(() {
          _currentFrameIndex++;
        });
      } else {
        _pausePlayback();
      }
    });
  }

  void _pausePlayback() {
    _playbackTimer?.cancel();
    setState(() {
      _isPlaying = false;
    });
  }

  void _previousFrame() {
    if (_currentFrameIndex > 0) {
      setState(() {
        _currentFrameIndex--;
      });
    }
  }

  void _nextFrame() {
    final replay = _replay;
    if (replay == null) return;

    if (_currentFrameIndex < replay.totalFrames - 1) {
      setState(() {
        _currentFrameIndex++;
      });
    }
  }

  /// Builds the caption for a replay frame's game event.
  ///
  /// Every value out of this map is treated as untrusted. The map is decoded
  /// from JSON persisted on the device, so it can be older than the current
  /// build — and replays are phone-only (Drift `replays` table, never synced),
  /// so a bad row sticks around until the user's replay list rolls over rather
  /// than being fixed by a server correction.
  ///
  /// That is not hypothetical: recordings made before the fix in GameCubit
  /// ._recordFrame stored `powerUpType: null` for EVERY power-up pickup, and
  /// the generated l10n methods take a non-nullable `Object`. Passing that null
  /// straight through threw "type 'Null' is not a subtype of type 'Object'"
  /// from inside build(), which is fatal and unrecoverable — the whole screen
  /// crashes the moment the playhead reaches such a frame.
  String _formatGameEvent(Map<String, dynamic> event) {
    final l10n = AppLocalizations.of(context)!;

    // `as String` on a missing key would throw here just as readily.
    final type = event['type'];

    switch (type) {
      case 'food_consumed':
        final foodType = event['foodType'];
        return foodType == null ? l10n.rvAteFoodUnknown : l10n.rvAteFood(foodType);
      case 'power_up_collected':
        final powerUpType = event['powerUpType'];
        return powerUpType == null
            ? l10n.rvCollectedPowerUpUnknown
            : l10n.rvCollectedPowerUp(powerUpType);
      default:
        // Unknown or malformed event: show nothing rather than dumping a raw
        // map over the board. The caller hides the chip on an empty string.
        return '';
    }
  }
}

/// The frame scrubber: a row of cells, lit up to the playhead. Drag or tap
/// to seek; screen readers get slider semantics with ±1 frame steps.
class _CellScrubber extends StatelessWidget {
  const _CellScrubber({
    required this.index,
    required this.max,
    required this.label,
    required this.onChanged,
  });

  final int index;
  final int max;
  final String label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final count = math.max(4, (c.maxWidth / 12).floor());
        void seek(double dx) {
          if (max <= 0) return;
          final v = (dx / c.maxWidth).clamp(0.0, 1.0);
          final next = (v * max).round();
          if (next != index) onChanged(next);
        }

        return Semantics(
          slider: true,
          label: label,
          value: '${index + 1}',
          increasedValue: '${math.min(index + 2, max + 1)}',
          decreasedValue: '${math.max(index, 1)}',
          onIncrease: index < max ? () => onChanged(index + 1) : null,
          onDecrease: index > 0 ? () => onChanged(index - 1) : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => seek(d.localPosition.dx),
            onHorizontalDragUpdate: (d) => seek(d.localPosition.dx),
            child: SizedBox(
              height: 48,
              child: Center(
                child: ExcludeSemantics(
                  child: LBCellsBar(
                    count: count,
                    // +1 so the first frame lights the first cell.
                    value: max <= 0 ? 1 : (index + 1) / (max + 1),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Draws one replay frame on the Living Board: the board tone, its grid,
/// the wall, an apple with a gold glow, a gold power-up cell, and the snake
/// drawn like the home snake (rounded cells, 100% → 45% from head to tail,
/// a glowing head with eyes facing the direction of travel).
class ReplayBoardPainter extends CustomPainter {
  final GameFrame frame;
  final LBPalette palette;
  final double cellSize;
  final int columns;
  final int rows;

  ReplayBoardPainter({
    required this.frame,
    required this.palette,
    required this.cellSize,
    required this.columns,
    required this.rows,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = palette;
    final c = cellSize;
    final board = Offset.zero & Size(columns * c, rows * c);
    final rr = RRect.fromRectAndRadius(board, const Radius.circular(LB.blockRadius));

    // Board + grid.
    canvas.drawRRect(rr, Paint()..color = p.deep);
    canvas.save();
    canvas.clipRRect(rr);
    final grid = Paint()
      ..color = p.gridLine
      ..strokeWidth = 1;
    for (var x = 1; x < columns; x++) {
      canvas.drawLine(Offset(x * c, 0), Offset(x * c, board.height), grid);
    }
    for (var y = 1; y < rows; y++) {
      canvas.drawLine(Offset(0, y * c), Offset(board.width, y * c), grid);
    }
    canvas.restore();
    canvas.drawRRect(
      rr.deflate(.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = p.wall,
    );

    Rect at(List<int> pos) => Rect.fromLTWH(pos[0] * c, pos[1] * c, c, c);
    bool valid(List<int>? pos) => pos != null && pos.length >= 2;

    // Food: apple with a gold glow (DESIGN_SPEC §5).
    final food = frame.foodPosition;
    if (valid(food)) {
      final center = at(food!).center;
      canvas.drawCircle(
        center,
        c * .5,
        Paint()
          ..color = LB.foodGlow
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, c * .35),
      );
      canvas.drawCircle(
        center,
        c * .36,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-.4, -.45),
            colors: [LB.appleHighlight, LB.apple],
          ).createShader(Rect.fromCircle(center: center, radius: c * .36)),
      );
    }

    // Power-up: a gold cell with a gold glow.
    final power = frame.powerUpPosition;
    if (valid(power)) {
      final r = at(power!).deflate(1);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r.inflate(2), Radius.circular(c * .3)),
        Paint()
          ..color = LB.gold.withValues(alpha: .5)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, c * .3),
      );
      canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(c * .25)), Paint()..color = LB.gold);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r.deflate(r.width * .32), Radius.circular(c * .1)),
        Paint()..color = LB.goldHead,
      );
    }

    // Snake, tail first so the head lands on top.
    final body = frame.snakePositions.where(valid).toList();
    if (body.isEmpty) return;
    final radius = Radius.circular(math.min(LB.snakeCellRadius, c * .2));
    for (var i = body.length - 1; i >= 1; i--) {
      final t = body.length <= 1 ? 0.0 : i / (body.length - 1);
      canvas.drawRRect(
        RRect.fromRectAndRadius(at(body[i]).deflate(1), radius),
        Paint()..color = p.lime.withValues(alpha: 1 - .55 * t),
      );
    }
    final head = at(body.first).deflate(1);
    final headRadius = Radius.circular(math.min(LB.headRadius, c * .3));
    canvas.drawRRect(
      RRect.fromRectAndRadius(head.inflate(2), headRadius),
      Paint()
        ..color = p.head.withValues(alpha: .45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.min(6, c * .4)),
    );
    canvas.drawRRect(RRect.fromRectAndRadius(head, headRadius), Paint()..color = p.head);
    _eyes(canvas, head, frame.direction, p.onLime);
  }

  static void _eyes(Canvas canvas, Rect head, String direction, Color color) {
    final paint = Paint()..color = color;
    final r = head.width * .09;
    final f = head.width * .2; // forward offset from centre
    final s = head.width * .19; // spread
    final c = head.center;
    final (Offset a, Offset b) = switch (direction) {
      'left' => (c + Offset(-f, -s), c + Offset(-f, s)),
      'up' => (c + Offset(-s, -f), c + Offset(s, -f)),
      'down' => (c + Offset(-s, f), c + Offset(s, f)),
      _ => (c + Offset(f, -s), c + Offset(f, s)),
    };
    canvas.drawCircle(a, r, paint);
    canvas.drawCircle(b, r, paint);
  }

  @override
  bool shouldRepaint(ReplayBoardPainter old) =>
      old.frame != frame ||
      old.palette != palette ||
      old.cellSize != cellSize ||
      old.columns != columns ||
      old.rows != rows;
}
