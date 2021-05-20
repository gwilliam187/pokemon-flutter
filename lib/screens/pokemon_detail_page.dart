import 'package:flutter/material.dart';

class PokemonDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(primaryColor: Colors.green),
        home: Scaffold(
            appBar: AppBar(
              title: Text('Pokemon Flutter'),
            ),
            body: Text('yo')));
  }
}
