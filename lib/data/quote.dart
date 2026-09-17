class DailyQuote {
  final String zh;
  final String en;

  const DailyQuote({
    required this.zh,
    required this.en,
  });

  static const List<DailyQuote> quotes = [
    DailyQuote(
      zh: '真正的改变，不是某一天突然爆发，而是每天多做一点。',
      en: 'Real change is not a sudden explosion, but a little more every day.',
    ),
    DailyQuote(
      zh: '先完成，再完美。',
      en: 'Done is better than perfect.',
    ),
    DailyQuote(
      zh: '你不需要每天都很厉害，但需要每天都向前一点。',
      en: 'You do not need to be great every day, but you need to move forward.',
    ),
    DailyQuote(
      zh: '行动会降低焦虑，等待只会放大焦虑。',
      en: 'Action reduces anxiety. Waiting amplifies it.',
    ),
    DailyQuote(
      zh: '把今天做好，明天自然会变得更容易。',
      en: 'Take care of today, and tomorrow becomes easier.',
    ),
  ];

  static DailyQuote getToday(String key) {
    final index = key.hashCode.abs() % quotes.length;
    return quotes[index];
  }
}