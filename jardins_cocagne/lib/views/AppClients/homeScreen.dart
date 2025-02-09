import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil Client'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_basket, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Bienvenue dans votre espace client',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Action future (ajouter navigation vers une autre page)
              },
              child: Text('Voir mes livraisons'),
            ),
          ],
        ),
      ),
    );
  }
}
