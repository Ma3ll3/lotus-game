import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lotus/ui/theme.dart';
import 'package:lotus/ui/core/text_field.dart';
import 'package:lotus/services/auth_service.dart';

class SignInAuthPage extends StatefulWidget {
  const SignInAuthPage({super.key});
  @override
  State<SignInAuthPage> createState() => _SignInAuthPageState();
}

class _SignInAuthPageState extends State<SignInAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final TextEditingController txtUsername = TextEditingController();
  final TextEditingController txtLogin = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();

  Future<void> _onInscription(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.signUpWithEmailAndPassword(
          txtLogin.text.trim(),
          txtPassword.text,
          txtUsername.text.trim(),
        );

        if (mounted) {
          context.go('/');
        }
      } catch (e) {
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              insetPadding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text('Erreur'),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK',
                      style: TextStyle(color: context.colors.onPrimary)),
                ),
              ],
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    txtUsername.dispose();
    txtLogin.dispose();
    txtPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: const AppBarStyle(title: "Page inscription"),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Sign in", style: context.texts.h1),
              const SizedBox(height: 60),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppTextFormField(
                      label: 'Nom d\'utilisateur',
                      hint: 'johndoe',
                      icon: Icons.person,
                      controller: txtUsername,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le nom d\'utilisateur est obligatoire';
                        }
                        if (value.trim().length < 3) {
                          return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextFormField(
                      label: 'Email',
                      hint: 'johndoe@email.com',
                      icon: Icons.email,
                      controller: txtLogin,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || !value.contains("@")) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextFormField(
                      label: 'Mot de passe',
                      hint: '*********',
                      icon: Icons.lock,
                      controller: txtPassword,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le mot de passe est obligatoire';
                        }
                        if (value.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await _onInscription(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.onPrimary,
                              foregroundColor: context.colors.surface,
                              textStyle: context.texts.bodyMedium,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 28,
                              ),
                            ),
                            child: const Text('Inscription'),
                          ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        context.go('/sign-up');
                      },
                      child: Text(
                        "J'ai déjà un compte",
                        style: TextStyle(
                            fontSize: context.texts.body.fontSize,
                            color: context.colors.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
