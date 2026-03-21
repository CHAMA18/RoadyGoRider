import 'package:flutter/material.dart';

import '../app/theme.dart';

class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(40),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2B000000),
                blurRadius: 34,
                offset: Offset(0, 20),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: child,
                ),
                const Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(child: _PhoneTopCover()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneTopCover extends StatelessWidget {
  const _PhoneTopCover();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 132,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

class HomeIndicator extends StatelessWidget {
  const HomeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      height: 6,
      width: 140,
      decoration: BoxDecoration(
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class CircleBack extends StatelessWidget {
  const CircleBack({super.key, this.closeIcon = false});

  final bool closeIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF475569)
        : const Color(0xFFCBD1D9);
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1.4),
        ),
        child: Icon(
          closeIcon ? Icons.close : Icons.arrow_back,
          size: 28,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key, this.title, this.trailing, this.closeIcon = false});

  final String? title;
  final String? trailing;
  final bool closeIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleBack(closeIcon: closeIcon),
              const Spacer(),
              if (trailing != null)
                Text(
                  trailing!,
                  style: TextStyle(
                    fontSize: AppTypography.size,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
            ],
          ),
          if (title != null) ...[
            const SizedBox(height: 22),
            Text(
              title!,
              style: TextStyle(
                fontSize: AppTypography.size,
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class UnderlineText extends StatelessWidget {
  const UnderlineText({super.key, required this.value, this.hint});

  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hintColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF94A3B8)
        : AppColors.slate;
    final showHint = value.isEmpty;
    final textStyle = TextStyle(
      fontSize: AppTypography.size,
      fontWeight: showHint ? FontWeight.w500 : FontWeight.w700,
      color: showHint ? hintColor : colorScheme.onSurface,
    );

    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.onSurface, width: 1),
        ),
      ),
      child: Text(showHint ? (hint ?? '') : value, style: textStyle),
    );
  }
}

class CountryCodeChip extends StatelessWidget {
  const CountryCodeChip({super.key, required this.prefix, required this.flag});

  final String prefix;
  final String flag;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (brightness == Brightness.dark ? Colors.black : Colors.black)
                .withValues(alpha: brightness == Brightness.dark ? 0.22 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: AppTypography.size)),
          const SizedBox(width: 8),
          Text(
            prefix,
            style: TextStyle(
              fontSize: AppTypography.size,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded, color: colorScheme.onSurface),
        ],
      ),
    );
  }
}
