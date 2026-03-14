import 'package:flutter/material.dart';
import 'package:lotus/ui/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_language_words/multi_language_words.dart';
import 'package:flutter/services.dart';
import 'package:lotus/services/user_service.dart';
import 'dart:math';

class DailyWordlePage extends StatefulWidget {
  final Language? language;

  const DailyWordlePage({super.key, this.language});

  @override
  State<DailyWordlePage> createState() => _DailyWordlePageState();
}

class _DailyWordlePageState extends State<DailyWordlePage> {
  final generator = WordGenerator();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variables du jeu
  String _targetWord = 'HELLO'; // Valeur par défaut
  int _wordLength = 5; // Valeur par défaut au cas où
  final int _maxAttempts = 6;
  int _currentAttempt = 0;
  int _currentPosition = 0;
  late Language _selectedLanguage;
  bool _gameCompleted = false; // Pour bloquer les tentatives après la fin

  // Variables pour le partage
  final List<String> _attemptResults =
      []; // Stocke les résultats de chaque tentative

  List<List<String>> _grid = [];
  List<List<Color>> _gridColors = [];

  // Clavier AZERTY
  final List<String> _keyboard = [
    'A',
    'Z',
    'E',
    'R',
    'T',
    'Y',
    'U',
    'I',
    'O',
    'P',
    'Q',
    'S',
    'D',
    'F',
    'G',
    'H',
    'J',
    'K',
    'L',
    'M',
    'W',
    'X',
    'C',
    'V',
    'B',
    'N',
  ];

  // Fonction pour retirer les accents d'un mot
  String _removeAccents(String text) {
    const String withAccents =
        'àáâäãåāăąçćčďđèéêëēėęěğǵḧîíïīĩįìłḿñńǹňôöòóœøōõőṕŕřßśšşťțûúùüūůűųẃẍÿýžźż';
    const String withoutAccents =
        'aaaaaaaaaacccddeeeeeeeegghiiiiiilmnnnnoooooooooprrssssttuuuuuuuuwxyyzzzz';

    String result = '';
    for (int i = 0; i < text.length; i++) {
      String char = text[i].toLowerCase();
      int index = withAccents.indexOf(char);
      if (index != -1) {
        result += withoutAccents[index];
      } else {
        result += char;
      }
    }
    return result.toUpperCase();
  }

  Future<String> getDailyWord(Language language) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final docRef = _firestore.collection('daily_words').doc(today);

    try {
      // 1. Vérifier si le mot du jour existe déjà
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // 2. Le mot existe, le récupérer
        final data = docSnapshot.data() as Map<String, dynamic>;
        final languageKey = language.name.toLowerCase();

        if (data.containsKey(languageKey) && data[languageKey] != null) {
          print('Mot récupéré depuis Firebase: ${data[languageKey]}');
          return _removeAccents(
              data[languageKey].toString()); // Retirer les accents
        }
      }

      // 3. Le mot n'existe pas, générer et sauvegarder
      print('Génération du mot du jour pour $language');
      final newWord = _generateDeterministicWord(language);
      final cleanWord = _removeAccents(newWord); // Retirer les accents

      // Sauvegarder dans Firebase pour les autres utilisateurs
      await docRef.set({
        language.name.toLowerCase(): cleanWord,
        'createdAt': FieldValue.serverTimestamp(),
        'generatedBy': 'first_user_today',
      }, SetOptions(merge: true));

      print('Mot généré et sauvegardé: $cleanWord');
      return cleanWord;
    } catch (e) {
      print('Erreur Firebase, fallback local: $e');
      // 4. Fallback local si Firebase indisponible
      return _generateDeterministicWord(language);
    }
  }

  String _generateDeterministicWord(Language language) {
    // Génération déterministe basée sur la date
    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final random = Random(seed);

    String word;
    try {
      word = '';
      int attempts = 0;
      const maxAttempts = 10; // Éviter une boucle infinie

      while (word.length < 3 || word.length > 8) {
        // Générer plusieurs mots pour avoir du choix de façon déterministe
        List<String> randomWords = generator.generateRandomWords(10, language);
        if (randomWords.isNotEmpty) {
          // Choisir un mot de façon déterministe basée sur la date
          final wordIndex = random.nextInt(randomWords.length);
          word = _removeAccents(randomWords[wordIndex]); // Retirer les accents
        } else {
          word =
              _removeAccents(_getDefaultWord(language)); // Retirer les accents
          break; // Sortir de la boucle si on utilise un mot par défaut
        }

        attempts++;
        if (attempts >= maxAttempts) {
          // Si on n'arrive pas à trouver un mot valide, utiliser un mot par défaut
          word = _removeAccents(_getDefaultWord(language));
          break;
        }
      }
    } catch (e) {
      word = _removeAccents(_getDefaultWord(language));
      print('Erreur génération locale: $e');
    }

    return word;
  }

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.language ?? Language.english;
    _grid =
        List.generate(_maxAttempts, (index) => List.filled(_wordLength, ''));
    _initializeGame();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialiser les couleurs ici car le contexte est disponible
    if (_gridColors.isEmpty || _gridColors[0].isEmpty) {
      _gridColors = List.generate(_maxAttempts,
          (index) => List.filled(_wordLength, context.colors.surface));
    }
  }

  void _initializeGame() async {
    String word;
    try {
      // Récupérer le mot du jour via Cloud Function
      word = await getDailyWord(_selectedLanguage);
      print(word);
    } catch (e) {
      // En cas d'erreur, utiliser un mot par défaut
      word = _getDefaultWord(_selectedLanguage);
    }

    // Vérifier que le mot n'est pas vide avant de continuer
    if (word.isEmpty) {
      word = _getDefaultWord(_selectedLanguage); // Fallback ultime
    }

    setState(() {
      _targetWord = word;
      _wordLength = _targetWord.length;

      // Ajuster la grille si la longueur du mot change
      _grid = List.generate(_maxAttempts, (_) => List.filled(_wordLength, ''));
      if (mounted) {
        _gridColors = List.generate(_maxAttempts,
            (_) => List.filled(_wordLength, context.colors.surface));
      }

      _currentAttempt = 0;
      _currentPosition = 0;
    });
  }

  String _getDefaultWord(Language language) {
    switch (language) {
      case Language.english:
        return _removeAccents('HELLO');
      case Language.french:
        return _removeAccents('BONJOUR');
      case Language.spanish:
        return _removeAccents('HOLA');
      case Language.italian:
        return _removeAccents('CIAO');
      default:
        return _removeAccents('HELLO');
    }
  }

  void _onKeyPress(String letter) {
    if (_currentAttempt >= _maxAttempts || _gameCompleted) return;

    // Retirer les accents de la lettre tapée
    String cleanLetter = _removeAccents(letter);

    if (_currentPosition < _wordLength) {
      setState(() {
        _grid[_currentAttempt][_currentPosition] = cleanLetter;
        _currentPosition++;
      });
    }
  }

  void _onDelete() {
    if (_currentPosition > 0) {
      setState(() {
        _currentPosition--;
        _grid[_currentAttempt][_currentPosition] = '';
      });
    }
  }

  void _onSubmit() {
    if (_currentPosition != _wordLength || _gameCompleted) {
      _showMessage('Veuillez remplir toutes les lettres');
      return;
    }

    String currentWord = _grid[_currentAttempt].join('');
    String cleanWord =
        _removeAccents(currentWord); // Retirer les accents pour la comparaison
    List<Color> newColors = _checkWord(cleanWord);

    // Ajouter le résultat de cette tentative à la liste
    String attemptResult = _getWordleEmoji(cleanWord, _targetWord);
    _attemptResults.add(attemptResult);

    setState(() {
      _gridColors[_currentAttempt] = newColors;
      _currentAttempt++;
      _currentPosition = 0;
    });

    if (cleanWord == _targetWord) {
      _gameCompleted = true;
      _saveScore(); // Sauvegarder le score
      _showWinDialog();
    } else if (_currentAttempt >= _maxAttempts) {
      _gameCompleted = true;
      _saveScore(); // Sauvegarder le score même en cas d'échec
      _showLoseDialog();
    }
  }

  // Générer l'emoji Wordle pour un mot
  String _getWordleEmoji(String guess, String target) {
    List<String> result = List.filled(guess.length, '');
    List<String> targetLetters = target.split('');
    List<String> guessLetters = guess.split('');

    // Marquer d'abord les lettres correctes (vert)
    for (int i = 0; i < guess.length; i++) {
      if (guessLetters[i] == targetLetters[i]) {
        result[i] = '🟩'; // Vert : lettre correcte et bien placée
        targetLetters[i] = ''; // Marquer comme utilisée
        guessLetters[i] = ''; // Marquer comme traitée
      }
    }

    // Ensuite marquer les lettres présentes mais mal placées (jaune)
    for (int i = 0; i < guess.length; i++) {
      if (guessLetters[i] != '') {
        int index = targetLetters.indexOf(guessLetters[i]);
        if (index != -1) {
          result[i] = '🟨'; // Jaune : lettre correcte mais mal placée
          targetLetters[index] = ''; // Marquer comme utilisée
        } else {
          result[i] = '⬛'; // Gris : lettre incorrecte
        }
      }
    }

    return result.join('');
  }

  // Sauvegarder le score dans Firestore
  Future<void> _saveScore() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Obtenir l'ID utilisateur depuis le service utilisateur
      String userId = UserService.getUserId();

      final scoreData = {
        'userId': userId,
        'date': today,
        'lang': _selectedLanguage.name.toLowerCase(),
        'nb_try': _currentAttempt,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Vérifier si un score existe déjà pour aujourd'hui et cette langue
      final existingScore = await _firestore
          .collection('scores')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: today)
          .where('lang', isEqualTo: _selectedLanguage.name.toLowerCase())
          .get();

      if (existingScore.docs.isEmpty) {
        // Créer un nouveau score
        await _firestore.collection('scores').add(scoreData);
        print(
            'Score sauvegardé: ${scoreData['nb_try']} tentatives pour ${scoreData['lang']}');
      } else {
        print('Score déjà existant pour aujourd\'hui et cette langue');
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde du score: $e');
    }
  }

  // Générer le texte partageable pour les résultats
  String _generateShareableResults() {
    String results =
        'Daily ${_selectedLanguage.name} ${_attemptResults.length}/6\n\n';

    for (int i = 0; i < _attemptResults.length; i++) {
      results += '${_attemptResults[i]}\n';
    }

    results += '\nMot à trouver : $_targetWord\nhttps://lotus-418f7.web.app/';
    return results;
  }

  // Fonction pour partager les résultats
  void _shareResults() async {
    final shareText = _generateShareableResults();

    try {
      // Tenter de partager avec le système natif
      await Clipboard.setData(ClipboardData(text: shareText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Résultats copiés dans le presse-papier!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la copie: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  List<Color> _checkWord(String guess) {
    List<Color> colors = List.filled(_wordLength, context.colors.primary);
    List<String> targetLetters = _targetWord.split('');
    List<String> guessLetters = guess.split('');

    // Marquer d'abord les lettres correctes (vert)
    for (int i = 0; i < _wordLength; i++) {
      if (guessLetters[i] == targetLetters[i]) {
        colors[i] = context.colors.secondaryContainer;
        targetLetters[i] = ''; // Marquer comme utilisée
        guessLetters[i] = ''; // Marquer comme traitée
      }
    }

    // Ensuite marquer les lettres présentes mais mal placées (jaune/tertiary)
    for (int i = 0; i < _wordLength; i++) {
      if (guessLetters[i] != '') {
        int index = targetLetters.indexOf(guessLetters[i]);
        if (index != -1) {
          colors[i] = context.colors.secondary;
          targetLetters[index] = ''; // Marquer comme utilisée
        }
      }
    }

    return colors;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: TextStyle(color: context.colors.onPrimary)),
        duration: const Duration(seconds: 2),
        backgroundColor: context.colors.secondary,
      ),
    );
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.all(12),
        title: Text('Bravo !',
            style: context.texts.h3.copyWith(color: context.colors.secondary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vous avez trouvé le mot : $_targetWord',
                style: context.texts.body.copyWith(
                  color: context.colors.onPrimary,
                )),
            const SizedBox(height: 10),
            Text('Nombre de coups : $_currentAttempt/$_maxAttempts',
                style: context.texts.body.copyWith(
                  color: context.colors.onPrimary,
                )),
            const SizedBox(height: 10),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _shareResults();
            },
            child: Text('Partager',
                style: context.texts.bodyBold.copyWith(
                  color: context.colors.onPrimary,
                )),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
            child: Text('Accueil',
                style: context.texts.bodyBold.copyWith(
                  color: context.colors.onPrimary,
                )),
          ),
        ],
      ),
    );
  }

  void _showLoseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.all(12),
        title: Text('Dommage !',
            style: context.texts.h3.copyWith(color: context.colors.secondary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Le mot était : $_targetWord',
                style: context.texts.body.copyWith(
                  color: context.colors.onPrimary,
                )),
            const SizedBox(height: 10),
            Text('Nombre de coups : $_currentAttempt/$_maxAttempts',
                style: context.texts.body.copyWith(
                  color: context.colors.onPrimary,
                )),
            const SizedBox(height: 10),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _shareResults();
            },
            child: Text('Partager',
                style: context.texts.bodyBold.copyWith(
                  color: context.colors.onPrimary,
                )),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
            child: Text('Accueil',
                style: context.texts.bodyBold.copyWith(
                  color: context.colors.onPrimary,
                )),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: context.colors.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showGameRules(context),
                tooltip: 'Règles du jeu',
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    _getLanguageImage(_selectedLanguage.name),
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.language, size: 32);
                    },
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Mot du jour',
                    style: context.texts.h3
                        .copyWith(color: context.colors.secondary),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              // Grille de jeu
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_maxAttempts, (attempt) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_wordLength, (position) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: _gridColors[attempt][position],
                                border: Border.all(
                                  color: context.colors.onPrimary,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  _grid[attempt][position],
                                  style: context.texts.body.copyWith(
                                    fontFamily: 'Pally',
                                    color: _gridColors[attempt][position] ==
                                                context.colors.secondary ||
                                            _gridColors[attempt][position] ==
                                                context
                                                    .colors.secondaryContainer
                                        ? context.colors.surface
                                        : context.colors.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

              // Clavier
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // Première rangée
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _keyboard.sublist(0, 10).map((letter) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: SizedBox(
                            width: 28,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () => _onKeyPress(letter),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.colors.onPrimary,
                                foregroundColor: context.colors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.all(0),
                              ),
                              child: Text(
                                letter,
                                style: context.texts.bodySmall,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 2),
                    // Deuxième rangée
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _keyboard.sublist(10, 20).map((letter) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: SizedBox(
                            width: 28,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () => _onKeyPress(letter),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.colors.onPrimary,
                                foregroundColor: context.colors.surface,
                                minimumSize: const Size(10, 30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.all(0),
                              ),
                              child: Text(
                                letter,
                                style: context.texts.bodySmall,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 2),
                    // Troisième rangée avec boutons spéciaux
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Lettres restantes
                        ..._keyboard.sublist(20).map((letter) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: SizedBox(
                              width: 28,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () => _onKeyPress(letter),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.colors.onPrimary,
                                  foregroundColor: context.colors.surface,
                                  minimumSize: const Size(10, 30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.all(0),
                                ),
                                child: Text(
                                  letter,
                                  style: context.texts.bodySmall,
                                ),
                              ),
                            ),
                          );
                        }),
                        // Bouton DELETE
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: SizedBox(
                            width: 28,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: _onDelete,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.colors.tertiary,
                                foregroundColor: context.colors.surface,
                                minimumSize: const Size(10, 30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.all(0),
                              ),
                              child: const Icon(Icons.backspace),
                            ),
                          ),
                        ),
                        // Bouton SUBMIT
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: SizedBox(
                            width: 28,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: _onSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    context.colors.secondaryContainer,
                                foregroundColor: context.colors.surface,
                                minimumSize: const Size(10, 30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.all(0),
                              ),
                              child: const Icon(Icons.check),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
