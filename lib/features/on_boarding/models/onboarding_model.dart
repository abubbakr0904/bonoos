class OnboardingModel {
  final String imageAsset;
  final String title;
  final String description;

  OnboardingModel({
    required this.imageAsset,
    required this.title,
    required this.description,
  });
}

final List<OnboardingModel> onboardingPages = [
  OnboardingModel(
    imageAsset: 'assets/images/page1.png',
    title: 'O\'zing bilan uyg\'unlikni boshqlash vaqti keldi',
    description: 'Bu ilova ayollar uchun — ichki kuchingizni uyg\'otish, '
        'o\'zingizni qadrlaш va hayotingizga ijobiy '
        'o\'zgarishlarni jalb qilish uchun yaratilgan.',
  ),
  OnboardingModel(
    imageAsset: 'assets/images/page2.png',
    title: 'Kunlik amaliyotlar bilan boshlang\'',
    description: 'Meditatsiya, yog\'a va motivasiyalar orqali '
        'o\'z-o\'ziga ishonch hosil qiling va ruhiy tinchlikni topganiz.',
  ),
  OnboardingModel(
    imageAsset: 'assets/images/page3.png',
    title: 'O\'z yo\'lida ustun bo\'ling',
    description: 'Har bir kunning muvaffaqiyatini yuzaki kiriting va '
        'o\'z-o\'zini rag\'batlantiring. Katta maqsadlarga erishmak '
        'kichik qadam bilan boshlangan.',
  ),
  OnboardingModel(
    imageAsset: 'assets/images/page4.png',
    title: 'Hamjamiyat bilan birga o\'sish',
    description: 'Boshqa ayollar bilan baham oling, tajribalarni almaшing '
        'va bir-biringizni qo\'llaysing. Birgalik kuchli va ilhomlantiradi.',
  ),
];
