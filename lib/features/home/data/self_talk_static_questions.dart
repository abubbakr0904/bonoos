import 'package:bonoos/features/home/domain/entity/topic_question.dart';

/// `true` bo‘lsa API o‘rniga statik savollar (UI tekshiruvi). Ishlash uchun `false`.
const bool kSelfTalkPreviewStaticOnly = false;

/// Namoyish uchun bir nechta savol (uz / ru / en).
List<TopicQuestion> get selfTalkStaticPreviewQuestions => const [
      TopicQuestion(
        id: 1,
        contentByLocale: {
          'uz': 'Bugun o‘zing bilan eng muloyim gaping qaysi bo‘lishi mumkin?',
          'ru': 'Какая самая добрая фраза ты можешь сказать себе сегодня?',
          'en': 'What is the kindest thing you could say to yourself today?',
        },
        sort: 0,
      ),
      TopicQuestion(
        id: 2,
        contentByLocale: {
          'uz': 'Hozirgi paytda tanaing qayerida kuch yoki yengillik his qilyapsan?',
          'ru': 'Где в теле ты сейчас чувствуешь силу или облегчение?',
          'en': 'Where in your body do you feel strength or ease right now?',
        },
        sort: 1,
      ),
      TopicQuestion(
        id: 3,
        contentByLocale: {
          'uz': 'Qaysi bir qoidani vaqtincha qo‘yib yuborsang, osonlashasan?',
          'ru': 'Какое правило ты можешь временно отпустить, чтобы стало легче?',
          'en': 'Which rule could you loosen for a moment to feel lighter?',
        },
        sort: 2,
      ),
      TopicQuestion(
        id: 4,
        contentByLocale: {
          'uz': 'Kim yoki narsa uchun minnatdorligingni ikki jumla bilan yoz.',
          'ru': 'За кого или что ты благодарен(на)? Две короткие фразы.',
          'en': 'Who or what are you grateful for, in two short phrases?',
        },
        sort: 3,
      ),
      TopicQuestion(
        id: 5,
        contentByLocale: {
          'uz': 'Ertaga o‘zingdan nimani kichik qadam bilan kutishing mumkin?',
          'ru': 'Какой маленький шаг ты можешь ожидать от себя завтра?',
          'en': 'What small step might you expect from yourself tomorrow?',
        },
        sort: 4,
      ),
    ];
