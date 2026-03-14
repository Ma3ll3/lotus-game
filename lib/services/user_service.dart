import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserService {
  static String? _cachedUserId;
  static bool _isListenerInitialized = false;

  // Initialiser l'écouteur des changements d'authentification
  static void _initializeAuthListener() {
    if (_isListenerInitialized) return;

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      // Réinitialiser le cache quand l'état d'authentification change
      _cachedUserId = null;
      print('Auth state changed, cache reset. User: ${user?.uid ?? 'null'}');
    });

    _isListenerInitialized = true;
  }

  // Obtenir l'ID utilisateur avec persistance
  static String getUserId() {
    // S'assurer que l'écouteur est initialisé
    _initializeAuthListener();

    if (_cachedUserId != null) {
      return _cachedUserId!;
    }

    // Option 1: Firebase Auth (recommandé)
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _cachedUserId = user.uid;
      return _cachedUserId!;
    }

    // Option 2: ID unique persistant (fallback)
    _cachedUserId = _generatePersistentUserId();
    return _cachedUserId!;
  }

  // Générer un ID utilisateur persistant sans authentification
  static String _generatePersistentUserId() {
    // En web, utiliser une combinaison de localStorage et timestamp
    if (kIsWeb) {
      // Pour le web, on pourrait utiliser localStorage
      // Pour l'instant, on génère un ID unique
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random().nextInt(10000);
      return 'web_user_${timestamp}_$random';
    } else {
      // Pour mobile, on pourrait utiliser device_info_plus
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random().nextInt(10000);
      return 'mobile_user_${timestamp}_$random';
    }
  }

  // Réinitialiser le cache (utile pour les tests et changements de compte)
  static void resetCache() {
    _cachedUserId = null;
    print('User cache manually reset');
  }

  // Forcer la réinitialisation du cache et retourner le nouvel ID
  static String forceRefreshUserId() {
    resetCache();
    return getUserId();
  }

  // Vérifier si l'utilisateur est authentifié
  static bool isAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }

  // Obtenir l'email de l'utilisateur si authentifié
  static String? getUserEmail() {
    return FirebaseAuth.instance.currentUser?.email;
  }

  // Obtenir le nom d'affichage de l'utilisateur si authentifié
  static String? getDisplayName() {
    return FirebaseAuth.instance.currentUser?.displayName;
  }
}
