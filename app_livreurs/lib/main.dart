import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_web/geolocator_web.dart';
import 'package:app_settings/app_settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application Livreurs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

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
    final response = await http.get(
      Uri.parse(
          'https://qjnieztpwnwroinqrolm.supabase.co/rest/v1/detail_livraisons?jour=eq.2025-02-26'),
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqbmllenRwd253cm9pbnFyb2xtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4MTEwNTAsImV4cCI6MjA1MzM4NzA1MH0.orLZFmX3i_qR0H4H6WwhUilNf5a1EAfrFhbbeRvN41M',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqbmllenRwd253cm9pbnFyb2xtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4MTEwNTAsImV4cCI6MjA1MzM4NzA1MH0.orLZFmX3i_qR0H4H6WwhUilNf5a1EAfrFhbbeRvN41M',
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
        // Already on the HomeScreen
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PaniersScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CarteScreen()),
        );
        break;
      case 3:
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
        itemCount: tournees.keys.length,
        itemBuilder: (context, index) {
          String tourneeId = tournees.keys.elementAt(index);
          return ListTile(
            title: Text('Tournée ID: $tourneeId'),
            subtitle: Text('${tournees[tourneeId]!.length} dépôts'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ListeDepotsScreen(
                        tourneeId: tourneeId,
                        livraisons: tournees[tourneeId]!)),
              );
            },
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

class ListeDepotsScreen extends StatefulWidget {
  final String tourneeId;
  final List livraisons;

  ListeDepotsScreen({required this.tourneeId, required this.livraisons});

  @override
  _ListeDepotsScreenState createState() => _ListeDepotsScreenState();
}

class _ListeDepotsScreenState extends State<ListeDepotsScreen> {
  List depotIds = [];
  List depots = [];

  int _currentIndex = 0;

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pop(context); // Go back to HomeScreen
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PaniersScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CarteScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ScannerScreen()),
        );
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _extractDepotIds();
  }

  void _extractDepotIds() {
    Set depotIdSet = {};
    Set depotSet = {};
    for (var livraison in widget.livraisons) {
      depotIdSet.add(livraison['depot_id']);
      depotSet.add(livraison['depot']);
    }
    setState(() {
      depotIds = depotIdSet.toList();
      depots = depotSet.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dépôts de la tournée ${widget.tourneeId}')),
      body: ListView.builder(
        itemCount: depotIds.length,
        itemBuilder: (context, index) {
          var depotId = depotIds[index];
          var depot = depots[index];
          return ListTile(
            title: Text('Dépôt : $depot'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CarteDepotScreen(depotId: depotId, depotName: depot),
                ),
              );
            },
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

class CarteDepotScreen extends StatefulWidget {
  final String depotId;
  final String depotName;

  CarteDepotScreen({required this.depotId, required this.depotName});

  @override
  _CarteDepotScreenState createState() => _CarteDepotScreenState();
}

class _CarteDepotScreenState extends State<CarteDepotScreen> {
  LatLng? depotCoordinates;
  Map<String, dynamic>? depotDetails; // To store all depot information

  @override
  void initState() {
    super.initState();
    _fetchDepotCoordinates();
    _fetchDepotDetails(); // Fetch all depot details
  }

  Future<void> _fetchDepotCoordinates() async {
    final response = await http.get(
      Uri.parse(
        'https://qjnieztpwnwroinqrolm.supabase.co/rest/v1/detail_depots?depot_id=eq.${widget.depotId}',
      ),
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqbmllenRwd253cm9pbnFyb2xtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4MTEwNTAsImV4cCI6MjA1MzM4NzA1MH0.orLZFmX3i_qR0H4H6WwhUilNf5a1EAfrFhbbeRvN41M',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqbmllenRwd253cm9pbnFyb2xtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4MTEwNTAsImV4cCI6MjA1MzM4NzA1MH0.orLZFmX3i_qR0H4H6WwhUilNf5a1EAfrFhbbeRvN41M',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        var localisation = data[0]['localisation'];
        double longitude = localisation['coordinates'][0];
        double latitude = localisation['coordinates'][1];
        setState(() {
          depotCoordinates = LatLng(latitude, longitude);
        });
      }
    } else {
      print('Erreur lors de la récupération des coordonnées du dépôt');
    }
  }

  Future<void> _fetchDepotDetails() async {
    final response = await http.get(
      Uri.parse(
        'https://qjnieztpwnwroinqrolm.supabase.co/rest/v1/detail_depots?depot_id=eq.${widget.depotId}',
      ),
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqbmllenRwd253cm9pbnFyb2xtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4MTEwNTAsImV4cCI6MjA1MzM4NzA1MH0.orLZFmX3i_qR0H4H6WwhUilNf5a1EAfrFhbbeRvN41M',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqbmllenRwd253cm9pbnFyb2xtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4MTEwNTAsImV4cCI6MjA1MzM4NzA1MH0.orLZFmX3i_qR0H4H6WwhUilNf5a1EAfrFhbbeRvN41M',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        setState(() {
          depotDetails = data[0]; // Store all depot details
        });
      }
    } else {
      print('Erreur lors de la récupération des détails du dépôt');
    }
  }

  void _openGoogleMaps() async {
  final String googleMapsUrl =
      'https://www.google.com/maps/dir/?api=1&destination=${depotCoordinates!.latitude},${depotCoordinates!.longitude}';

  if (await canLaunch(googleMapsUrl)) {
    await launch(googleMapsUrl);
  } else {
    throw 'Could not launch $googleMapsUrl';
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détails du Dépôt: ${widget.depotName}')),
      body: depotDetails == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display depot details
                  Text(
                    'Nom du Dépôt: ${depotDetails!['depot']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'ID du Dépôt: ${depotDetails!['depot_id']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Adresse: ${depotDetails!['adresse'] ?? 'Non disponible'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Ville: ${depotDetails!['ville'] ?? 'Non disponible'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Code Postal: ${depotDetails!['code_postal'] ?? 'Non disponible'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Téléphone: ${depotDetails!['telephone'] ?? 'Non disponible'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Email: ${depotDetails!['email'] ?? 'Non disponible'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  // Button to open Google Maps
                  Center(
                    child: ElevatedButton(
                      onPressed: _openGoogleMaps,
                      child: Text('Ouvrir dans Google Maps'),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2, // Highlight the "Carte" tab
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pop(context); // Go back to HomeScreen
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaniersScreen()),
              );
              break;
            case 2:
              // Already on the CarteScreen
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScannerScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.blue,
      selectedItemColor: Colors.grey[500],
      unselectedItemColor: Colors.grey[800],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tournées'),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart), label: 'Paniers'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Carte'),
        BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner), label: 'Scanner'),
      ],
    );
  }
}

// Placeholder screens for navigation
class PaniersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Paniers')),
      body: Center(child: Text('Paniers Screen')),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}

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

class ScannerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scanner')),
      body: Center(child: Text('Scanner Screen')),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}
