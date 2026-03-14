import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lotus/app/home.pages.dart';
import 'package:lotus/ui/theme.dart';
import 'package:lotus/features/auth/sign_up.auth.dart';
import 'package:lotus/features/auth/sign_in.auth.dart';
import 'package:lotus/features/auth/auth_wrapper.dart';
import 'package:lotus/app/daily.games.pages.dart';
import 'package:lotus/app/infiny.games.pages.dart';
import 'package:lotus/app/scores.pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:multi_language_words/multi_language_words.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthWrapper(),
    ),
    GoRoute(
      path: '/infiny-home',
      builder: (context, state) {
        final FirebaseAuth auth = FirebaseAuth.instance;
        if (auth.currentUser == null) {
          return const SignUpAuthPage();
        }
        return const HomePage(initialIndex: 1);
      },
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) {
        final FirebaseAuth auth = FirebaseAuth.instance;
        if (auth.currentUser != null) {
          return const HomePage();
        }
        return const SignInAuthPage();
      },
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) {
        final FirebaseAuth auth = FirebaseAuth.instance;
        if (auth.currentUser != null) {
          return const HomePage();
        }
        return const SignUpAuthPage();
      },
    ),
    GoRoute(
      path: '/daily-wordle',
      builder: (context, state) {
        final FirebaseAuth auth = FirebaseAuth.instance;
        if (auth.currentUser == null) {
          return const SignUpAuthPage();
        }
        final language = state.extra as Language?;
        return DailyWordlePage(language: language);
      },
    ),
    GoRoute(
      path: '/infiny-wordle',
      builder: (context, state) {
        final FirebaseAuth auth = FirebaseAuth.instance;
        if (auth.currentUser == null) {
          return const SignUpAuthPage();
        }
        final language = state.extra as Language?;
        return InfinyWordlePage(language: language);
      },
    ),
    GoRoute(
      path: '/scores',
      builder: (context, state) {
        final FirebaseAuth auth = FirebaseAuth.instance;
        if (auth.currentUser == null) {
          return const SignUpAuthPage();
        }
        return const ScoresPage();
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.base();

    final appTexts = AppTexts.base();

    return MaterialApp.router(
      title: 'Lotus Game',
      theme: ThemeData(
        fontFamily: 'Satoshi',
        extensions: [appColors, appTexts],
        colorScheme: appColors.toColorScheme(),
        scaffoldBackgroundColor: appColors.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: appColors.surface,
          foregroundColor: appColors.onPrimary,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: appColors.primary,
            foregroundColor: appColors.onPrimary,
            textStyle: appTexts.labelLarge,
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: appTexts.bodyLarge,
          bodyMedium: appTexts.bodyMedium,
          bodySmall: appTexts.bodySmall,
          titleLarge: appTexts.h4,
          titleMedium: appTexts.h5,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: appColors.surface,
          labelStyle: appTexts.bodySmall,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: appColors.primary,
            side: BorderSide(color: appColors.primary),
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}



// extension ThemeColors on BuildContext {

//   AppColors get colors => Theme.of(this).extension<AppColors>()!;

// }

// extension ThemeTexts on BuildContext {

//   AppTexts get texts => Theme.of(this).extension<AppTexts>()!;

// }

// style: AppTypography.h1.copyWith(color: context.theme.appColors.error)

