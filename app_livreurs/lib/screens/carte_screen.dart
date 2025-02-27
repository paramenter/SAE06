import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class CarteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Carte')),
      body: Center(child: Text('Carte Screen')),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}