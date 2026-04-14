import 'package:flutter/material.dart';

import 'game_screen.dart';
import 'home_screen.dart';
import 'stats_screen.dart';
import 'timer_screen.dart';
import 'todo_screen.dart';

class FocusTapShell extends StatefulWidget {
  const FocusTapShell({super.key});

  @override
  State<FocusTapShell> createState() => _FocusTapShellState();
}

class _FocusTapShellState extends State<FocusTapShell> {
  int _currentIndex = 0;

  static const _pages = [
    HomeScreen(),
    TodoScreen(),
    TimerScreen(),
    GameScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.checklist_rtl), label: 'TODO'),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            label: 'Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.stars_outlined),
            label: 'Break',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
