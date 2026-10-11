import 'dart:ui';

import 'package:bonoos/core/resources/assets/images/app_images.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/features/chat/ui/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bo'limlar → «Biz haqimizda» — [landingUrl] bilan bir xil kontent va uslub.
class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  static const String routeName = '/sections/about-us';
  static const String landingUrl = 'https://bonoos.uz/';

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  bool _animateIn = false;
  String _appVersion = '';

  static const _highlights = <String>[
    '4 til qo‘llab-quvvatlanadi',
    'PIN va Face ID himoyasi',
    'Har kuni yangi motivatsiya',
  ];

  static const _philosophyPoints = <String>[
    'Hukm qilmaydigan, iliq ohang',
    'Kuniga bir necha daqiqa yetarli',
    'Shaxsiy va xavfsiz — faqat siz uchun',
  ];

  static const _features = <_FeatureItem>[
    _FeatureItem(
      icon: CupertinoIcons.smiley_fill,
      title: 'Kayfiyat kuzatuvi',
      subtitle:
          'Har kuni bir bosishda kayfiyatingizni belgilang — vaqt o‘tishi bilan o‘zingizni yaxshiroq tushunasiz.',
    ),
    _FeatureItem(
      icon: CupertinoIcons.book_fill,
      title: 'Shukronalik daftari',
      subtitle:
          'Kichik yaxshiliklarni yozib boring, teglang va istalgan payt qayta o‘qib, kayfiyatingizni ko‘taring.',
    ),
    _FeatureItem(
      icon: CupertinoIcons.wind,
      title: 'Nafas mashqlari',
      subtitle:
          'Deep relaxation, Stress relief, Energy boost — har bir holatga mos yo‘riqnoma.',
    ),
    _FeatureItem(
      icon: CupertinoIcons.sparkles,
      title: 'Meditatsiya va melodiyalar',
      subtitle:
          'Zen meditatsiya, okean to‘lqinlari, yomg‘ir ovozi va tinch pianino.',
    ),
    _FeatureItem(
      icon: CupertinoIcons.gift_fill,
      title: 'Kun sovg‘asi',
      subtitle:
          'Har kuni bitta motivatsion xabar ochiladi — kuningizni yorqin qiladigan ritual.',
    ),
    _FeatureItem(
      icon: CupertinoIcons.question_circle_fill,
      title: 'Psixologik testlar',
      subtitle:
          'Qiziqarli emoji-savollar orqali o‘zingizni yanada chuqurroq bilib boring.',
    ),
  ];

  static const _steps = <_StepItem>[
    _StepItem(
      number: '1',
      title: 'Yuklab oling',
      subtitle: 'Bonoos’ni App Store yoki Google Play’dan bir necha soniyada o‘rnating.',
    ),
    _StepItem(
      number: '2',
      title: 'Kayfiyatingizni belgilang',
      subtitle: 'Har kuni bosh ekranda kayfiyatingizni tanlang va shukronalik yozing.',
    ),
    _StepItem(
      number: '3',
      title: 'Hamrohingizdan bahramand bo‘ling',
      subtitle: 'Nafas mashqlari, tinch ohanglar va kunlik sovg‘alar — doim yoningizda.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadVersion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _animateIn = true);
    });
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _appVersion = info.version);
    } catch (_) {
      if (!mounted) return;
      setState(() => _appVersion = '1.0.0');
    }
  }

  Future<void> _openLanding() => _openUrl(AboutUsScreen.landingUrl);

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veb-saytni ochib bo‘lmadi',
            style: AppTextStyles.body14w5.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.c842D5F,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leadingWidth: 62.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 14.w, top: 6.h, bottom: 6.h),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: () => Navigator.of(context).maybePop(),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                ),
                child: Icon(
                  CupertinoIcons.chevron_left,
                  color: Colors.white.withValues(alpha: 0.94),
                  size: 19.sp,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Biz haqimizda',
          style: AppTextStyles.body18w6.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 28.h),
          children: [
            _AnimatedSection(
              animateIn: _animateIn,
              delayMs: 0,
              child: _LandingHeroCard(onOpenLanding: _openLanding),
            ),
            SizedBox(height: 12.h),
            _AnimatedSection(
              animateIn: _animateIn,
              delayMs: 60,
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _highlights
                    .map((text) => _HighlightChip(label: text))
                    .toList(),
              ),
            ),
            SizedBox(height: 16.h),
            _AnimatedSection(
              animateIn: _animateIn,
              delayMs: 120,
              child: _SectionHeader(
                eyebrow: 'Bizning falsafamiz',
                title: 'Har bir kichik yaxshilik —\nkatta baxtning boshlanishi',
              ),
            ),
            SizedBox(height: 12.h),
            _AnimatedSection(
              animateIn: _animateIn,
              delayMs: 160,
              child: _InfoCard(
                body:
                    'Bonoos — sizni hukm qilmaydigan, shoshiltirmaydigan shaxsiy hamrohingiz. '
                    'U sizga psixolog yoki shifokor bo‘lishga da’vo qilmaydi — u shunchaki har kuni yoningizda bo‘ladi: '
                    'kayfiyatingizni so‘raydi, minnatdorchilik yozishga taklif qiladi, nafas olishni eslatadi va tinch lahzalar sovg‘a qiladi.\n\n'
                    'Chunki hayotning har bir kichik lahzasi — allaqachon bonus.',
                child: Column(
                  children: [
                    for (var i = 0; i < _philosophyPoints.length; i++) ...[
                      if (i > 0) SizedBox(height: 8.h),
                      _BulletRow(text: _philosophyPoints[i]),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            _AnimatedSection(
              animateIn: _animateIn,
              delayMs: 220,
              child: const _SectionHeader(
                eyebrow: 'Imkoniyatlar',
                title: 'Kuningizga kerak bo‘lgan\nhamma narsa — bir joyda',
              ),
            ),
            SizedBox(height: 12.h),
            ...List.generate(_features.length, (i) {
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _AnimatedSection(
                  animateIn: _animateIn,
                  delayMs: 260 + i * 40,
                  child: _FeatureRow(item: _features[i]),
                ),
              );
            }),
            SizedBox(height: 12.h),
            _AnimatedSection(
              animateIn: _animateIn,
              delayMs: 520,
              child: const _SectionHeader(
                eyebrow: 'Jarayon',
                title: 'Qanday ishlaydi?',
              ),
            ),
            SizedBox(height: 12.h),
            ...List.generate(_steps.length, (i) {
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _AnimatedSection(
                  animateIn: _animateIn,
                  delayMs: 560 + i * 50,
                  child: _StepRow(item: _steps[i]),
                ),
              );
            }),
            SizedBox(height: 16.h),
            _AnimatedSection(
              animateIn: _animateIn,
              delayMs: 700,
              child: _QuoteCard(),
            ),
            SizedBox(height: 16.h),
            _AnimatedSection(
              animateIn: _animateIn,
              delayMs: 760,
              child: _LandingCtaCard(onOpenLanding: _openLanding),
            ),
            SizedBox(height: 12.h),
            _AnimatedSection(
              animateIn: _animateIn,
              delayMs: 820,
              child: _SecondaryActionButton(
                label: 'Qo‘llab-quvvatlash chatiga yozish',
                icon: CupertinoIcons.headphones,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            _AnimatedSection(
              animateIn: _animateIn,
              delayMs: 880,
              child: Center(
                child: Text(
                  _appVersion.isEmpty
                      ? 'Bonoos · Hayot bu bonus'
                      : 'Bonoos · v$_appVersion',
                  style: AppTextStyles.body12w4.copyWith(
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LandingHeroCard extends StatelessWidget {
  const _LandingHeroCard({required this.onOpenLanding});

  final VoidCallback onOpenLanding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenLanding,
        borderRadius: BorderRadius.circular(24.r),
        splashColor: Colors.white.withValues(alpha: 0.08),
        child: Ink(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20.w, 26.h, 20.w, 22.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.14),
                AppColors.c55004D.withValues(alpha: 0.35),
                AppColors.c30215A.withValues(alpha: 0.45),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22842D5F),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -18.w,
                top: -12.h,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                  child: Container(
                    width: 110.w,
                    height: 110.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Image.asset(
                    AppImages.splashImage,
                    width: 96.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'Hayot bu bonus',
                    style: AppTextStyles.body13w5.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Har kuningiz —\nkichik bir bonus',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DancingScript',
                      color: Colors.white.withValues(alpha: 0.98),
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Kayfiyatingizni kuzating, minnatdorchilik yozing, nafas oling va '
                    'tinchlantiruvchi ohanglar ostida dam oling — barchasi bitta iliq, '
                    'sizga hamroh bo‘ladigan ilovada.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body14w5.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  _PrimaryLandingButton(onTap: onOpenLanding),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryLandingButton extends StatelessWidget {
  const _PrimaryLandingButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Ink(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.globe,
                color: AppColors.mainBgColor,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  'Veb-saytni ochish',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body15w6.copyWith(
                    color: AppColors.mainBgColor,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                CupertinoIcons.arrow_up_right,
                color: AppColors.mainBgColor.withValues(alpha: 0.75),
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandingCtaCard extends StatelessWidget {
  const _LandingCtaCard({required this.onOpenLanding});

  final VoidCallback onOpenLanding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.c842D5F.withValues(alpha: 0.55),
            AppColors.c55004D.withValues(alpha: 0.45),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        children: [
          Text(
            'Bugundan boshlang —\no‘zingizga vaqt ajrating',
            textAlign: TextAlign.center,
            style: AppTextStyles.body18w6.copyWith(
              color: Colors.white.withValues(alpha: 0.96),
              height: 1.3,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Bonoos veb-saytida barcha imkoniyatlar, rejalar va savollarga javoblarni ko‘ring.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body13w4.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),
          _PrimaryLandingButton(onTap: onOpenLanding),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.eyebrow,
    required this.title,
  });

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: AppTextStyles.body11w6.copyWith(
            color: Colors.white.withValues(alpha: 0.52),
            letterSpacing: 1.1,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          title,
          style: AppTextStyles.body20w7.copyWith(
            color: Colors.white.withValues(alpha: 0.96),
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _HighlightChip extends StatelessWidget {
  const _HighlightChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: AppTextStyles.body12w5.copyWith(
          color: Colors.white.withValues(alpha: 0.82),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.body,
    this.child,
  });

  final String body;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            body,
            style: AppTextStyles.body14w5.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
              height: 1.48,
            ),
          ),
          if (child != null) ...[
            SizedBox(height: 14.h),
            child!,
          ],
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 6.h),
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.c842D5F.withValues(alpha: 0.9),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body13w5.copyWith(
              color: Colors.white.withValues(alpha: 0.84),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.item});

  final _FeatureItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: AppColors.c842D5F.withValues(alpha: 0.24),
            ),
            child: Icon(item.icon, color: Colors.white, size: 19.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.body15w6.copyWith(
                    color: Colors.white.withValues(alpha: 0.94),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.subtitle,
                  style: AppTextStyles.body13w4.copyWith(
                    color: Colors.white.withValues(alpha: 0.62),
                    height: 1.38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.item});

  final _StepItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.07),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Center(
              child: Text(
                item.number,
                style: AppTextStyles.body14w7.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.body15w6.copyWith(
                    color: Colors.white.withValues(alpha: 0.94),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  item.subtitle,
                  style: AppTextStyles.body13w4.copyWith(
                    color: Colors.white.withValues(alpha: 0.62),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: [
          Text(
            '“',
            style: TextStyle(
              fontFamily: 'DancingScript',
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 42.sp,
              height: 0.8,
            ),
          ),
          Text(
            'Sen hayotingdagi eng to‘g‘ri qarorni qabul qilding...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DancingScript',
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.88), size: 18.sp),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body14w6.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedSection extends StatelessWidget {
  const _AnimatedSection({
    required this.animateIn,
    required this.delayMs,
    required this.child,
  });

  final bool animateIn;
  final int delayMs;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: (320 + delayMs).clamp(320, 900));
    return AnimatedSlide(
      duration: duration,
      curve: Curves.easeOutCubic,
      offset: animateIn ? Offset.zero : const Offset(0, 0.1),
      child: AnimatedOpacity(
        duration: duration,
        opacity: animateIn ? 1 : 0,
        child: child,
      ),
    );
  }
}

class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

class _StepItem {
  const _StepItem({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  final String number;
  final String title;
  final String subtitle;
}
