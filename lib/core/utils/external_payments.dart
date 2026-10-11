import 'dart:io';

/// iOS'da tashqi to‘lov (Payme) va narxlar ko‘rsatilmaydi: Apple raqamli kontentni ilova ichida
/// boshqa to‘lov tizimi orqali sotishga ruxsat bermaydi. Shu sababli iOS'da «To‘plamlar» tabi ham
/// yashirin (`TabBoxController.isSubscriptionVisible`).
bool hideExternalPayments() => Platform.isIOS;
