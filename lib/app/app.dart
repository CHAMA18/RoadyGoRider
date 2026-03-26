import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../screens/rider_experience.dart';
import '../widgets/common_widgets.dart';
import 'localization.dart';
import 'theme.dart';

class RoadyGoRiderApp extends StatefulWidget {
  const RoadyGoRiderApp({super.key});

  @override
  State<RoadyGoRiderApp> createState() => _RoadyGoRiderAppState();

  static RoadyGoThemeScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<RoadyGoThemeScope>();
    assert(scope != null, 'No theme scope found in context');
    return scope!;
  }
}

class _RoadyGoRiderAppState extends State<RoadyGoRiderApp> {
  ThemeMode _themeMode = ThemeMode.light;
  String _selectedLanguage = 'English';

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  void _setSelectedLanguage(String language) {
    setState(() => _selectedLanguage = language);
  }

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      title: AppLocalizations(_selectedLanguage).text(AppStrings.appTitle),
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildDarkAppTheme(),
      themeMode: _themeMode,
      builder: (context, child) {
        if (!kIsWeb || child == null) {
          return child ?? const SizedBox.shrink();
        }

        return _WebLockedViewport(child: child);
      },
      home: const RiderExperience(),
    );

    return RoadyGoThemeScope(
      themeMode: _themeMode,
      setThemeMode: _setThemeMode,
      selectedLanguage: _selectedLanguage,
      setSelectedLanguage: _setSelectedLanguage,
      child: app,
    );
  }
}

class RoadyGoThemeScope extends InheritedWidget {
  const RoadyGoThemeScope({
    super.key,
    required this.themeMode,
    required this.setThemeMode,
    required this.selectedLanguage,
    required this.setSelectedLanguage,
    required super.child,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> setThemeMode;
  final String selectedLanguage;
  final ValueChanged<String> setSelectedLanguage;

  @override
  bool updateShouldNotify(RoadyGoThemeScope oldWidget) =>
      themeMode != oldWidget.themeMode ||
      selectedLanguage != oldWidget.selectedLanguage;
}

class _WebLockedViewport extends StatelessWidget {
  const _WebLockedViewport({required this.child});

  static const Size _iphone14ProMaxPortrait = Size(430, 932);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE5E7EB),
      child: Center(
        child: PhoneFrame(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: _iphone14ProMaxPortrait.width,
              height: _iphone14ProMaxPortrait.height,
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(size: _iphone14ProMaxPortrait),
                child: ClipRect(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
