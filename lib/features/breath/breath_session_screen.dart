import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class BreathSessionScreen extends StatefulWidget {
  const BreathSessionScreen({
    super.key,
    required this.title,
    required this.duration,
    this.themeKey = 3,
  });

  final String title;

  /// Duration in minutes.
  final int duration;
  final int themeKey;

  static const String routeName = "/breath_session";

  @override
  State<BreathSessionScreen> createState() => _BreathSessionScreenState();
}

class BreathSessionArgs {
  const BreathSessionArgs({
    required this.title,
    required this.duration,
    this.themeKey = 3,
  });

  final String title;
  final int duration;
  final int themeKey;
}

class BreathSessionTheme {
  const BreathSessionTheme({
    required this.background,
    required this.progressBg,
    required this.progressValue,
    required this.textPrimary,
    required this.textSecondary,
    required this.buttonGradient,
    required this.exhaleGradient,
    required this.waveDeep,
    required this.waveMid,
    required this.waveSoft,
  });

  final Color background;
  final Color progressBg;
  final Color progressValue;
  final Color textPrimary;
  final Color textSecondary;
  final List<Color> buttonGradient;
  final List<Color> exhaleGradient;
  final Color waveDeep;
  final Color waveMid;
  final Color waveSoft;
}

enum _BreathCuePhase { idle, inhale, exhale }

class _BreathSessionScreenState extends State<BreathSessionScreen>
    with TickerProviderStateMixin {
  late final AnimationController _wavePhaseController;
  late final AnimationController _breathController;
  late final AnimationController _timerController;
  late final AudioPlayer _inhaleCuePlayer;
  late final AudioPlayer _exhaleCuePlayer;
  bool _started = false;
  _BreathCuePhase _lastCuePhase = _BreathCuePhase.idle;
  bool _cuePlayersReady = false;

  int get _totalSeconds => widget.duration * 60;
  int get _themeKey => widget.themeKey;

  static const List<BreathSessionTheme> _themes = [
    BreathSessionTheme(
      background: Color(0xFFF3EEFF),
      progressBg: Color(0xFFD7CCF4),
      progressValue: Color(0xFF8C7BFF),
      textPrimary: Color(0xFF4A3D70),
      textSecondary: Color(0xFF75689A),
      buttonGradient: [Color(0xFF9B8CFF), Color(0xFF6E5CD6)],
      exhaleGradient: [Color(0xFFCFC7FF), Color(0xFF8A7BEB)],
      waveDeep: Color(0xFF7D6EEA),
      waveMid: Color(0xFFA69AF8),
      waveSoft: Color(0xFFD1C9FF),
    ),
    BreathSessionTheme(
      background: Color(0xFFEAF8FB),
      progressBg: Color(0xFFBFDDE5),
      progressValue: Color(0xFF2CAEC0),
      textPrimary: Color(0xFF1F4A56),
      textSecondary: Color(0xFF48717D),
      buttonGradient: [Color(0xFF43CFE0), Color(0xFF1E8CA1)],
      exhaleGradient: [Color(0xFFAEDFE8), Color(0xFF519FB0)],
      waveDeep: Color(0xFF2E8FA2),
      waveMid: Color(0xFF62B7C7),
      waveSoft: Color(0xFFA4DEE9),
    ),
    BreathSessionTheme(
      background: Color(0xFFEFF8F2),
      progressBg: Color(0xFFCBE3D3),
      progressValue: Color(0xFF5EA881),
      textPrimary: Color(0xFF2C5A3E),
      textSecondary: Color(0xFF4E7860),
      buttonGradient: [Color(0xFF73C696), Color(0xFF3D8D63)],
      exhaleGradient: [Color(0xFFBEE3CC), Color(0xFF6EAF88)],
      waveDeep: Color(0xFF4E9A70),
      waveMid: Color(0xFF82C59D),
      waveSoft: Color(0xFFBCE7CC),
    ),
    BreathSessionTheme(
      background: Color(0xFFF7EAD9),
      progressBg: Color(0xFFE1D4C3),
      progressValue: Color(0xFF8D6BFF),
      textPrimary: Color(0xFF5D4670),
      textSecondary: Color(0xFF8C7D6A),
      buttonGradient: [Color(0xFFB177FF), Color(0xFF8D6BFF)],
      exhaleGradient: [Color(0xFFCDC1FF), Color(0xFF9685F5)],
      waveDeep: Color(0xFF9685F5),
      waveMid: Color(0xFFB19BFF),
      waveSoft: Color(0xFFCDC1FF),
    ),
    BreathSessionTheme(
      background: Color(0xFFFFEDF2),
      progressBg: Color(0xFFF0CAD6),
      progressValue: Color(0xFFC95B7D),
      textPrimary: Color(0xFF7A3F56),
      textSecondary: Color(0xFF9F6278),
      buttonGradient: [Color(0xFFFF88A8), Color(0xFFC95B7D)],
      exhaleGradient: [Color(0xFFF7C8D9), Color(0xFFC96E8E)],
      waveDeep: Color(0xFFC96E8E),
      waveMid: Color(0xFFE39AB6),
      waveSoft: Color(0xFFF7C8D9),
    ),
  ];

  /// Rise to peak → hold at top (text "Nafas oling") → fall → rest at bottom.
  static const int _riseSeconds = 5;
  static const int _holdTopSeconds = 3;
  static const int _fallSeconds = 3;
  static const int _restSeconds = 5;

  static int get _cycleSeconds =>
      _riseSeconds + _holdTopSeconds + _fallSeconds + _restSeconds;

  double _easeInOut(double t) => Curves.easeInOut.transform(t);

  double _cueScale(double opacity) => 0.96 + (opacity * 0.04);

  double _cueOffsetY(double opacity, {required bool inhale}) {
    final travel = (1 - opacity) * 8.h;
    return inhale ? travel : -travel;
  }

  /// 0 at phase edges → 1 in the middle; fadeFraction of phase length at each end.
  double _phaseFadeOpacity(
    double p,
    double start,
    double end, {
    double fadeFraction = 0.20,
  }) {
    if (p <= start || p >= end) return 0.0;
    final len = end - start;
    if (len <= 0) return 0.0;
    final fade = len * fadeFraction;
    final t = p - start;
    double smooth(double x) => x * x * (3 - 2 * x); // smoothstep 0..1
    if (t < fade) return smooth((t / fade).clamp(0.0, 1.0));
    if (t > len - fade) {
      return smooth(((len - t) / fade).clamp(0.0, 1.0));
    }
    return 1.0;
  }

  @override
  void initState() {
    super.initState();
    _wavePhaseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );
    _breathController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _cycleSeconds),
    );

    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _totalSeconds),
    );
    _inhaleCuePlayer = AudioPlayer();
    _exhaleCuePlayer = AudioPlayer();
    unawaited(_initCuePlayers());

    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _breathController.stop();
        _wavePhaseController.stop();
      }
    });
  }

  @override
  void dispose() {
    _wavePhaseController.dispose();
    _breathController.dispose();
    _timerController.dispose();
    _inhaleCuePlayer.dispose();
    _exhaleCuePlayer.dispose();
    super.dispose();
  }

  void _startSession() {
    if (_started) return;
    setState(() {
      _started = true;
    });
    _lastCuePhase = _BreathCuePhase.idle;
    _timerController.forward(from: 0);
    _breathController.repeat();
    _wavePhaseController.repeat();
  }

  _BreathCuePhase _cuePhaseForProgress(
    double breathProgress,
    double holdEnd,
    double fallEnd,
  ) {
    if (!_started) return _BreathCuePhase.idle;
    if (breathProgress < holdEnd) return _BreathCuePhase.inhale;
    if (breathProgress < fallEnd) return _BreathCuePhase.exhale;
    return _BreathCuePhase.idle;
  }

  void _playCueSoundIfNeeded(_BreathCuePhase phase) {
    if (phase == _lastCuePhase || phase == _BreathCuePhase.idle) return;
    _lastCuePhase = phase;
    if (!_cuePlayersReady) return;
    if (phase == _BreathCuePhase.inhale) {
      unawaited(_replayCue(_inhaleCuePlayer));
      return;
    }
    unawaited(_replayCue(_exhaleCuePlayer));
  }

  Future<void> _replayCue(AudioPlayer player) async {
    try {
      await player.seek(Duration.zero);
      await player.play();
    } catch (_) {
      // Cue signal fails silently; breathing UI should stay uninterrupted.
    }
  }

  Future<void> _initCuePlayers() async {
    try {
      final dir = await getTemporaryDirectory();
      final inhalePath = "${dir.path}/breath_inhale_cue.wav";
      final exhalePath = "${dir.path}/breath_exhale_cue.wav";
      final inhaleFile = await File(inhalePath).create(recursive: true);
      final exhaleFile = await File(exhalePath).create(recursive: true);
      await inhaleFile.writeAsBytes(
        _buildSineWavBytes(
          frequency: 720,
          durationMs: 140,
          volume: 0.26,
        ),
        flush: true,
      );
      await exhaleFile.writeAsBytes(
        _buildSineWavBytes(
          frequency: 460,
          durationMs: 180,
          volume: 0.24,
        ),
        flush: true,
      );

      await _inhaleCuePlayer.setFilePath(inhalePath);
      await _exhaleCuePlayer.setFilePath(exhalePath);
      await _inhaleCuePlayer.setVolume(1.0);
      await _exhaleCuePlayer.setVolume(1.0);
      _cuePlayersReady = true;
    } catch (_) {
      _cuePlayersReady = false;
    }
  }

  Uint8List _buildSineWavBytes({
    required double frequency,
    int durationMs = 150,
    double volume = 0.25,
    int sampleRate = 22050,
  }) {
    final sampleCount = (sampleRate * durationMs / 1000).round();
    final data = BytesBuilder();
    for (int i = 0; i < sampleCount; i++) {
      final t = i / sampleRate;
      final fadeIn = (i / (sampleRate * 0.01)).clamp(0.0, 1.0);
      final fadeOut = ((sampleCount - i) / (sampleRate * 0.03)).clamp(0.0, 1.0);
      final env = fadeIn * fadeOut;
      final sample =
          (math.sin(2 * math.pi * frequency * t) * volume * env * 32767)
              .round()
              .clamp(-32768, 32767);
      data.add(_int16LE(sample));
    }

    final pcm = data.toBytes();
    final byteRate = sampleRate * 2;
    final wav = BytesBuilder();
    wav
      ..add(_ascii("RIFF"))
      ..add(_int32LE(36 + pcm.length))
      ..add(_ascii("WAVE"))
      ..add(_ascii("fmt "))
      ..add(_int32LE(16))
      ..add(_int16LE(1))
      ..add(_int16LE(1))
      ..add(_int32LE(sampleRate))
      ..add(_int32LE(byteRate))
      ..add(_int16LE(2))
      ..add(_int16LE(16))
      ..add(_ascii("data"))
      ..add(_int32LE(pcm.length))
      ..add(pcm);
    return wav.toBytes();
  }

  List<int> _ascii(String value) => value.codeUnits;
  List<int> _int16LE(int value) => [value & 0xff, (value >> 8) & 0xff];
  List<int> _int32LE(int value) => [
        value & 0xff,
        (value >> 8) & 0xff,
        (value >> 16) & 0xff,
        (value >> 24) & 0xff,
      ];

  String _formatRemaining() {
    final remaining = (_totalSeconds * (1 - _timerController.value)).ceil();
    final m = remaining ~/ 60;
    final s = remaining % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themes[_themeKey.clamp(0, _themes.length - 1)];

    return Scaffold(
      backgroundColor: theme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            left: false,
            right: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: AnimatedBuilder(
                    animation: _timerController,
                    builder: (context, _) {
                      return Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: _started ? _timerController.value : 0,
                                minHeight: 3.h,
                                backgroundColor: theme.progressBg,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.progressValue,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            _started ? _formatRemaining() : _formatDuration(),
                            style: AppTextStyles.body14w6.copyWith(
                              color: theme.textSecondary,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          InkWell(
                            onTap: () => context.pop(),
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              height: 28.w,
                              width: 28.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.progressBg,
                              ),
                              child: const Icon(
                                CupertinoIcons.xmark,
                                size: 16,
                                color: Color(0xFF8C7D6A),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 32.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 26.w),
                  child: Column(
                    children: [
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body24w7.copyWith(
                          color: theme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        "Ready to take a soft pause and breathe?\nWhen you feel ready, tap start and\nlet the rhythm guide you.",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body14w4.copyWith(
                          color: theme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      if (!_started)
                        SizedBox(
                          width: double.infinity,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _startSession,
                              borderRadius: BorderRadius.circular(999),
                              child: Ink(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 40.w,
                                  vertical: 13.h,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: theme.buttonGradient,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x2B8D6BFF),
                                      blurRadius: 18,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    "Start practice",
                                    style: AppTextStyles.body16w7.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 480.h,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: Listenable.merge(
                [_breathController, _wavePhaseController, _timerController],
              ),
              builder: (context, _) {
                final wavePhase = _wavePhaseController.value;

                // breathProgress: 0..1 within one full cycle.
                final breathProgress = _started ? _breathController.value : 0.0;
                final cycle = _cycleSeconds.toDouble();
                final riseEnd = _riseSeconds / cycle;
                final holdEnd =
                    (_riseSeconds + _holdTopSeconds) / cycle; // fall starts
                final fallEnd =
                    (_riseSeconds + _holdTopSeconds + _fallSeconds) / cycle;

                // breathLift: 0 rest → 1 peak (rise + hold) → 0 (after fall) → 0 rest.
                double breathLift;
                if (breathProgress < riseEnd) {
                  final t = (breathProgress / riseEnd).clamp(0.0, 1.0);
                  breathLift = _easeInOut(t);
                } else if (breathProgress < holdEnd) {
                  breathLift = 1.0;
                } else if (breathProgress < fallEnd) {
                  final t = ((breathProgress - holdEnd) / (fallEnd - holdEnd))
                      .clamp(0.0, 1.0);
                  breathLift = 1 - _easeInOut(t);
                } else {
                  breathLift = 0.0;
                }

                final inhaleTextOpacity = _started
                    ? _phaseFadeOpacity(breathProgress, 0, holdEnd)
                    : 0.0;
                final exhaleTextOpacity = _started
                    ? _phaseFadeOpacity(breathProgress, holdEnd, fallEnd)
                    : 0.0;
                final cuePhase = _cuePhaseForProgress(
                  breathProgress,
                  holdEnd,
                  fallEnd,
                );
                _playCueSoundIfNeeded(cuePhase);

                // No Transform.scale: scaling < 1.0 shrinks the paint horizontally and
                // exposes the scaffold background on the left/right during exhale/rest.
                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: _WavesPainter(
                            wavePhase: wavePhase,
                            breathLift: breathLift,
                            isStarted: _started,
                            deepColor: theme.waveDeep,
                            midColor: theme.waveMid,
                            softColor: theme.waveSoft,
                          ),
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: inhaleTextOpacity,
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                _cueOffsetY(inhaleTextOpacity, inhale: true),
                              ),
                              child: Transform.scale(
                                scale: _cueScale(inhaleTextOpacity),
                                child: _BreathCuePill(
                                  text: "Nafas oling",
                                  isInhale: true,
                                  gradientColors: theme.buttonGradient,
                                ),
                              ),
                            ),
                          ),
                          Opacity(
                            opacity: exhaleTextOpacity,
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                _cueOffsetY(exhaleTextOpacity, inhale: false),
                              ),
                              child: Transform.scale(
                                scale: _cueScale(exhaleTextOpacity),
                                child: _BreathCuePill(
                                  text: "Nafas chiqaring",
                                  isInhale: false,
                                  gradientColors: theme.exhaleGradient,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration() {
    final m = widget.duration;
    return "0${m.toString()}:00".substring(m >= 10 ? 0 : 1);
  }
}

class _WavesPainter extends CustomPainter {
  _WavesPainter({
    required this.wavePhase,
    required this.isStarted,
    required this.breathLift,
    required this.deepColor,
    required this.midColor,
    required this.softColor,
  });

  final double wavePhase;
  final bool isStarted;
  final double breathLift; // 0..1
  final Color deepColor;
  final Color midColor;
  final Color softColor;

  List<Offset> _buildWavePoints({
    required double width,
    required double baseY,
    required double frequency,
    required double amplitude,
    required double primaryPhase,
    required double secondaryPhase,
    required double taperStrength,
    required double chopStrength,
  }) {
    const step = 6.0;
    final points = <Offset>[];
    for (double x = 0; x <= width + step; x += step) {
      final t = (x / width).clamp(0.0, 1.0);
      final edge = ((t - 0.5).abs() / 0.5).clamp(0.0, 1.0);
      final taper = 1 - (edge * edge * edge * taperStrength);
      final swell = math.sin((t * math.pi * 2 * frequency) + primaryPhase);
      final crossSwell = math.sin(
        (t * math.pi * 2 * (frequency * 0.58)) -
            (primaryPhase * 0.65) +
            secondaryPhase,
      );
      final ripple = math.sin(
        (t * math.pi * 2 * (frequency * 2.35)) + secondaryPhase,
      );
      final mix =
          (swell * 0.62) + (crossSwell * 0.28) + (ripple * 0.10 * chopStrength);
      points.add(Offset(x, baseY + (mix * amplitude * taper)));
    }
    return points;
  }

  Path _smoothStrokePathFromPoints(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final control = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
      path.quadraticBezierTo(current.dx, current.dy, control.dx, control.dy);
    }
    final last = points.last;
    path.lineTo(last.dx, last.dy);
    return path;
  }

  Path _smoothPathFromPoints(List<Offset> points, double width, double height) {
    final path = Path()..moveTo(0, height);
    if (points.isEmpty) {
      path
        ..lineTo(width, height)
        ..close();
      return path;
    }

    path.lineTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final control = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
      path.quadraticBezierTo(current.dx, current.dy, control.dx, control.dy);
    }

    final last = points.last;
    path
      ..lineTo(last.dx, last.dy)
      ..lineTo(width, height)
      ..close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Breath-driven rise/fall of the liquid fill height.
    // Tuned so that at inhale peak the fill height reaches 400 (as requested),
    // and returns to the previous "rest" fill height at exhale peak.
    final restFillHeight = h * 0.54; // matches previous visual at breathLift=0
    final peakFillHeight = math.min(400.h, h);
    final waveHeight =
        (restFillHeight + (peakFillHeight - restFillHeight) * breathLift)
            .clamp(40.0, h);
    final waveTop = h - waveHeight;

    // Breathing-like strength: slow oscillation (only strong when started).
    final strength = isStarted ? (0.28 + breathLift * 0.72) : 0.22;

    // Subtle vertical drift synchronized with the lift curve.
    final shiftFactor = 1 - (breathLift - 0.5).abs() * 2; // peak at mid-lift
    final shiftY = shiftFactor * waveHeight * (0.014 + breathLift * 0.022);

    void drawLayer({
      required Color color,
      required double amplitude,
      required double freq,
      required double phaseOffset,
      required double yOffset,
      required double alpha,
      required int flowTurns,
      required double flowDirection,
      double edgeTaper = 0.12,
      double chopStrength = 0.5,
      double strokeAlpha = 0.0,
    }) {
      final paint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..isAntiAlias = true
        ..style = PaintingStyle.fill;

      // Integer turn counts keep loop boundaries seamless while allowing
      // per-layer flow speeds and directions.
      final primaryPhase =
          (wavePhase * 2 * math.pi * flowTurns * flowDirection) + phaseOffset;
      final secondaryPhase =
          (wavePhase * 2 * math.pi * (flowTurns + 1) * -flowDirection * 0.6) +
              (phaseOffset * 0.8);

      final points = _buildWavePoints(
        width: w,
        baseY: waveTop + yOffset + shiftY,
        frequency: freq,
        amplitude: amplitude * strength * (0.82 + breathLift * 0.26),
        primaryPhase: primaryPhase,
        secondaryPhase: secondaryPhase,
        taperStrength: edgeTaper,
        chopStrength: chopStrength,
      );
      final path = _smoothPathFromPoints(points, w, h);
      canvas.drawPath(path, paint);

      if (strokeAlpha > 0) {
        final stroke = Paint()
          ..color = Colors.white.withValues(alpha: strokeAlpha)
          ..isAntiAlias = true
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        canvas.drawPath(_smoothStrokePathFromPoints(points), stroke);
      }
    }

    // Opaque base fill: must follow the same curved surface as the waves — a flat
    // `drawRect` leaves a visible horizontal “card” edge behind translucent layers.
    drawLayer(
      color: deepColor,
      amplitude: waveHeight * 0.078,
      freq: 0.66,
      phaseOffset: 0.0,
      yOffset: waveHeight * 0.050,
      alpha: 1.0,
      flowTurns: 1,
      flowDirection: 1,
      edgeTaper: 0.08,
      chopStrength: 0.34,
    );

    drawLayer(
      color: midColor,
      amplitude: waveHeight * 0.064,
      freq: 0.92,
      phaseOffset: math.pi / 8,
      yOffset: waveHeight * 0.072,
      alpha: 0.56 + breathLift * 0.22,
      flowTurns: 2,
      flowDirection: -1,
      edgeTaper: 0.14,
      chopStrength: 0.48,
    );

    drawLayer(
      color: softColor,
      amplitude: waveHeight * 0.046,
      freq: 1.18,
      phaseOffset: math.pi / 1.2,
      yOffset: waveHeight * 0.095,
      alpha: 0.44 + breathLift * 0.17,
      flowTurns: 3,
      flowDirection: 1,
      edgeTaper: 0.16,
      chopStrength: 0.62,
    );

    // Thin highlight crest.
    drawLayer(
      color: Colors.white,
      amplitude: waveHeight * 0.018,
      freq: 1.28,
      phaseOffset: math.pi / 2.1,
      yOffset: waveHeight * 0.104,
      alpha: 0.015 + breathLift * 0.03,
      flowTurns: 2,
      flowDirection: -1,
      edgeTaper: 0.18,
      chopStrength: 0.75,
      strokeAlpha: 0.05 + breathLift * 0.04,
    );
  }

  @override
  bool shouldRepaint(covariant _WavesPainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase ||
        oldDelegate.breathLift != breathLift ||
        oldDelegate.isStarted != isStarted ||
        oldDelegate.deepColor != deepColor ||
        oldDelegate.midColor != midColor ||
        oldDelegate.softColor != softColor;
  }
}

class _BreathCuePill extends StatelessWidget {
  const _BreathCuePill({
    required this.text,
    required this.isInhale,
    required this.gradientColors,
  });

  final String text;
  final bool isInhale;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradientColors,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: gradient,
        boxShadow: const [
          BoxShadow(
            color: Color(0x2B8D6BFF),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Text(
        text,
        style: AppTextStyles.body16w7.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}
