import 'package:flutter/material.dart';

import '../screens/create_match/create_match_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/splash/splash_screen.dart';
import 'theme.dart';

class GullyCricketApp extends StatelessWidget {
  const GullyCricketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gully Cricket',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: '/splash',
      builder: (context, child) =>
          Stack(children: [if (child != null) child, const _DeveloperCredit()]),
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/home': (_) => const HomeScreen(),
        '/create-match': (_) => const CreateMatchScreen(),
        '/calendar': (_) => const CalendarScreen(),
      },
    );
  }
}

class _DeveloperCredit extends StatelessWidget {
  const _DeveloperCredit();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 6),
          child: Opacity(
            opacity: 0.45,
            child: Text(
              'Developed by Raviteja Adari',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
      ),
    );
  }
}
