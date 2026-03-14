import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Inscription avec email et mot de passe
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    UserCredential userCredential;

    try {
      // Étape 1: Créer l'utilisateur dans Firebase Auth
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Étape 2: Attendre un court instant pour s'assurer que l'authentification est propagée
      await Future.delayed(const Duration(milliseconds: 500));

      // Étape 3: Créer le document utilisateur dans Firestore avec l'utilisateur authentifié
      try {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'username': username,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } on FirebaseException catch (e) {
        // Si Firestore échoue, on supprime l'utilisateur Firebase créé
        await userCredential.user?.delete();
        throw 'Erreur lors de la création du profil utilisateur: ${e.message}';
      } catch (e) {
        // Si une autre erreur se produit, on supprime l'utilisateur Firebase créé
        await userCredential.user?.delete();
        throw 'Erreur lors de la création du profil utilisateur';
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getErrorMessage(e);
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      throw errorMessage;
    } on FirebaseException catch (e) {
      print('Firestore Error: ${e.code} - ${e.message}');
      throw 'Erreur Firestore: ${e.message}';
    } catch (e) {
      print('Unexpected Error: ${e.toString()}');
      throw 'Une erreur est survenue lors de l\'inscription: ${e.toString()}';
    }
  }

  // Connexion avec email et mot de passe
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e);
    } catch (e) {
      throw 'Une erreur est survenue lors de la connexion';
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Une erreur est survenue lors de la déconnexion';
    }
  }

  // Obtenir l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Stream pour écouter les changements d'état d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obtenir les données de l'utilisateur depuis Firestore
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('Users').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw 'Une erreur est survenue lors de la récupération des données utilisateur';
    }
  }

  // Créer le document utilisateur dans Firestore (utilitaire)
  Future<void> createUserData(
    String userId,
    String email,
    String username,
  ) async {
    try {
      // Attendre que l'authentification soit complètement propagée
      await Future.delayed(const Duration(milliseconds: 200));

      await _firestore.collection('users').doc(userId).set({
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Document utilisateur créé avec succès pour l\'UID: $userId');
    } on FirebaseException catch (e) {
      print(
        'Erreur Firestore lors de la création du document: ${e.code} - ${e.message}',
      );
      throw 'Erreur lors de la création du profil utilisateur: ${e.message}';
    } catch (e) {
      print(
        'Erreur inattendue lors de la création du document: ${e.toString()}',
      );
      throw 'Erreur lors de la création du profil utilisateur: ${e.toString()}';
    }
  }

  // Supprimer le compte utilisateur
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw 'Aucun utilisateur connecté';
      }

      // Supprimer le document utilisateur de Firestore
      try {
        await _firestore.collection('users').doc(user.uid).delete();
      } catch (e) {
        print(
            'Erreur lors de la suppression du document Firestore: ${e.toString()}');
      }

      // Supprimer le compte Firebase Auth
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw 'Cette action nécessite une authentification récente. Veuillez vous déconnecter et vous reconnecter.';
      }
      throw 'Erreur lors de la suppression du compte: ${e.message}';
    } catch (e) {
      throw 'Une erreur est survenue lors de la suppression du compte: ${e.toString()}';
    }
  }

  // Traduire les erreurs Firebase en messages français
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Le mot de passe est trop faible';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'invalid-email':
        return 'L\'email est invalide';
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email';
      case 'wrong-password':
        return 'Le mot de passe est incorrect';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'too-many-requests':
        return 'Trop de tentatives de connexion. Veuillez réessayer plus tard';
      default:
        return 'Une erreur est survenue: ${e.message}';
    }
  }
}
