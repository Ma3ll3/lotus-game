import 'package:flutter/material.dart';
import 'package:lotus/ui/theme.dart';
import 'package:lotus/services/auth_service.dart';
import 'package:lotus/services/user_sync_service.dart';
import 'package:lotus/services/user_service.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();
  final UserSyncService _syncService = UserSyncService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _syncStatus;
  String? _username;

  Future<void> _logout() async {
    try {
      // Réinitialiser le cache utilisateur avant de se déconnecter
      UserService.resetCache();
      await _authService.signOut();
      if (mounted) {
        context.go('/sign-up');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la déconnexion: ${e.toString()}',
                style: TextStyle(color: context.colors.onPrimary)),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    try {
      await _authService.deleteAccount();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compte supprimé avec succès!',
                style: TextStyle(color: context.colors.surface)),
            backgroundColor: context.colors.secondaryContainer,
          ),
        );
        context.go('/sign-up');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: ${e.toString()}',
                style: TextStyle(color: context.colors.onPrimary)),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  Future<void> _checkSyncStatus() async {
    try {
      Map<String, dynamic> status = await _syncService.getSyncStatus();
      setState(() {
        _syncStatus = status;
      });

      // Récupérer le username si l'utilisateur est authentifié
      if (status['isAuthenticated'] == true && status['userId'] != null) {
        await _fetchUsername(status['userId']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la vérification: ${e.toString()}',
                style: TextStyle(color: context.colors.onPrimary)),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  Future<void> _fetchUsername(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists && mounted) {
        setState(() {
          _username = userDoc.get('username') as String?;
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération du username: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkSyncStatus();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Paramètres',
                  style: context.texts.h1
                      .copyWith(color: context.colors.secondary),
                ),
                const SizedBox(height: 40),
                // Section informations utilisateur
                if (_syncStatus != null && _syncStatus!['isAuthenticated']) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      border: Border.all(
                        color: context.colors.onPrimary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nom d\'utilisateur',
                                style: context.texts.bodyMedium.copyWith(
                                  color: context.colors.tertiary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _username ?? 'Non disponible',
                                style: context.texts.body.copyWith(
                                  color: context.colors.onPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Email',
                                style: context.texts.bodyMedium.copyWith(
                                  color: context.colors.tertiary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _syncStatus!['email'] ?? 'Non disponible',
                                style: context.texts.body.copyWith(
                                  color: context.colors.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Section actions
                if (_syncStatus != null && _syncStatus!['isAuthenticated']) ...[
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.secondary,
                      foregroundColor: context.colors.surface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Se déconnecter',
                      style: context.texts.bodyMedium.copyWith(
                        color: context.colors.surface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _deleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.error,
                      foregroundColor: context.colors.surface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Supprimer mon compte',
                      style: context.texts.bodyMedium.copyWith(
                        color: context.colors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
