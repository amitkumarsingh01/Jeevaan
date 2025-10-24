import 'package:flutter/material.dart';
import '../models/language.dart';
import '../services/language_service.dart';

class LanguageSelector extends StatelessWidget {
  final LanguageService languageService;

  const LanguageSelector({
    super.key,
    required this.languageService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageService.translate('select_language'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...SupportedLanguage.values.map((language) {
          final isSelected = languageService.currentLanguage == language;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: isSelected ? 4 : 1,
            color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : null,
            child: ListTile(
              leading: Text(
                language.flag,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(
                language.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
              onTap: () {
                languageService.changeLanguage(language);
              },
            ),
          );
        }).toList(),
      ],
    );
  }
}
