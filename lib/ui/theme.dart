import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.surface,
    required this.onPrimary,
    required this.secondaryContainer,
    required this.error,
  });

  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color surface;
  final Color onPrimary;
  final Color secondaryContainer;
  final Color error;

  @override
  ThemeExtension<AppColors> copyWith({
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? surface,
    Color? onPrimary,
    Color? secondaryContainer,
    Color? error,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      surface: surface ?? this.surface,
      onPrimary: onPrimary ?? this.onPrimary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      error: error ?? this.error,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(
    covariant ThemeExtension<AppColors>? other,
    double t,
  ) {
    if (other is! AppColors) {
      return this;
    }

    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      error: Color.lerp(error, other.error, t)!,
      secondaryContainer: Color.lerp(
        secondaryContainer,
        other.secondaryContainer,
        t,
      )!,
    );
  }

  factory AppColors.base() => const AppColors(
        primary: Color(0xFF0C345A),
        secondary: Color(0xFFF4D35E),
        tertiary: Color(0xFFF6832D),
        surface: Color(0xFF071F36),
        onPrimary: Color(0xFFFAF0CA),
        secondaryContainer: Color(0xFF72A840),
        error: Color(0xFFD50000),
      );
}

class AppTexts extends ThemeExtension<AppTexts> {
  const AppTexts({
    required this.h1,
    required this.h2,
    required this.h3,
    required this.h4,
    required this.h5,
    required this.h6,
    required this.body,
    required this.bodyBold,
    required this.bodyItalic,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
  });

  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle h4;
  final TextStyle h5;
  final TextStyle h6;
  final TextStyle body;
  final TextStyle bodyBold;
  final TextStyle bodyItalic;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;

  @override
  ThemeExtension<AppTexts> copyWith({
    TextStyle? h1,
    TextStyle? h2,
    TextStyle? h3,
    TextStyle? h4,
    TextStyle? h5,
    TextStyle? h6,
    TextStyle? body,
    TextStyle? bodyBold,
    TextStyle? bodyItalic,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
  }) {
    return AppTexts(
      h1: h1 ?? this.h1,
      h2: h2 ?? this.h2,
      h3: h3 ?? this.h3,
      h4: h4 ?? this.h4,
      h5: h5 ?? this.h5,
      h6: h6 ?? this.h6,
      body: body ?? this.body,
      bodyBold: bodyBold ?? this.bodyBold,
      bodyItalic: bodyItalic ?? this.bodyItalic,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
    );
  }

  @override
  ThemeExtension<AppTexts> lerp(
    covariant ThemeExtension<AppTexts>? other,
    double t,
  ) {
    if (other is! AppTexts) {
      return this;
    }

    return AppTexts(
      h1: TextStyle.lerp(h1, other.h1, t)!,
      h2: TextStyle.lerp(h2, other.h2, t)!,
      h3: TextStyle.lerp(h3, other.h3, t)!,
      h4: TextStyle.lerp(h4, other.h4, t)!,
      h5: TextStyle.lerp(h5, other.h5, t)!,
      h6: TextStyle.lerp(h6, other.h6, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodyBold: TextStyle.lerp(bodyBold, other.bodyBold, t)!,
      bodyItalic: TextStyle.lerp(bodyItalic, other.bodyItalic, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
    );
  }

  factory AppTexts.base() => const AppTexts(
        h1: TextStyle(
          fontFamily: 'Pally',
          fontWeight: FontWeight.w700,
          fontSize: 48,
        ),
        h2: TextStyle(
          fontFamily: 'Pally',
          fontWeight: FontWeight.w500,
          fontSize: 38,
        ),
        h3: TextStyle(
          fontFamily: 'Pally',
          fontWeight: FontWeight.w500,
          fontSize: 36,
        ),
        h4: TextStyle(
          fontFamily: 'Satoshi',
          fontWeight: FontWeight.w900,
          fontSize: 30,
        ),
        h5: TextStyle(
          fontFamily: 'Satoshi',
          fontWeight: FontWeight.w700,
          fontSize: 26,
        ),
        h6: TextStyle(
          fontFamily: 'Satoshi',
          fontWeight: FontWeight.w500,
          fontSize: 22,
        ),
        body: TextStyle(fontFamily: 'Satoshi', fontSize: 16),
        bodyBold: TextStyle(
          fontFamily: 'Satoshi',
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
        bodyItalic: TextStyle(
          fontFamily: 'Satoshi',
          fontStyle: FontStyle.italic,
          fontSize: 16,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Satoshi',
          fontWeight: FontWeight.w500,
          fontSize: 30,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Satoshi',
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Satoshi',
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Satoshi',
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
      );
}

extension ThemeTexts on BuildContext {
  AppTexts get texts => Theme.of(this).extension<AppTexts>()!;
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

extension AppColorsMaterialX on AppColors {
  ColorScheme toColorScheme({Brightness brightness = Brightness.dark}) {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onPrimary,
      tertiary: tertiary,
      onTertiary: onPrimary,
      surface: surface,
      onSurface: onPrimary,
      error: error,
      onError: onPrimary,
    );
  }
}
