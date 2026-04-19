import 'package:flutter/material.dart';

import '../app/app.dart';
import '../app/localization.dart';
import '../widgets/common_widgets.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  static const Map<String, String> languageMap = {
    'English': 'English',
    'Albanian': 'Shqip',
    'French': 'Français',
    'German': 'Deutsch',
    'Spanish': 'Español',
    'Italian': 'Italiano',
    'Portuguese': 'Português',
    'Dutch': 'Nederlands',
    'Polish': 'Polski',
    'Greek': 'Ελληνικά',
    'Romanian': 'Română',
    'Turkish': 'Türkçe',
    'Russian': 'Русский',
  };

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selectedLanguage;
  late String _currentAppLanguage;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentAppLanguage = RoadyGoRiderApp.of(context).selectedLanguage;
    if (!_isInitialized) {
      _selectedLanguage = LanguageScreen.languageMap.containsKey(_currentAppLanguage) ? _currentAppLanguage : 'English';
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeScope = RoadyGoRiderApp.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          context.tr(AppStrings.language),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: List.generate(LanguageScreen.languageMap.length, (index) {
                        final languageKey = LanguageScreen.languageMap.keys.elementAt(index);
                        final languageName = LanguageScreen.languageMap.values.elementAt(index);
                        final isSelected = languageKey == _selectedLanguage;
                        
                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedLanguage = languageKey;
                                  themeScope.setSelectedLanguage(languageKey);
                                });
                              },
                              borderRadius: BorderRadius.vertical(
                                top: index == 0 ? const Radius.circular(16) : Radius.zero,
                                bottom: index == LanguageScreen.languageMap.length - 1 ? const Radius.circular(16) : Radius.zero,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        languageName,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                      color: isSelected ? const Color(0xFFFF5A00) : const Color(0xFF94A3B8),
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (index < LanguageScreen.languageMap.length - 1)
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: Color(0xFFF1F5F9),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5A00),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                    disabledForegroundColor: const Color(0xFF94A3B8),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.tr(AppStrings.save),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
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

