import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lotus/app/home.pages.dart';
import 'package:lotus/features/auth/sign_up.auth.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_user == null) {
      return const SignUpAuthPage();
    } else {
      return const HomePage();
    }
  }
}
