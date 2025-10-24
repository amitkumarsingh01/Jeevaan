enum SupportedLanguage {
  english('en', 'English', '🇺🇸'),
  hindi('hi', 'हिंदी', '🇮🇳'),
  kannada('kn', 'ಕನ್ನಡ', '🇮🇳'),
  telugu('te', 'తెలుగు', '🇮🇳');

  const SupportedLanguage(this.code, this.name, this.flag);

  final String code;
  final String name;
  final String flag;

  static SupportedLanguage fromCode(String code) {
    return SupportedLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => SupportedLanguage.english,
    );
  }
}
