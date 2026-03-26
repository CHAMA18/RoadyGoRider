import 'package:flutter/material.dart';

import '../app/app.dart';
import '../app/localization.dart';
import '../widgets/common_widgets.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeScope = RoadyGoRiderApp.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final filteredSections = _languageSections
        .map((section) {
          final languages = section.languages
              .where(
                (language) =>
                    language.name.toLowerCase().contains(_query) ||
                    language.nativeName.toLowerCase().contains(_query),
              )
              .toList();
          return _LanguageSectionData(
            title: section.title,
            languages: languages,
          );
        })
        .where((section) => section.languages.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF020617)
          : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(AppStrings.language),
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr(AppStrings.chooseLanguageDescription),
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? const [Color(0xFF111827), Color(0xFF1E293B)]
                        : const [Color(0xFFFFFBEB), Color(0xFFE0F2FE)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: isDark ? 0.08 : 0.72,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Aa',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr(AppStrings.currentLanguage),
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF475569),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            themeScope.selectedLanguage,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.language_rounded,
                      color: isDark
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFF2563EB),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _LanguageSearchField(
                controller: _searchController,
                onChanged: (value) => setState(() {
                  _query = value.trim().toLowerCase();
                }),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                children: [
                  for (final section in filteredSections) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
                      child: Text(
                        section.title,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    ...section.languages.map(
                      (language) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _LanguageCard(
                          language: language,
                          selected:
                              language.name == themeScope.selectedLanguage,
                          onTap: () =>
                              themeScope.setSelectedLanguage(language.name),
                        ),
                      ),
                    ),
                  ],
                  if (filteredSections.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        context.tr(AppStrings.noLanguagesMatch),
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Center(child: HomeIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSearchField extends StatelessWidget {
  const _LanguageSearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      cursorColor: theme.colorScheme.onSurface,
      decoration: InputDecoration(
        hintText: context.tr(AppStrings.searchLanguages),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFF97316), width: 1.4),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final _LanguageOption language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? const Color(0xFF111827) : const Color(0xFFFFF7ED))
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? const Color(0xFFF97316)
                  : (isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0)),
              width: selected ? 1.6 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFFF97316).withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.10 : 0.04,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFF97316).withValues(alpha: 0.14)
                      : (isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  language.code,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFFF97316)
                        : colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.name,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      language.nativeName,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFF97316)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFFF97316)
                        : (isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFCBD5E1)),
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 18,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageSectionData {
  const _LanguageSectionData({required this.title, required this.languages});

  final String title;
  final List<_LanguageOption> languages;
}

class _LanguageOption {
  const _LanguageOption({
    required this.name,
    required this.nativeName,
    required this.code,
  });

  final String name;
  final String nativeName;
  final String code;
}

const List<_LanguageSectionData> _languageSections = [
  _LanguageSectionData(
    title: 'WIDELY USED',
    languages: [
      _LanguageOption(name: 'English', nativeName: 'English', code: 'EN'),
      _LanguageOption(name: 'French', nativeName: 'Francais', code: 'FR'),
      _LanguageOption(name: 'German', nativeName: 'Deutsch', code: 'DE'),
      _LanguageOption(name: 'Spanish', nativeName: 'Espanol', code: 'ES'),
      _LanguageOption(name: 'Italian', nativeName: 'Italiano', code: 'IT'),
      _LanguageOption(name: 'Portuguese', nativeName: 'Portugues', code: 'PT'),
      _LanguageOption(name: 'Russian', nativeName: 'Russkiy', code: 'RU'),
    ],
  ),
  _LanguageSectionData(
    title: 'NORDIC & BALTIC',
    languages: [
      _LanguageOption(name: 'Danish', nativeName: 'Dansk', code: 'DA'),
      _LanguageOption(name: 'Estonian', nativeName: 'Eesti', code: 'ET'),
      _LanguageOption(name: 'Finnish', nativeName: 'Suomi', code: 'FI'),
      _LanguageOption(name: 'Icelandic', nativeName: 'Islenska', code: 'IS'),
      _LanguageOption(name: 'Latvian', nativeName: 'Latviesu', code: 'LV'),
      _LanguageOption(name: 'Lithuanian', nativeName: 'Lietuviu', code: 'LT'),
      _LanguageOption(name: 'Norwegian', nativeName: 'Norsk', code: 'NO'),
      _LanguageOption(name: 'Swedish', nativeName: 'Svenska', code: 'SV'),
    ],
  ),
  _LanguageSectionData(
    title: 'WESTERN & CENTRAL EUROPE',
    languages: [
      _LanguageOption(name: 'Dutch', nativeName: 'Nederlands', code: 'NL'),
      _LanguageOption(name: 'Irish', nativeName: 'Gaeilge', code: 'GA'),
      _LanguageOption(
        name: 'Luxembourgish',
        nativeName: 'Letzebuergesch',
        code: 'LB',
      ),
      _LanguageOption(name: 'Welsh', nativeName: 'Cymraeg', code: 'CY'),
    ],
  ),
  _LanguageSectionData(
    title: 'SOUTHERN EUROPE',
    languages: [
      _LanguageOption(name: 'Albanian', nativeName: 'Shqip', code: 'SQ'),
      _LanguageOption(name: 'Basque', nativeName: 'Euskara', code: 'EU'),
      _LanguageOption(name: 'Catalan', nativeName: 'Catala', code: 'CA'),
      _LanguageOption(name: 'Croatian', nativeName: 'Hrvatski', code: 'HR'),
      _LanguageOption(name: 'Galician', nativeName: 'Galego', code: 'GL'),
      _LanguageOption(name: 'Greek', nativeName: 'Ellinika', code: 'EL'),
      _LanguageOption(name: 'Maltese', nativeName: 'Malti', code: 'MT'),
      _LanguageOption(name: 'Serbian', nativeName: 'Srpski', code: 'SR'),
      _LanguageOption(name: 'Slovene', nativeName: 'Slovenscina', code: 'SL'),
    ],
  ),
  _LanguageSectionData(
    title: 'EASTERN EUROPE',
    languages: [
      _LanguageOption(
        name: 'Belarusian',
        nativeName: 'Belaruskaya',
        code: 'BE',
      ),
      _LanguageOption(name: 'Bosnian', nativeName: 'Bosanski', code: 'BS'),
      _LanguageOption(name: 'Bulgarian', nativeName: 'Balgarski', code: 'BG'),
      _LanguageOption(name: 'Czech', nativeName: 'Cestina', code: 'CS'),
      _LanguageOption(name: 'Hungarian', nativeName: 'Magyar', code: 'HU'),
      _LanguageOption(name: 'Macedonian', nativeName: 'Makedonski', code: 'MK'),
      _LanguageOption(name: 'Polish', nativeName: 'Polski', code: 'PL'),
      _LanguageOption(name: 'Romanian', nativeName: 'Romana', code: 'RO'),
      _LanguageOption(name: 'Slovak', nativeName: 'Slovencina', code: 'SK'),
      _LanguageOption(name: 'Ukrainian', nativeName: 'Ukrainska', code: 'UK'),
    ],
  ),
  _LanguageSectionData(
    title: 'REGIONAL & MINORITY',
    languages: [
      _LanguageOption(name: 'Armenian', nativeName: 'Hayeren', code: 'HY'),
      _LanguageOption(
        name: 'Azerbaijani',
        nativeName: 'Azarbaycanca',
        code: 'AZ',
      ),
      _LanguageOption(name: 'Breton', nativeName: 'Brezhoneg', code: 'BR'),
      _LanguageOption(name: 'Corsican', nativeName: 'Corsu', code: 'CO'),
      _LanguageOption(name: 'Georgian', nativeName: 'Kartuli', code: 'KA'),
      _LanguageOption(name: 'Kazakh', nativeName: 'Qazaqsa', code: 'KK'),
      _LanguageOption(name: 'Kurdish', nativeName: 'KurdI', code: 'KU'),
      _LanguageOption(name: 'Sami', nativeName: 'Sami', code: 'SE'),
      _LanguageOption(name: 'Tatar', nativeName: 'Tatarca', code: 'TT'),
      _LanguageOption(name: 'Turkish', nativeName: 'Turkce', code: 'TR'),
    ],
  ),
];
