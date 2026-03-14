import 'package:flutter/material.dart';
import 'package:lotus/ui/theme.dart';
import 'package:lotus/app/daily.pages.dart';
import 'package:lotus/app/infiny.pages.dart';
import 'package:lotus/app/scores.pages.dart';
import 'package:lotus/app/settings.pages.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

extension ThemeColors on BuildContext {}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const DailyPage(),
    const InfinyModePage(),
    const ScoresPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(
        //     "Lotus",
        //     style: context.texts.h1.copyWith(color: context.colors.primary),
        //   ),
        //   backgroundColor: context.colors.surface,
        //   actions: [
        //     IconButton(
        //       icon: const Icon(Icons.leaderboard),
        //       onPressed: () => context.go('/scores'),
        //       tooltip: 'Voir les scores',
        //     ),
        //   ],
        // ),
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          unselectedItemColor: context.colors.tertiary,
          selectedItemColor: context.colors.secondary,
          backgroundColor: context.colors.primary,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
                icon:
                    Image.asset('assets/Logo_small.png', width: 24, height: 24),
                label: 'Mot du jour'),
            BottomNavigationBarItem(
              icon: Image.asset('assets/infiny.png', width: 24, height: 24),
              label: 'Mode Infini',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.score), label: 'Scores'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Paramètres',
            ),
          ],
        ),
      ),
    );
  }
}
