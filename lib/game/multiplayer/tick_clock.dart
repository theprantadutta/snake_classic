import 'dart:math' as math;

/// A continuous server-tick counter for drawing an online match smoothly.
///
/// Snapshots leave the server on a steady cadence (`tick_ms`) but reach the
/// phone whenever the network delivers them: on Wi-Fi a 300ms tick arrives
/// anywhere from ~190ms to ~400ms after the one before, sometimes two at
/// once. Animating from each ARRIVAL — restarting the glide when a packet
/// lands — turns that jitter straight into motion: an early packet cuts the
/// glide short (a skip forward), a late one lets it finish and sit still
/// (stop-and-go).
///
/// This clock is the standard fix. It advances by itself at the server's
/// tick rate, so [position] moves the same distance every frame however the
/// packets fall, and it is only *steered* by them:
///
/// * each arrival says where the clock ought to read now — the snapshot's
///   tick minus a chosen `lag`. The difference is smoothed
///   ([phaseSmoothing]) into an estimate of how far off the clock runs, and
///   the clock runs up to [maxRateAdjust] faster or slower until it has made
///   it up. One early or late packet barely moves it; a sustained shift (a
///   speed-ramp step, a change of route) is absorbed over a few ticks.
/// * a divergence beyond [resyncThreshold] ticks — a reconnect, a new
///   match, the app returning from the background — is not worth gliding
///   out: the clock jumps to the target.
/// * a `limit` caps it (the newest tick there is anything to draw for). It
///   slows into the cap over [softZone] ticks instead of stopping dead, so a
///   snapshot that is later than the margin allows reads as a brief ease,
///   not a freeze, and it never stops short of the cap, so the final tick
///   of a match is always reached.
///
/// It also measures the arrival jitter ([jitter]) — the playout buffer for
/// the rival sizes its delay from it.
///
/// Time is passed in, never read: every behaviour is a deterministic
/// function of the frame deltas and arrivals a test feeds it.
class TickClock {
  TickClock({
    this.maxRateAdjust = .12,
    this.gain = .6,
    this.phaseSmoothing = .2,
    this.jitterSmoothing = .1,
    this.resyncThreshold = 1.5,
    this.softZone = .3,
    this.minSoftRate = .25,
    this.initialJitter = .12,
    this.catchUpBoost = .25,
  }) : _jitter = initialJitter;

  /// The most the clock ever runs faster or slower than the server, as a
  /// fraction of the tick rate. Small enough that nobody sees a speed
  /// change; large enough to make up a tick of drift in under ten.
  final double maxRateAdjust;

  /// Rate change per tick of estimated offset, before [maxRateAdjust].
  final double gain;

  /// Weight of each new arrival in the offset estimate.
  final double phaseSmoothing;

  /// Weight of each new arrival in [jitter].
  final double jitterSmoothing;

  /// Beyond this many ticks off, an arrival moves the clock outright.
  final double resyncThreshold;

  /// The last this-many ticks below the limit are run at a slowing rate.
  final double softZone;

  /// The slowest the soft zone ever runs, as a fraction of the tick rate.
  final double minSoftRate;

  /// The jitter assumed before any arrival has been measured, in ticks.
  final double initialJitter;

  /// Extra speed-up allowed when the clock is more than a tick BEHIND,
  /// reached at two ticks behind. After a long silence and a burst the
  /// clock has fallen well behind the server; running a little faster for a
  /// second reads better than jumping. Ahead, the bound stays
  /// [maxRateAdjust]: slowing down never needs to be quicker.
  final double catchUpBoost;

  double _position = 0;
  double _offset = 0;
  double _jitter;
  double _tickMs = 300;
  bool _started = false;
  int _resyncs = 0;

  /// Whether the clock has seen its first arrival.
  bool get started => _started;

  /// The current position on the server's tick axis: 41.25 is a quarter of
  /// the way from tick 41 to tick 42.
  double get position => _position;

  /// The estimated difference between where arrivals say the clock should
  /// read and where it does, in ticks (positive: running behind).
  double get offset => _offset;

  /// Smoothed mean absolute deviation of arrivals from the clock's cadence,
  /// in ticks.
  double get jitter => _jitter;

  /// The tick length the clock currently runs at.
  double get tickMs => _tickMs;

  /// How many arrivals have moved the clock outright since [reset].
  int get resyncs => _resyncs;

  /// Forget everything; the next arrival starts the clock.
  void reset() {
    _position = 0;
    _offset = 0;
    _jitter = initialJitter;
    _started = false;
    _resyncs = 0;
  }

  /// A snapshot for [tick] arrived now. The clock should read `tick − lag`
  /// at this moment. [resync] forces a jump (a reconnect the caller has
  /// recognised). Returns true when the clock jumped.
  bool onArrival(
    int tick, {
    required int tickMs,
    double lag = 0,
    bool resync = false,
  }) {
    if (tickMs > 0) _tickMs = tickMs.toDouble();
    final target = tick - lag;
    if (!_started || resync) {
      if (_started) _resyncs++;
      _jump(target);
      return true;
    }
    final error = target - _position;
    if (error.abs() > resyncThreshold) {
      _resyncs++;
      _jump(target);
      return true;
    }
    final residual = (error - _offset).abs();
    _jitter += jitterSmoothing * (residual - _jitter);
    _offset += phaseSmoothing * (error - _offset);
    return false;
  }

  void _jump(double target) {
    _position = target;
    _offset = 0;
    _started = true;
  }

  /// Move the clock back to [limit] when what it may show has shrunk under
  /// it (a predicted path that now stops short). The only way the clock
  /// ever runs backwards outside a resync; the caller eases the picture.
  void clampTo(double limit) {
    if (_position <= limit) return;
    _offset += _position - limit;
    _position = limit;
  }

  /// Advance by one frame of [dtSeconds], never past [limit].
  void advance(double dtSeconds, {required double limit}) {
    if (!_started || dtSeconds <= 0) return;
    final nominal = dtSeconds * 1000 / _tickMs;
    final behind = (_offset - 1).clamp(0.0, 1.0);
    final rate =
        1 +
        (_offset * gain).clamp(
          -maxRateAdjust,
          maxRateAdjust + catchUpBoost * behind,
        );
    var step = nominal * rate;

    final room = limit - _position;
    if (room <= 0) {
      step = 0;
    } else {
      if (room < softZone && softZone > 0) {
        step *= math.max(minSoftRate, room / softZone);
      }
      step = math.min(step, room);
    }

    _position += step;
    // The target moved on at the nominal rate; whatever the clock did not
    // keep up with (or ran ahead by) is now owed.
    _offset += nominal - step;
    _offset = _offset.clamp(-2 * resyncThreshold, 2 * resyncThreshold);
  }
}
