import 'package:flutter/material.dart';
import 'package:lotus/ui/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_language_words/multi_language_words.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lotus/services/user_service.dart';

class DailyPage extends StatefulWidget {
  const DailyPage({super.key});

  @override
  State<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<Language, bool?> _playedToday = {};
  bool _allLanguagesPlayed = false;

  final List<Language> languages = [
    Language.english,
    Language.french,
    Language.italian,
    Language.spanish
  ];

  @override
  void initState() {
    super.initState();
    // Forcer la réinitialisation du cache pour s'assurer d'avoir le bon utilisateur
    UserService.forceRefreshUserId();
    _checkAllLanguagesStatus();
  }

  Future<void> _checkAllLanguagesStatus() async {
    for (var language in languages) {
      final hasPlayed = await _checkIfPlayedToday(language);
      _playedToday[language] = hasPlayed;
    }

    // Vérifier si toutes les langues ont été jouées
    _allLanguagesPlayed = _playedToday.values.every((played) => played == true);

    setState(() {});
  }

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
                  'Mot du jour',
                  style: context.texts.h1
                      .copyWith(color: context.colors.secondary),
                ),
                const SizedBox(height: 40),
                Text(
                  _allLanguagesPlayed
                      ? 'Reviens demain !'
                      : 'Choisir la langue',
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
                      '/daily-wordle',
                      'assets/english.png',
                    ),
                    const SizedBox(height: 16),
                    _buildLanguageButton(
                      context,
                      'Français',
                      Language.french,
                      '/daily-wordle',
                      'assets/francais.png',
                    ),
                    const SizedBox(height: 16),
                    _buildLanguageButton(
                      context,
                      'Italiano',
                      Language.italian,
                      '/daily-wordle',
                      'assets/italiano.png',
                    ),
                    const SizedBox(height: 16),
                    _buildLanguageButton(
                      context,
                      'Español',
                      Language.spanish,
                      '/daily-wordle',
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
    final isPlayed = _playedToday[language] ?? false;

    return SizedBox(
      width: 210,
      child: ElevatedButton(
        onPressed: () async {
          // Vérifier si l'utilisateur a déjà joué aujourd'hui pour cette langue
          final hasPlayedToday = await _checkIfPlayedToday(language);

          if (hasPlayedToday) {
            _showAlreadyPlayedDialog(context);
          } else {
            // Passer la langue sélectionnée en paramètre direct
            context.go(route, extra: language);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isPlayed ? Colors.grey.shade400 : context.colors.primary,
          foregroundColor:
              isPlayed ? Colors.grey.shade600 : context.colors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: isPlayed ? 0 : 2,
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
                    color: isPlayed
                        ? Colors.grey.shade600
                        : context.colors.onPrimary,
                  ),
                ),
              ],
            ),
            if (isPlayed)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> _checkIfPlayedToday(Language language) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      String userId = UserService.getUserId();

      final existingScore = await _firestore
          .collection('scores')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: today)
          .where('lang', isEqualTo: language.name.toLowerCase())
          .get();

      return existingScore.docs.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification du score: $e');
      return false;
    }
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

  void _showAlreadyPlayedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(12),
          title: Text('Jeu déjà terminé',
              style:
                  context.texts.h3.copyWith(color: context.colors.secondary)),
          content: Text(
            'Tu as déjà joué aujourd\'hui pour cette langue. Reviens demain pour une nouvelle partie !',
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
