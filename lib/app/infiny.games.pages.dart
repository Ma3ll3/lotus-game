import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lotus/ui/theme.dart';
import 'package:multi_language_words/multi_language_words.dart';
import 'package:go_router/go_router.dart';

class InfinyWordlePage extends StatefulWidget {
  final Language? language;

  const InfinyWordlePage({super.key, this.language});

  @override
  State<InfinyWordlePage> createState() => _InfinyWordlePageState();
}

class _InfinyWordlePageState extends State<InfinyWordlePage> {
  final generator = WordGenerator();

  // Variables du jeu
  String _targetWord = 'HELLO';
  int _wordLength = 5;
  final int _maxAttempts = 6;
  int _currentAttempt = 0;
  int _currentPosition = 0;
  late Language _selectedLanguage;

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
    const String validLetters = 'abcdefghijklmnopqrstuvwxyz';

    String result = '';
    for (int i = 0; i < text.length; i++) {
      String char = text[i].toLowerCase();

      // Vérifier si le caractère est une lettre valide
      if (!validLetters.contains(char)) {
        continue; // Ignorer les caractères non alphabétiques
      }

      int index = withAccents.indexOf(char);
      if (index != -1) {
        result += withoutAccents[index];
      } else {
        result += char;
      }
    }
    return result.toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.language ?? Language.english;
    // Ne pas créer la grille ici, elle sera créée dans _initializeGame()
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialiser le jeu ici après que le contexte soit disponible
    _initializeGame();
  }

  void _initializeGame() async {
    String word;
    try {
      word = '';
      int attempts = 0;
      const maxAttempts = 10; // Éviter une boucle infinie

      while (word.length < 3 || word.length > 8) {
        List<String> randomWords = generator.generateRandomWords(
          1,
          _selectedLanguage,
        );
        if (randomWords.isNotEmpty) {
          word = _removeAccents(randomWords[0]); // Retirer les accents
        } else {
          word = _removeAccents(
              _getDefaultWord(_selectedLanguage)); // Retirer les accents
          break; // Sortir de la boucle si on utilise un mot par défaut
        }

        attempts++;
        if (attempts >= maxAttempts) {
          // Si on n'arrive pas à trouver un mot valide, utiliser un mot par défaut
          word = _removeAccents(_getDefaultWord(_selectedLanguage));
          break;
        }
      }
    } catch (e) {
      // En cas d'erreur, utiliser un mot par défaut
      word = _removeAccents(
          _getDefaultWord(_selectedLanguage)); // Retirer les accents
    }

    // Réinitialiser les résultats pour une nouvelle partie
    _attemptResults.clear();

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
    if (_currentAttempt >= _maxAttempts) return;

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
    if (_currentPosition != _wordLength) {
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
      _showWinDialogInfiny();
    } else if (_currentAttempt >= _maxAttempts) {
      _showLoseDialogInfiny();
    }
  }

  // Générer l'emoji Wordle pour un mot
  String _getWordleEmoji(String guess, String target) {
    List<String> result = List.filled(guess.length, '');
    // Utiliser le mot cible sans accents pour la comparaison
    String cleanTarget = _removeAccents(target);
    List<String> targetLetters = cleanTarget.split('');
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

  // Générer le texte partageable pour les résultats
  String _generateShareableResults() {
    String results =
        'Infiny ${_selectedLanguage.name} ${_attemptResults.length}/6\n\n';

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
    // Utiliser le mot cible sans accents pour la comparaison
    String cleanTarget = _removeAccents(_targetWord);
    List<String> targetLetters = cleanTarget.split('');
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
        content: Text(message, style: TextStyle(color: context.colors.surface)),
        duration: const Duration(seconds: 2),
        backgroundColor: context.colors.secondary,
      ),
    );
  }

  void _showWinDialogInfiny() {
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
                style: context.texts.bodyMedium.copyWith(
                  color: context.colors.onPrimary,
                )),
            const SizedBox(height: 10),
            Text('Nombre de tentatives : $_currentAttempt/$_maxAttempts',
                style: context.texts.bodyMedium.copyWith(
                  color: context.colors.onPrimary,
                )),
            const SizedBox(height: 10),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  _shareResults();
                },
                child: Text('Partager',
                    style: TextStyle(color: context.colors.onPrimary)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _initializeGame();
                  });
                },
                child: Text('Nouveau jeu',
                    style: TextStyle(color: context.colors.onPrimary)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/infiny-home');
                },
                child: Text('Accueil',
                    style: TextStyle(color: context.colors.onPrimary)),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showLoseDialogInfiny() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.all(12),
        title: Text('Dommage!',
            style: context.texts.h3.copyWith(color: context.colors.secondary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Le mot était : $_targetWord',
                style: context.texts.bodyMedium.copyWith(
                  color: context.colors.onPrimary,
                )),
            const SizedBox(height: 10),
            Text('Nombre de coups : $_currentAttempt/$_maxAttempts',
                style: context.texts.bodyMedium.copyWith(
                  color: context.colors.onPrimary,
                )),
            const SizedBox(height: 10),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  _shareResults();
                },
                child: Text('Partager',
                    style: TextStyle(color: context.colors.onPrimary)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _initializeGame();
                  });
                },
                child: Text('Nouveau jeu',
                    style: TextStyle(color: context.colors.onPrimary)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/infiny-home');
                },
                child: Text('Accueil',
                    style: TextStyle(color: context.colors.onPrimary)),
              ),
            ],
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
            onPressed: () => context.go('/infiny-home'),
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
          padding: const EdgeInsets.all(2),
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
                    'Infiny',
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
                            padding: const EdgeInsets.symmetric(horizontal: 1),
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
                flex: 2,
                child: Column(
                  children: [
                    // Première rangée
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _keyboard.sublist(0, 10).map((letter) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: SizedBox(
                            width: 26,
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
                    const SizedBox(height: 4),
                    // Deuxième rangée
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _keyboard.sublist(10, 20).map((letter) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: SizedBox(
                            width: 26,
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
                    const SizedBox(height: 4),
                    // Troisième rangée avec boutons spéciaux
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Lettres restantes
                        ..._keyboard.sublist(20).map((letter) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: SizedBox(
                              width: 26,
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
                            width: 32,
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
                            width: 38,
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
