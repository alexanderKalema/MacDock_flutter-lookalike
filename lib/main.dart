import 'package:flutter/material.dart';
import 'home_page.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// The main application widget.
/// Builds the [MaterialApp] and defines the overall theme.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Icon Dock',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 4,
        ),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}