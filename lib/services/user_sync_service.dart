import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class UserSyncService {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Vérifier si l'utilisateur actuel a un document dans Firestore
  Future<bool> hasUserDocument() async {
    User? user = _authService.currentUser;
    if (user == null) return false;

    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Synchroniser l'utilisateur actuel avec Firestore
  Future<void> syncCurrentUser(String username) async {
    User? user = _authService.currentUser;
    if (user == null) {
      throw 'Aucun utilisateur connecté';
    }

    // Vérifier si le document existe déjà
    bool hasDoc = await hasUserDocument();
    if (hasDoc) {
      return; // Le document existe déjà, pas besoin de synchroniser
    }

    // Créer le document manuellement
    await _authService.createUserData(user.uid, user.email!, username);
  }

  // Obtenir les informations de synchronisation
  Future<Map<String, dynamic>> getSyncStatus() async {
    User? user = _authService.currentUser;
    if (user == null) {
      return {
        'isAuthenticated': false,
        'hasDocument': false,
        'message': 'Aucun utilisateur connecté',
      };
    }

    bool hasDoc = await hasUserDocument();

    return {
      'isAuthenticated': true,
      'userId': user.uid,
      'email': user.email,
      'hasDocument': hasDoc,
      'message': hasDoc
          ? 'Utilisateur synchronisé'
          : 'Document utilisateur manquant',
    };
  }
}
