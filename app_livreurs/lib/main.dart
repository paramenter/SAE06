import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(LivreurApp());
}

class LivreurApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Livreur App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TourneeScreen(),
    );
  }
}

// Model for Depot
class Depot {
  final int depotId;
  final String depot;
  final String adresse;
  final String ville;
  final List<double> coordinates;

  Depot({required this.depotId, required this.depot, required this.adresse, required this.ville, required this.coordinates});

  factory Depot.fromJson(Map<String, dynamic> json) {
    // Assurez-vous que 'localisation' n'est pas null et que 'coordinates' existe
    List<double> coords = [];
    if (json['localisation'] != null && json['localisation']['coordinates'] != null) {
      coords = List<double>.from(json['localisation']['coordinates']);
    }
    return Depot(
      depotId: json['depot_id'] ?? -1, // Si 'depot_id' est manquant, utilisez une valeur par défaut
      depot: json['depot'] ?? 'Inconnu', // Si 'depot' est manquant, utilisez 'Inconnu'
      adresse: json['adresse'] ?? 'Adresse non fournie', // Valeur par défaut si manquante
      ville: json['ville'] ?? 'Ville non fournie', // Valeur par défaut si manquante
      coordinates: coords,
    );
  }
}

// Model for Livraison
class Livraison {
  final String tournee;
  final String produit;
  final String depot;
  final String adresse;
  final String ville;
  final List<double> coordinates;

  Livraison({required this.tournee, required this.produit, required this.depot, required this.adresse, required this.ville, required this.coordinates});

  factory Livraison.fromJson(Map<String, dynamic> json) {
    // Assurez-vous que 'localisation' n'est pas null et que 'coordinates' existe
    List<double> coords = [];
    if (json['localisation'] != null && json['localisation']['coordinates'] != null) {
      coords = List<double>.from(json['localisation']['coordinates']);
    }
    return Livraison(
      tournee: json['tournee'] ?? 'Non définie', // Valeur par défaut si manquante
      produit: json['produit'] ?? 'Produit non fourni', // Valeur par défaut si manquante
      depot: json['depot'] ?? 'Dépôt inconnu', // Valeur par défaut si manquante
      adresse: json['adresse'] ?? 'Adresse non fournie', // Valeur par défaut si manquante
      ville: json['ville'] ?? 'Ville non fournie', // Valeur par défaut si manquante
      coordinates: coords,
    );
  }
}


// API Service to fetch data
class ApiService {
  static const String baseUrl =
      'https://qjnieztpwnwroinqrolm.supabase.co/rest/v1/';
  static const String apiKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqbmllenRwd253cm9pbnFyb2xtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4MTEwNTAsImV4cCI6MjA1MzM4NzA1MH0.orLZFmX3i_qR0H4H6WwhUilNf5a1EAfrFhbbeRvN41M'; // Replace with your real API key

  Future<List<Depot>> fetchDepots() async {
    final response = await http.get(
      Uri.parse('${baseUrl}detail_depots'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'apikey': apiKey,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Depot.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load depots');
    }
  }

  // Function to fetch livraisons info for a specific date with API Key in headers
  Future<List<Livraison>> fetchLivraisons(String date) async {
    final response = await http.get(
      Uri.parse('${baseUrl}detail_livraisons?jour=eq.$date'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'apikey': apiKey, // Adding the apikey in the headers
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Livraison.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load livraisons');
    }
  }

  // Function to fetch depot details by depotId with API Key in headers
  Future<Depot> fetchDepotDetails(String depotId) async {
    final response = await http.get(
      Uri.parse('${baseUrl}detail_depots?depot_id=eq.$depotId'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'apikey': apiKey, // Adding the apikey in the headers
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return Depot.fromJson(jsonData[0]);
    } else {
      throw Exception('Failed to load depot details');
    }
  }

  // Function to fetch tournee info by tourneeId with API Key in headers
  Future<List<Tournee>> fetchTourneeDetails(int tourneeId) async {
    final response = await http.get(
      Uri.parse('${baseUrl}detail_tournees?tournee_id=eq.$tourneeId'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'apikey': apiKey, // Adding the apikey in the headers
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Tournee.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tournee details');
    }
  }
}

class Tournee {
  final int tourneeId;
  final String tournee;
  final int preparationId;
  final String preparation;
  final int ordre;
  final int distributionId;
  final String nom;
  final String adresse;
  final String codePostal;
  final String ville;
  final Map<String, dynamic> localisation;

  Tournee({
    required this.tourneeId,
    required this.tournee,
    required this.preparationId,
    required this.preparation,
    required this.ordre,
    required this.distributionId,
    required this.nom,
    required this.adresse,
    required this.codePostal,
    required this.ville,
    required this.localisation,
  });

  factory Tournee.fromJson(Map<String, dynamic> json) {
    return Tournee(
      tourneeId: json['tournee_id'] ?? -1, // Default if null
      tournee: json['tournee'] ?? 'null', // If 'tournee' is null, return 'null'
      preparationId: json['preparation_id'] ?? -1, // Default if null
      preparation: json['preparation'] ??
          'null', // If 'preparation' is null, return 'null'
      ordre: json['ordre'] ?? -1, // Default if null
      distributionId: json['distribution_id'] ?? -1, // Default if null
      nom: json['nom'] ?? 'null', // If 'nom' is null, return 'null'
      adresse: json['adresse'] ?? 'null', // If 'adresse' is null, return 'null'
      codePostal: json['codepostal'] ??
          'null', // If 'codepostal' is null, return 'null'
      ville: json['ville'] ?? 'null', // If 'ville' is null, return 'null'
      localisation: json['localisation'] ?? {}, // Default if null
    );
  }
}

// Tournee Screen - List the tournées for the selected date
class TourneeScreen extends StatefulWidget {
  @override
  _TourneeScreenState createState() => _TourneeScreenState();
}

class _TourneeScreenState extends State<TourneeScreen> {
  late Future<List<Livraison>> livraisons;

  @override
  void initState() {
    super.initState();
    livraisons = ApiService()
        .fetchLivraisons('2025-02-26'); // Date hardcoded as an example
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liste des tournées')),
      body: FutureBuilder<List<Livraison>>(
        future: livraisons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune tournée pour cette date.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final livraison = snapshot.data![index];
                return ListTile(
                  title: Text(livraison.tournee),
                  subtitle: Text('Produit: ${livraison.produit}'),
                  onTap: () {
                    // Passer à l'écran suivant avec les détails du dépôt
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DepotScreen(depotId: livraison.depot),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

// Depot Screen - Show details about a selected depot
class DepotScreen extends StatelessWidget {
  final String depotId;

  DepotScreen({required this.depotId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détails du dépôt')),
      body: FutureBuilder<Depot>(
        future: ApiService().fetchDepotDetails(depotId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Aucun dépôt trouvé.'));
          } else {
            final depot = snapshot.data!;
            return Column(
              children: [
                Text('Dépôt: ${depot.depot}'),
                Text('Adresse: ${depot.adresse}'),
                Text('Ville: ${depot.ville}'),
                Container(
                  height: 300,
                  width: double.infinity,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target:
                          LatLng(depot.coordinates[1], depot.coordinates[0]),
                      zoom: 12,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('depot'),
                        position:
                            LatLng(depot.coordinates[1], depot.coordinates[0]),
                      ),
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the QR code scanner screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanQRScreen(),
                      ),
                    );
                  },
                  child: Text('Scanner QR Code'),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

// QR Scanner Screen
class ScanQRScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scanner QR Code')),
    );
  }
}
