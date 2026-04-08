import 'package:flutter/material.dart';
import 'package:shopping_list_app/grocery_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(                                      // Widget that provides Material Design theming
      title: 'Flutter Groceries',
      theme: ThemeData.dark().copyWith(                      // To customize specific aspects only
        //useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 147, 229, 250),
          brightness: Brightness.dark,
          surface: const Color.fromARGB(255, 42, 51, 59),                     // For the cards and surfaces
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 50, 58, 60),       // Main App background color.
      ),
      home: const GroceryList(),
    );
  }
}