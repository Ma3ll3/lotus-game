import 'package:flutter/material.dart';
import 'package:lotus/ui/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_language_words/multi_language_words.dart';

class InfinyModePage extends StatelessWidget {
  const InfinyModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Image.asset(
                "assets/Logo_all.png",
                width: double.infinity,
                height: 52,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.star_outline, size: 32);
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showGameRules(context),
              tooltip: 'Règles du jeu',
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Mode Infini',
                  style: context.texts.h1
                      .copyWith(color: context.colors.secondary),
                ),
                const SizedBox(height: 40),
                Text(
                  'Choisir la langue',
                  style: context.texts.bodyLarge.copyWith(
                    color: context.colors.onPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // Boutons de langue
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLanguageButton(
                      context,
                      'English',
                      Language.english,
                      '/infiny-wordle',
                      'assets/english.png',
                    ),
                    const SizedBox(height: 16),
                    _buildLanguageButton(
                      context,
                      'Français',
                      Language.french,
                      '/infiny-wordle',
                      'assets/francais.png',
                    ),
                    const SizedBox(height: 16),
                    _buildLanguageButton(
                      context,
                      'Italiano',
                      Language.italian,
                      '/infiny-wordle',
                      'assets/italiano.png',
                    ),
                    const SizedBox(height: 16),
                    _buildLanguageButton(
                      context,
                      'Español',
                      Language.spanish,
                      '/infiny-wordle',
                      'assets/espanol.png',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(
    BuildContext context,
    String label,
    Language language,
    String route,
    String imageAsset,
  ) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: () {
          // Passer la langue sélectionnée en paramètre direct
          context.go(route, extra: language);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.primary,
          foregroundColor: context.colors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Image.asset(
                  imageAsset,
                  width: 32,
                  height: 32,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.language, size: 32);
                  },
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: context.texts.bodyBold.copyWith(
                    color: context.colors.onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showGameRules(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(12),
          title: Text('Règles du jeu',
              style:
                  context.texts.h3.copyWith(color: context.colors.secondary)),
          content: Text(
            'Trouvez le mot secret en 6 tentatives maximum.\n\n'
            '🟩 Lettre correcte et bien placée\n'
            '🟨 Lettre correcte mais mal placée\n'
            '⬛ Lettre incorrecte\n\n'
            'Bonne chance !',
            style: context.texts.body.copyWith(
              color: context.colors.onPrimary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  Text('OK', style: TextStyle(color: context.colors.onPrimary)),
            ),
          ],
        );
      },
    );
  }
}
