import 'dart:async';

import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/features/alarm/alarm_models.dart';
import 'package:bonoos/features/common/widget/home_gradient_background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';

class AddAlarmScreen extends StatefulWidget {
  const AddAlarmScreen({super.key, this.editing});

  /// `null` — yangi budilnik; qiymat — tahrirlash rejimi (o‘chirish tugmasi chiqadi).
  final AlarmItem? editing;

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen>
    with SingleTickerProviderStateMixin {
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;
  late final AnimationController _entryController;
  late final AudioPlayer _previewPlayer;
  StreamSubscription<PlayerState>? _playerStateSub;
  int _hour = 0;
  int _minute = 0;
  String _selectedVoicePath = AlarmVoiceCatalog.defaultPath;
  String _selectedVoiceLabel = AlarmVoiceCatalog.defaultLabel;
  String? _currentlyPlayingPath;

  @override
  void initState() {
    super.initState();
    final edit = widget.editing;
    if (edit != null) {
      _hour = edit.hour;
      _minute = edit.minute;
      _selectedVoicePath = edit.voiceAssetPath;
      _selectedVoiceLabel = edit.voiceLabel;
    }
    _previewPlayer = AudioPlayer();
    _playerStateSub = _previewPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed ||
          state.processingState == ProcessingState.idle) {
        setState(() => _currentlyPlayingPath = null);
      }
    });
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 920),
    )..forward();
    _hourController = FixedExtentScrollController(initialItem: _hour);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    unawaited(_previewPlayer.stop());
    _previewPlayer.dispose();
    _entryController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  Future<void> _stopPreview() async {
    await _previewPlayer.stop();
    if (!mounted) return;
    setState(() => _currentlyPlayingPath = null);
  }

  Future<void> _playVoicePreview(String assetPath) async {
    try {
      if (_currentlyPlayingPath == assetPath) {
        await _stopPreview();
        return;
      }

      await _previewPlayer.stop();
      await _previewPlayer.setAsset(assetPath);
      await _previewPlayer.seek(Duration.zero);
      await _previewPlayer.play();
      if (!mounted) return;
      setState(() => _currentlyPlayingPath = assetPath);
    } catch (_) {
      if (!mounted) return;
      setState(() => _currentlyPlayingPath = null);
    }
  }

  String _two(int n) => n.toString().padLeft(2, '0');
  Animation<double> _fadeAnim(double begin, double end) => CurvedAnimation(
        parent: _entryController,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      );

  Animation<double> _scaleAnim(double begin, double end) =>
      Tween<double>(begin: 0.82, end: 1.0).animate(
        CurvedAnimation(
          parent: _entryController,
          curve: Interval(begin, end, curve: Curves.easeOutBack),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        unawaited(
          _stopPreview().then((_) {
            if (!context.mounted) return;
            Navigator.of(context).pop();
          }),
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF140B2A),
        body: Stack(
          children: [
            const HomeGradientBackground(),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 8.h),
                    child: Row(
                      children: [
                        FadeTransition(
                          opacity: _fadeAnim(0.0, 0.42),
                          child: ScaleTransition(
                            scale: _scaleAnim(0.0, 0.42),
                            child: _RoundActionButton(
                              icon: CupertinoIcons.clear,
                              onTap: () async {
                                await _stopPreview();
                                if (!context.mounted) return;
                                Navigator.of(context).maybePop();
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: FadeTransition(
                            opacity: _fadeAnim(0.12, 0.55),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, -0.12),
                                end: Offset.zero,
                              ).animate(_fadeAnim(0.12, 0.55)),
                              child: Text(
                                widget.editing == null
                                    ? "Budilnik qo'shish"
                                    : "Budilnikni tahrirlash",
                                textAlign: TextAlign.center,
                                style: AppTextStyles.body20w7.copyWith(
                                  color: Colors.white.withValues(alpha: 0.95),
                                ),
                              ),
                            ),
                          ),
                        ),
                        FadeTransition(
                          opacity: _fadeAnim(0.18, 0.58),
                          child: ScaleTransition(
                            scale: _scaleAnim(0.18, 0.58),
                            child: _RoundActionButton(
                              icon: CupertinoIcons.check_mark,
                              filled: true,
                              onTap: () async {
                                await _stopPreview();
                                if (!context.mounted) return;
                                Navigator.of(context).pop(
                                  AlarmFormResult.saved(
                                    AlarmDraft(
                                      hour: _hour,
                                      minute: _minute,
                                      voiceAssetPath: _selectedVoicePath,
                                      voiceLabel: _selectedVoiceLabel,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FadeTransition(
                    opacity: _fadeAnim(0.08, 0.5),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Soat va daqiqani tanlang",
                          style: AppTextStyles.body13w4.copyWith(
                            color: Colors.white.withValues(alpha: 0.66),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnim(0.28, 1.0),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.14),
                          end: Offset.zero,
                        ).animate(_fadeAnim(0.28, 1.0)),
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.94, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _entryController,
                              curve: Interval(0.28, 1.0, curve: Curves.easeOutCubic),
                            ),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned.fill(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            height: 56.h,
                                            margin: EdgeInsets.symmetric(horizontal: 8.w),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.06),
                                              borderRadius: BorderRadius.circular(18.r),
                                              border: Border.all(
                                                color: Colors.white.withValues(alpha: 0.10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CupertinoPicker(
                                              scrollController: _hourController,
                                              itemExtent: 56.h,
                                              diameterRatio: 1.25,
                                              squeeze: 1.12,
                                              useMagnifier: true,
                                              magnification: 1.02,
                                              selectionOverlay: const SizedBox.shrink(),
                                              onSelectedItemChanged: (v) => setState(() => _hour = v),
                                              children: List.generate(
                                                24,
                                                (i) => Center(
                                                  child: Text(
                                                    _two(i),
                                                    style: AppTextStyles.body40w5.copyWith(
                                                      color: Colors.white.withValues(alpha: 0.92),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: CupertinoPicker(
                                              scrollController: _minuteController,
                                              itemExtent: 56.h,
                                              diameterRatio: 1.25,
                                              squeeze: 1.12,
                                              useMagnifier: true,
                                              magnification: 1.02,
                                              selectionOverlay: const SizedBox.shrink(),
                                              onSelectedItemChanged: (v) => setState(() => _minute = v),
                                              children: List.generate(
                                                60,
                                                (i) => Center(
                                                  child: Text(
                                                    _two(i),
                                                    style: AppTextStyles.body40w5.copyWith(
                                                      color: Colors.white.withValues(alpha: 0.92),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              FadeTransition(
                                opacity: _fadeAnim(0.45, 1.0),
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.08),
                                    end: Offset.zero,
                                  ).animate(_fadeAnim(0.45, 1.0)),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Budilnik ovozi",
                                          style: AppTextStyles.body14w6.copyWith(
                                            color: Colors.white.withValues(alpha: 0.88),
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        ...AlarmVoiceCatalog.options.map((e) {
                                          final selected = e.path == _selectedVoicePath;
                                          final isPlaying = e.path == _currentlyPlayingPath;
                                          return Padding(
                                            padding: EdgeInsets.only(bottom: 8.h),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(14.r),
                                                color: Colors.white.withValues(alpha: 0.06),
                                                border: Border.all(
                                                  color: selected
                                                      ? AppColors.c842D5F.withValues(alpha: 0.85)
                                                      : Colors.white.withValues(alpha: 0.10),
                                                  width: selected ? 1.5 : 1,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      borderRadius: BorderRadius.circular(12.r),
                                                      onTap: () => _playVoicePreview(e.path),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(10.w),
                                                        child: Icon(
                                                          isPlaying
                                                              ? CupertinoIcons.stop_fill
                                                              : CupertinoIcons.play_arrow_solid,
                                                          size: 22.sp,
                                                          color: Colors.white.withValues(alpha: 0.92),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            _selectedVoicePath = e.path;
                                                            _selectedVoiceLabel = e.label;
                                                          });
                                                        },
                                                        child: Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 14.h),
                                                          child: Align(
                                                            alignment: Alignment.centerLeft,
                                                            child: Text(
                                                              e.label,
                                                              style: AppTextStyles.body15w5.copyWith(
                                                                color: Colors.white.withValues(alpha: 0.92),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  if (selected)
                                                    Padding(
                                                      padding: EdgeInsets.only(right: 12.w),
                                                      child: Icon(
                                                        CupertinoIcons.check_mark_circled_solid,
                                                        size: 22.sp,
                                                        color: AppColors.c842D5F,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                        SizedBox(height: 4.h),
                                        Text(
                                          "Play bilan tinglang, keyin yoqqan qatorni bosing",
                                          style: AppTextStyles.body11w4.copyWith(
                                            color: Colors.white.withValues(alpha: 0.48),
                                          ),
                                        ),
                                        if (widget.editing != null) ...[
                                          SizedBox(height: 20.h),
                                          Center(
                                            child: TextButton(
                                              onPressed: () async {
                                                await _stopPreview();
                                                if (!context.mounted) return;
                                                Navigator.of(context).pop(
                                                  const AlarmFormResult.deleted(),
                                                );
                                              },
                                              child: Text(
                                                "Budilnikni o'chirish",
                                                style: AppTextStyles.body15w6.copyWith(
                                                  color: const Color(0xFFFF6B6B),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58.w,
      width: 58.w,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(29.r),
          child: Ink(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? AppColors.c842D5F : Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                color: filled
                    ? AppColors.c842D5F.withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.12),
              ),
              boxShadow: filled
                  ? const [
                      BoxShadow(
                        color: Color(0x33842D5F),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                icon,
                size: 28.sp,
                color: filled ? Colors.white : Colors.white.withValues(alpha: 0.92),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
