import 'package:flutter/material.dart';
import 'ui/redacteur_interface.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MonAppli());
}

class MonAppli extends StatelessWidget {
  const MonAppli({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Magazine Infos — Rédacteurs",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const RedacteurInterface(),
    );
  }
}
