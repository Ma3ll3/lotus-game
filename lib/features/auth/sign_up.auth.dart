import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lotus/ui/core/text_field.dart';
import 'package:lotus/services/auth_service.dart';
import 'package:lotus/ui/theme.dart';

class SignUpAuthPage extends StatefulWidget {
  const SignUpAuthPage({super.key});
  @override
  State<SignUpAuthPage> createState() => _SignUpAuthPageState();
}

class _SignUpAuthPageState extends State<SignUpAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final TextEditingController txtLogin = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();

  Future<void> _onAuth(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.signInWithEmailAndPassword(
          txtLogin.text.trim(),
          txtPassword.text,
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
              backgroundColor: context.colors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text('Erreur'),
              content: Text('Email ou mot de passe incorrect.'),
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
    txtLogin.dispose();
    txtPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Sign up", style: context.texts.h1),
              const SizedBox(height: 60),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.onPrimary,
                              foregroundColor: context.colors.surface,
                              textStyle: context.texts.bodyMedium,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 28,
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await _onAuth(context);
                              }
                            },
                            child: const Text('Connexion'),
                          ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        context.go('/sign-in');
                      },
                      child: Text("Créer un compte",
                          style: TextStyle(
                              fontSize: context.texts.body.fontSize,
                              color: context.colors.onPrimary)),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
