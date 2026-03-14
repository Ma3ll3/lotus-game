import 'package:flutter/material.dart';
import 'package:lotus/ui/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lotus/services/user_service.dart';

class ScoresPage extends StatefulWidget {
  const ScoresPage({super.key});

  @override
  State<ScoresPage> createState() => _ScoresPageState();
}

class _ScoresPageState extends State<ScoresPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _scores = [];
  List<Map<String, dynamic>> _todayScores = [];
  bool _isLoading = true;
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _currentUserId = UserService.getUserId();
    _loadScores();
  }

  Future<void> _loadScores() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Charger les scores de l'utilisateur connecté
      final QuerySnapshot userScoresSnapshot = await _firestore
          .collection('scores')
          .where('userId', isEqualTo: _currentUserId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      setState(() {
        _scores = userScoresSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        // Filtrer uniquement les scores du jour pour l'utilisateur connecté
        _todayScores =
            _scores.where((score) => score['date'] == today).toList();

        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des scores: $e');
      setState(() => _isLoading = false);
    }
  }

  Map<String, double> _calculateAverages() {
    Map<String, double> averages = {};
    Map<String, List<int>> attemptsByLanguage = {};

    // Calculer les moyennes uniquement pour les scores de l'utilisateur connecté
    for (var score in _scores) {
      final language = score['lang'] as String? ?? 'unknown';
      final attempts = score['nb_try'] as int? ?? 0;

      if (!attemptsByLanguage.containsKey(language)) {
        attemptsByLanguage[language] = [];
      }
      attemptsByLanguage[language]!.add(attempts);
    }

    // Calculer la moyenne pour chaque langue
    attemptsByLanguage.forEach((language, attempts) {
      if (attempts.isNotEmpty) {
        final sum = attempts.reduce((a, b) => a + b);
        averages[language] = sum / attempts.length;
      }
    });

    return averages;
  }

  // Grouper les scores du jour par langue
  Map<String, List<Map<String, dynamic>>> _groupTodayScoresByLanguage() {
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var score in _todayScores) {
      final language = score['lang'] as String? ?? 'unknown';
      if (!grouped.containsKey(language)) {
        grouped[language] = [];
      }
      grouped[language]!.add(score);
    }

    return grouped;
  }

  // Définir l'ordre des langues
  List<String> _getLanguageOrder() {
    return ['english', 'french', 'italian', 'spanish'];
  }

  // Trier les entrées de langue selon l'ordre défini
  List<MapEntry<String, List<Map<String, dynamic>>>> _sortLanguageEntries(
      Map<String, List<Map<String, dynamic>>> grouped) {
    final order = _getLanguageOrder();
    final sortedEntries = <MapEntry<String, List<Map<String, dynamic>>>>[];

    // Ajouter les langues dans l'ordre défini
    for (String lang in order) {
      if (grouped.containsKey(lang)) {
        sortedEntries.add(MapEntry(lang, grouped[lang]!));
      }
    }

    // Ajouter les autres langues non prévues à la fin
    for (var entry in grouped.entries) {
      if (!order.contains(entry.key)) {
        sortedEntries.add(entry);
      }
    }

    return sortedEntries;
  }

  // Trier les moyennes par langue selon l'ordre défini
  List<MapEntry<String, double>> _sortAverageEntries(
      Map<String, double> averages) {
    final order = _getLanguageOrder();
    final sortedEntries = <MapEntry<String, double>>[];

    // Ajouter les langues dans l'ordre défini
    for (String lang in order) {
      if (averages.containsKey(lang)) {
        sortedEntries.add(MapEntry(lang, averages[lang]!));
      }
    }

    // Ajouter les autres langues non prévues à la fin
    for (var entry in averages.entries) {
      if (!order.contains(entry.key)) {
        sortedEntries.add(entry);
      }
    }

    return sortedEntries;
  }

  @override
  Widget build(BuildContext context) {
    final averages = _calculateAverages();

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Statistiques',
                        style: context.texts.h1
                            .copyWith(color: context.colors.secondary),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Section des scores du jour
                    Text(
                      'Scores du jour',
                      style: context.texts.h3
                          .copyWith(color: context.colors.secondary),
                    ),
                    const SizedBox(height: 16),
                    ..._sortLanguageEntries(_groupTodayScoresByLanguage()).map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Center(
                          child: SizedBox(
                            width: 200,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: context.colors.onPrimary,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Image du drapeau
                                  Image.asset(
                                    _getLanguageImage(entry.key),
                                    width: 32,
                                    height: 32,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.language,
                                          size: 32);
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _getLanguageDisplayName(entry.key),
                                    style: context.texts.bodyBold.copyWith(
                                      color: context.colors.tertiary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ...entry.value.map(
                                    (score) => Text(
                                      '${score['nb_try'] ?? 0}/6',
                                      style: context.texts.body,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Section des moyennes personnelles
                    Text(
                      'Moyennes',
                      style: context.texts.h3
                          .copyWith(color: context.colors.secondary),
                    ),
                    const SizedBox(height: 16),
                    ..._sortAverageEntries(averages).map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Center(
                          child: SizedBox(
                            width: 225,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: context.colors.onPrimary,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Image du drapeau
                                  Image.asset(
                                    _getLanguageImage(entry.key),
                                    width: 32,
                                    height: 32,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.language,
                                          size: 32);
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _getLanguageDisplayName(entry.key),
                                    style: context.texts.bodyBold.copyWith(
                                      color: context.colors.tertiary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${entry.value.toStringAsFixed(1)}/6',
                                    style: context.texts.body.copyWith(
                                      color: context.colors.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String _getLanguageImage(String language) {
    switch (language.toLowerCase()) {
      case 'english':
        return 'assets/english.png';
      case 'french':
        return 'assets/francais.png';
      case 'italian':
        return 'assets/italiano.png';
      case 'spanish':
        return 'assets/espanol.png';
      default:
        return 'assets/english.png';
    }
  }

  String _getLanguageDisplayName(String language) {
    switch (language.toLowerCase()) {
      case 'english':
        return 'English';
      case 'french':
        return 'Français';
      case 'italian':
        return 'Italiano';
      case 'spanish':
        return 'Español';
      default:
        return 'English';
    }
  }
}
