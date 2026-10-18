import 'package:flutter/material.dart';
import 'package:sidedeck/theme/sidedeck_theme.dart';
import 'package:sidedeck/ui/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ReverMixApp()); // نام کلاس را تغییر دادم
}

class ReverMixApp extends StatelessWidget {
  const ReverMixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReverMix', // نام نمایشی برنامه
      debugShowCheckedModeBanner: false,
      theme: SideDeckTheme.dark(),
      home: const HomePage(),
    );
  }
}
