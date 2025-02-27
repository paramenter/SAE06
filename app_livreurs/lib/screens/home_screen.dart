import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'carte_screen.dart';
import 'liste_depots_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import 'scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, List> tournees = {};

  @override
  void initState() {
    super.initState();
    fetchTours();
  }

  Future<void> fetchTours() async {
    String today = DateTime.now().toIso8601String().split('T')[0];
    final response = await http.get(
      
      Uri.parse(
          'https://qjnieztpwnwroinqrolm.supabase.co/rest/v1/detail_livraisons?jour=eq.$today'),
      headers: {
        'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqbmllenRwd253cm9pbnFyb2xtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4MTEwNTAsImV4cCI6MjA1MzM4NzA1MH0.orLZFmX3i_qR0H4H6WwhUilNf5a1EAfrFhbbeRvN41M',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqbmllenRwd253cm9pbnFyb2xtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4MTEwNTAsImV4cCI6MjA1MzM4NzA1MH0.orLZFmX3i_qR0H4H6WwhUilNf5a1EAfrFhbbeRvN41M',
      },
    );

    if (response.statusCode == 200) {
      List livraisons = json.decode(response.body);
      Map<String, List> tourneesMap = {};

      for (var livraison in livraisons) {
        String tourneeId = livraison['tournee_id'].toString();
        String depotId = livraison['depot_id'].toString();
        String depotName = livraison['depot'];

        if (!tourneesMap.containsKey(tourneeId)) {
          tourneesMap[tourneeId] = [];
        }
        tourneesMap[tourneeId]!.add({
          'depot_id': depotId,
          'depot': depotName,
        });
      }

      setState(() {
        tournees = tourneesMap;
      });
    }
  }

  int _currentIndex = 0;

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ScannerScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tournées')),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: tournees.keys.length,
        itemBuilder: (context, index) {
          String tourneeId = tournees.keys.elementAt(index);
          return Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(
                'Tournée ID: $tourneeId',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${tournees[tourneeId]!.length} panier',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListeDepotsScreen(
                      tourneeId: tourneeId,
                      livraisons: tournees[tourneeId]!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}