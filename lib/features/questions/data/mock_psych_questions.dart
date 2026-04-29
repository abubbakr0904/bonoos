import '../models/psych_question.dart';

const mockPsychQuestions = <PsychQuestion>[
  PsychQuestion(
    id: 1,
    type: 1,
    isActive: true,
    question: "Bo‘sh vaqtingizda qaysi mashg‘ulotlar sizga zavq bag‘ishlaydi?",
    options: [
      PsychOption(
          id: 1, questionId: 1, score: 0, emoji: "🏀", title: "Sport"),
      PsychOption(
          id: 2, questionId: 1, score: 0, emoji: "🎨", title: "Ijod"),
      PsychOption(
          id: 3, questionId: 1, score: 0, emoji: "📚", title: "O‘qish"),
      PsychOption(
          id: 4, questionId: 1, score: 0, emoji: "✈️", title: "Sayohat"),
      PsychOption(
          id: 5, questionId: 1, score: 0, emoji: "😇", title: "Sokinlik"),
      PsychOption(
          id: 6, questionId: 1, score: 0, emoji: "📝", title: "O‘z ustimda ishlash"),
      PsychOption(
          id: 7, questionId: 1, score: 0, emoji: "🔲", title: "Boshqa narsa"),
    ],
  ),
  PsychQuestion(
    id: 2,
    type: 1,
    isActive: true,
    question: "Odamlar orasida o‘zingizni ko‘proq qanday his qilasiz?",
    options: [
      PsychOption(id: 8, questionId: 2, score: 0, emoji: "✨", title: "Yengil va ochiq"),
      PsychOption(id: 9, questionId: 2, score: 0, emoji: "🙂", title: "Oddiy, vaziyatga qarab"),
      PsychOption(id: 10, questionId: 2, score: 0, emoji: "🫶", title: "Yaqinlarim bo‘lsa tinch"),
      PsychOption(id: 11, questionId: 2, score: 0, emoji: "😶‍🌫️", title: "Biroz tortinchoq"),
    ],
  ),
  PsychQuestion(
    id: 3,
    type: 1,
    isActive: true,
    question: "Stress paytida sizga eng ko‘p nima yordam beradi?",
    options: [
      PsychOption(id: 12, questionId: 3, score: 0, emoji: "🎧", title: "Musiqa"),
      PsychOption(id: 13, questionId: 3, score: 0, emoji: "🚶‍♀️", title: "Yurish / sayr"),
      PsychOption(id: 14, questionId: 3, score: 0, emoji: "🧘‍♀️", title: "Nafas / meditasiya"),
      PsychOption(id: 15, questionId: 3, score: 0, emoji: "💬", title: "Suhbat (yaqin odam)"),
    ],
  ),
  PsychQuestion(
    id: 4,
    type: 1,
    isActive: true,
    question: "Kun rejangiz qanday bo‘lishini yoqtirasiz?",
    options: [
      PsychOption(id: 16, questionId: 4, score: 0, emoji: "🗓️", title: "Aniq reja bilan"),
      PsychOption(id: 17, questionId: 4, score: 0, emoji: "🌿", title: "Erkin, oqim bo‘yicha"),
      PsychOption(id: 18, questionId: 4, score: 0, emoji: "⚖️", title: "Yarim reja, yarim erkin"),
      PsychOption(id: 19, questionId: 4, score: 0, emoji: "🎲", title: "Spontan"),
    ],
  ),
  PsychQuestion(
    id: 5,
    type: 1,
    isActive: true,
    question: "O‘zingizni quvvatlantiradigan muhit qaysi?",
    options: [
      PsychOption(id: 20, questionId: 5, score: 0, emoji: "🏡", title: "Uyda, sokin"),
      PsychOption(id: 21, questionId: 5, score: 0, emoji: "☕️", title: "Kofe-shop / shinam joy"),
      PsychOption(id: 22, questionId: 5, score: 0, emoji: "🌆", title: "Shahar shovqini"),
      PsychOption(id: 23, questionId: 5, score: 0, emoji: "🌊", title: "Tabiat, suv bo‘yida"),
    ],
  ),
  PsychQuestion(
    id: 6,
    type: 1,
    isActive: true,
    question: "Qaror qabul qilayotganda ko‘proq nimaga tayanasiz?",
    options: [
      PsychOption(id: 24, questionId: 6, score: 0, emoji: "🧠", title: "Mantiq"),
      PsychOption(id: 25, questionId: 6, score: 0, emoji: "❤️", title: "His-tuyg‘u"),
      PsychOption(id: 26, questionId: 6, score: 0, emoji: "🧩", title: "Tajriba"),
      PsychOption(id: 27, questionId: 6, score: 0, emoji: "🤝", title: "Maslahat"),
    ],
  ),
  PsychQuestion(
    id: 7,
    type: 1,
    isActive: true,
    question: "Katta maqsadga borishda sizga nima muhimroq?",
    options: [
      PsychOption(id: 28, questionId: 7, score: 0, emoji: "🎯", title: "Natija"),
      PsychOption(id: 29, questionId: 7, score: 0, emoji: "🛤️", title: "Jarayon"),
      PsychOption(id: 30, questionId: 7, score: 0, emoji: "🌟", title: "Ilhom"),
      PsychOption(id: 31, questionId: 7, score: 0, emoji: "🧱", title: "Barqarorlik"),
    ],
  ),
  PsychQuestion(
    id: 8,
    type: 1,
    isActive: true,
    question: "Sizni eng ko‘p motivatsiya qiladigan narsa nima?",
    options: [
      PsychOption(id: 32, questionId: 8, score: 0, emoji: "🏆", title: "Yutuq"),
      PsychOption(id: 33, questionId: 8, score: 0, emoji: "💖", title: "Qo‘llab-quvvatlash"),
      PsychOption(id: 34, questionId: 8, score: 0, emoji: "📈", title: "O‘sish"),
      PsychOption(id: 35, questionId: 8, score: 0, emoji: "🔥", title: "Raqobat"),
    ],
  ),
  PsychQuestion(
    id: 9,
    type: 1,
    isActive: true,
    question: "Kun oxirida o‘zingizni baxtli his qilishingiz uchun nima kerak?",
    options: [
      PsychOption(id: 36, questionId: 9, score: 0, emoji: "✅", title: "Vazifalar tugagan bo‘lsa"),
      PsychOption(id: 37, questionId: 9, score: 0, emoji: "👩‍❤️‍👩", title: "Yaqinlar bilan vaqt"),
      PsychOption(id: 38, questionId: 9, score: 0, emoji: "🌙", title: "Tinch, shinam kech"),
      PsychOption(id: 39, questionId: 9, score: 0, emoji: "🎁", title: "Yangi taassurot"),
    ],
  ),
  PsychQuestion(
    id: 10,
    type: 1,
    isActive: true,
    question: "Qaysi sifatlaringizni kuchaytirishni xohlaysiz?",
    options: [
      PsychOption(id: 40, questionId: 10, score: 0, emoji: "💪", title: "Iroda"),
      PsychOption(id: 41, questionId: 10, score: 0, emoji: "🕊️", title: "Xotirjamlik"),
      PsychOption(id: 42, questionId: 10, score: 0, emoji: "🗣️", title: "Muloqot"),
      PsychOption(id: 43, questionId: 10, score: 0, emoji: "🌱", title: "O‘ziga ishonch"),
    ],
  ),
];

