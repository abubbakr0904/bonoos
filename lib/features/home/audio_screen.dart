import 'dart:async';
import 'dart:math' as math;

import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/playlist/domain/entity/audition.dart';
import 'package:bonoos/features/playlist/domain/repository/playlist_repository.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

class AudioScreenArgs {
  const AudioScreenArgs({
    required this.title,
    required this.durationLabel,
    required this.audioUrl,
    this.auditionId,
    this.auditionType,
    this.durationSeconds,
    this.initialFavorited,
    this.categoryIdForSync,
    this.onAuditionsSynced,
    this.syncHomeAuditionsAfterFavorite = false,
  });

  final String title;
  final String durationLabel;
  final String audioUrl;
  final int? auditionId;
  final int? auditionType;
  final int? durationSeconds;
  final bool? initialFavorited;
  final int? categoryIdForSync;
  final void Function(List<Audition> list)? onAuditionsSynced;
  final bool syncHomeAuditionsAfterFavorite;
}

class AudioScreen extends StatefulWidget {
  const AudioScreen({
    super.key,
    required this.title,
    required this.durationLabel,
    required this.audioUrl,
    this.auditionId,
    this.auditionType,
    this.durationSeconds,
    this.initialFavorited,
    this.categoryIdForSync,
    this.onAuditionsSynced,
    this.syncHomeAuditionsAfterFavorite = false,
  });

  static const String routeName = '/audio_screen';

  final String title;
  final String durationLabel;
  final String audioUrl;
  final int? auditionId;
  final int? auditionType;
  final int? durationSeconds;
  final bool? initialFavorited;
  final int? categoryIdForSync;
  final void Function(List<Audition> list)? onAuditionsSynced;
  final bool syncHomeAuditionsAfterFavorite;

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> with TickerProviderStateMixin {
  late final AudioPlayer _player;
  late final AnimationController _orbController;
  late final AnimationController _pulseController;
  late final AnimationController _enterController;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<Duration>? _positionSub;
  bool _auditionListenReported = false;
  late bool _favorited;
  String? _audioErrorText;

  void _showError(String text) {
    if (!mounted) return;
    setState(() => _audioErrorText = text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  void initState() {
    super.initState();
    _favorited = widget.initialFavorited ?? false;
    _player = AudioPlayer();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _initAudio();

    _playingSub = _player.playingStream.listen((playing) {
      if (!mounted) return;
      if (playing) {
        _enterController.forward(from: 0);
        if (!_orbController.isAnimating) {
          _orbController.repeat();
        }
        if (!_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        }
      } else {
        _pulseController.stop();
        _orbController.stop();
        _orbController.value = 0;
        _pulseController.value = 0;
        _enterController.reverse();
      }
    });

    _positionSub = _player.positionStream.listen(_onPositionForListenReport);
  }

  void _onPositionForListenReport(Duration position) {
    if (_auditionListenReported || !mounted) return;
    final auditionId = widget.auditionId;
    if (auditionId == null) return;
    final total = _player.duration;
    if (total == null || total.inMilliseconds <= 0) return;
    if (position.inMilliseconds * 100 < total.inMilliseconds * 70) return;
    _auditionListenReported = true;
    final dur = widget.durationSeconds ?? total.inSeconds;
    unawaited(
      inject<PlaylistRepository>().reportAuditionListen(
        auditionId: auditionId,
        durationSeconds: dur,
        auditionType: widget.auditionType ?? 0,
      ),
    );
  }

  Future<void> _initAudio() async {
    try {
      await _player.setUrl(widget.audioUrl);
      if (mounted) {
        setState(() => _audioErrorText = null);
      }
    } on MissingPluginException {
      _showError("Audio plugin topilmadi. Appni to'liq restart qiling (hot restart).");
    } catch (_) {
      _showError("Audio yuklanmadi. Internetni tekshiring yoki keyinroq urinib ko'ring.");
    }
  }

  @override
  void dispose() {
    _orbController.dispose();
    _pulseController.dispose();
    _enterController.dispose();
    _playingSub?.cancel();
    _positionSub?.cancel();
    _player.dispose().catchError((_) {});
    super.dispose();
  }

  Future<void> _togglePlay() async {
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
      if (mounted) {
        setState(() => _audioErrorText = null);
      }
    } on MissingPluginException {
      _showError("Audio plugin topilmadi. Appni to'liq restart qiling (hot restart).");
    } catch (_) {
      _showError("Audio ijro etilmadi. Internetni tekshiring.");
    }
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _toggleFavorite() async {
    final id = widget.auditionId;
    if (id == null) {
      setState(() => _favorited = !_favorited);
      return;
    }
    final prev = _favorited;
    setState(() => _favorited = !_favorited);
    final repo = inject<PlaylistRepository>();
    final either = await repo.toggleAuditionFavorite(id);
    if (!mounted) return;
    final failed = either.fold<bool>(
      (_) {
        setState(() => _favorited = prev);
        return true;
      },
      (_) => false,
    );
    if (failed) return;
    final cat = widget.categoryIdForSync;
    if (cat != null) {
      final r = await repo.fetchAuditions(cat);
      if (!mounted) return;
      r.fold((_) {}, (list) => widget.onAuditionsSynced?.call(list));
      return;
    }
    if (widget.syncHomeAuditionsAfterFavorite) {
      final r = await repo.fetchAuditionsPage(limit: 20, offset: 0);
      if (!mounted) return;
      r.fold((_) {}, (page) => widget.onAuditionsSynced?.call(page.items));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Column(
            children: [
              SizedBox(height: 8.h),
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(CupertinoIcons.back, color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      _favorited ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                      color: _favorited ? const Color(0xFFFFA3C3) : Colors.white70,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 26.h),
              AnimatedBuilder(
                animation: Listenable.merge([_orbController, _pulseController, _enterController]),
                builder: (context, _) {
                  return SizedBox(
                    height: 270.w,
                    width: 270.w,
                    child: CustomPaint(
                      painter: _GlowingOrbPainter(
                        phase: _orbController.value,
                        pulse: _pulseController.value,
                        enter: _enterController.value,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 50.h),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.body33w7.copyWith(color: Colors.white, height: 1.15),
              ),
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                child: StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, posSnap) {
                    final position = posSnap.data ?? Duration.zero;
                    return StreamBuilder<Duration?>(
                      stream: _player.durationStream,
                      builder: (context, durSnap) {
                        final total = durSnap.data ?? const Duration(seconds: 1);
                        final maxMs = math.max(total.inMilliseconds, 1);
                        final curMs = position.inMilliseconds.clamp(0, maxMs).toDouble();
                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.white38,
                                thumbColor: Colors.white,
                                overlayColor: Colors.white.withValues(alpha: 0.2),
                              ),
                              child: Slider(
                                min: 0,
                                max: maxMs.toDouble(),
                                value: curMs,
                                onChanged: (v) => _player.seek(Duration(milliseconds: v.toInt())),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.w),
                              child: Row(
                                children: [
                                  Text(_format(position),
                                      style: AppTextStyles.body20w5.copyWith(fontSize: 14, color: Colors.white70)),
                                  const Spacer(),
                                  Text(_format(total),
                                      style: AppTextStyles.body20w5.copyWith(fontSize: 14, color: Colors.white70)),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              if (_audioErrorText != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Text(
                    _audioErrorText!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body12w5.copyWith(color: const Color(0xFFFFC7D7)),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CircleIconButton(
                    icon: CupertinoIcons.refresh_thick,
                    onTap: () => _player.seek(Duration.zero),
                  ),
                  _CircleIconButton(
                    icon: CupertinoIcons.gobackward_15,
                    onTap: () async {
                      final p = _player.position - const Duration(seconds: 15);
                      await _player.seek(p.isNegative ? Duration.zero : p);
                    },
                  ),
                  StreamBuilder<bool>(
                    stream: _player.playingStream,
                    builder: (context, snap) {
                      final playing = snap.data ?? false;
                      return _CircleIconButton(
                        icon: playing ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                        active: true,
                        size: 66.w,
                        onTap: _togglePlay,
                      );
                    },
                  ),
                  _CircleIconButton(
                    icon: CupertinoIcons.goforward_15,
                    onTap: () async {
                      final d = _player.duration ?? Duration.zero;
                      final p = _player.position + const Duration(seconds: 15);
                      await _player.seek(p > d ? d : p);
                    },
                  ),
                  _CircleIconButton(
                    icon: CupertinoIcons.repeat,
                    onTap: () async {
                      final next = _player.loopMode == LoopMode.off ? LoopMode.one : LoopMode.off;
                      await _player.setLoopMode(next);
                    },
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.active = false,
    this.size,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final s = size ?? 50.w;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          height: s,
          width: s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.08),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Icon(
            icon,
            color: active ? AppColors.mainBgColor : Colors.white,
            size: active ? 30.sp : 24.sp,
          ),
        ),
      ),
    );
  }
}

class _GlowingOrbPainter extends CustomPainter {
  _GlowingOrbPainter({
    required this.phase,
    required this.pulse,
    required this.enter,
  });

  final double phase;
  final double pulse;
  final double enter;

  Color _withOpacity(Color c, double opacity) {
    return c.withValues(alpha: opacity.clamp(0.0, 1.0));
  }

  Color _hueShift(Color color, double hueDegrees) {
    final hsl = HSLColor.fromColor(color);
    var hue = (hsl.hue + hueDegrees) % 360.0;
    if (hue < 0) hue += 360.0;
    return HSLColor.fromAHSL(hsl.alpha, hue, hsl.saturation, hsl.lightness).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    const idleT = 0.32;
    final t = (idleT + (1.0 - idleT) * enter).clamp(0.0, 1.0);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.47;
    final slowEnterBoost = 0.55 + 0.45 * enter;
    final shapeWave = (0.045 * slowEnterBoost) * math.sin(phase * math.pi) +
        (0.028 * slowEnterBoost) * math.sin(phase * math.pi * 2 + math.pi / 4);
    final scaledRadius = radius * (0.885 + 0.18 * t + shapeWave);

    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          _withOpacity(_hueShift(const Color(0x55E8B5FF), 140 * phase), t),
          _withOpacity(_hueShift(const Color(0x338C60D9), 170 * phase), t),
          _withOpacity(_hueShift(const Color(0x008C60D9), 200 * phase), t),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: scaledRadius * 1.25))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 18 + 16 * t);
    canvas.drawCircle(center, scaledRadius * (1.03 + pulse * 0.05), auraPaint);

    final basePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 0.95,
        colors: [
          _withOpacity(_hueShift(const Color(0xFFF4E8FF), 110 * phase), t),
          _withOpacity(_hueShift(const Color(0xFFD18CFF), 150 * phase), t),
          _withOpacity(_hueShift(const Color(0xFF9C55E2), 190 * phase), t),
          _withOpacity(_hueShift(AppColors.c55004D, 90 * phase + 40 * pulse), t),
        ],
        stops: const [0.0, 0.40, 0.76, 1.0],
        transform: GradientRotation(phase * math.pi * (0.28 + 0.12 * pulse)),
      ).createShader(Rect.fromCircle(center: center, radius: scaledRadius));
    canvas.drawCircle(center, scaledRadius, basePaint);

    final highlightOffset = Offset(
      center.dx + math.sin(phase * math.pi * 2) * (3.2 + 5.2 * t) + math.cos(phase * math.pi) * (1.2 * t),
      center.dy + scaledRadius * (0.43 + 0.05 * pulse),
    );
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          _withOpacity(_hueShift(const Color(0xCCFFEEDC), 80 * phase), t),
          _withOpacity(_hueShift(const Color(0x99E2BAFF), 120 * phase), t),
          _withOpacity(_hueShift(const Color(0x00E2BAFF), 160 * phase), t),
        ],
      ).createShader(Rect.fromCircle(center: highlightOffset, radius: scaledRadius * (0.30 + pulse * 0.06)))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + 10 * t);
    canvas.drawCircle(highlightOffset, scaledRadius * (0.24 + pulse * 0.045), highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _GlowingOrbPainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.pulse != pulse || oldDelegate.enter != enter;
  }
}
