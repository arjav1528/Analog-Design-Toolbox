import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analog Designer Toolbox',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'JetBrainsMono',
        scaffoldBackgroundColor: const Color(0xFF101214),
      ),
      home: const HomeScreen(),
    );
  }
}
