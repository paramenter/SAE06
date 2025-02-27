import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Clients',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Index actuel de la barre de navigation

  // Liste des pages à afficher
  final List<Widget> _pages = [
    DashboardPage(
      adherentId: 47476,
    ),
    HistoriquePage(
      adherentId: 47476,
    ),
    NotificationsPage(),
  ];

  // Fonction pour changer de page
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info livraison jardin de cocagne'),
      ),
      body: _pages[_selectedIndex], // Affiche la page correspondant à l'index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}

// Page du Tableau de bord
class DashboardPage extends StatefulWidget {
  final int adherentId; // Identifiant de l'adhérent

  const DashboardPage({super.key, required this.adherentId});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final String baseUrl =
      'https://qjnieztpwnwroinqrolm.supabase.co/rest/v1/detail_livraisons';
  final String apiKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqbmllenRwd253cm9pbnFyb2xtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4MTEwNTAsImV4cCI6MjA1MzM4NzA1MH0.orLZFmX3i_qR0H4H6WwhUilNf5a1EAfrFhbbeRvN41M';

  Future<List<dynamic>> fetchUpcomingDeliveries() async {
    final response = await http.get(
      Uri.parse('$baseUrl?adherent_id=eq.${widget.adherentId}'
          '&jour=gte.${DateTime.now().toIso8601String().substring(0, 10)}'
          '&order=jour.asc'
          '&limit=10'),
      headers: {
        'apikey': apiKey,
        'Authorization': 'Bearer $apiKey',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des livraisons à venir');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de Bord')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<dynamic>>(
          future: fetchUpcomingDeliveries(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucune livraison prévue.'));
            } else {
              final deliveries = snapshot.data!;
              return ListView.builder(
                itemCount: deliveries.length,
                itemBuilder: (context, index) {
                  final delivery = deliveries[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text('Livraison du ${delivery['jour']}'),
                      subtitle: Text(
                        'Dépôt : ${delivery['depot']}\n'
                        'Produit : ${delivery['produit']} - Qté: ${delivery['qte']}',
                      ),
                      onTap: () {
                        _showDeliveryDetails(context, delivery);
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  void _showDeliveryDetails(
      BuildContext context, Map<String, dynamic> delivery) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Détails de la Livraison'),
          content: Text(
            'Nom : ${delivery['adherent']}\n'
            'Adresse : ${delivery['adresse_id']}\n'
            'Dépôt : ${delivery['depot']}\n'
            'Produit : ${delivery['produit']}\n'
            'Quantité : ${delivery['qte']}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}

// Page de l'Historique
class HistoriquePage extends StatefulWidget {
  final int adherentId; // Identifiant de l'adhérent

  const HistoriquePage({super.key, required this.adherentId});

  @override
  _HistoriquePageState createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  final String baseUrl =
      'https://qjnieztpwnwroinqrolm.supabase.co/rest/v1/detail_livraisons';
  final String apiKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqbmllenRwd253cm9pbnFyb2xtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4MTEwNTAsImV4cCI6MjA1MzM4NzA1MH0.orLZFmX3i_qR0H4H6WwhUilNf5a1EAfrFhbbeRvN41M';
  Future<List<dynamic>> fetchUserDeliveries() async {
    final response = await http.get(
      Uri.parse('$baseUrl?adherent_id=eq.${widget.adherentId}'
          '&jour=lt.${DateTime.now().toIso8601String().substring(0, 10)}'
          '&order=jour.desc'),
      headers: {
        'apikey': apiKey,
        'Authorization': 'Bearer $apiKey',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du chargement de l\'historique');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique des Livraisons')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<dynamic>>(
          future: fetchUserDeliveries(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucune livraison trouvée.'));
            } else {
              final deliveries = snapshot.data!;
              return ListView.builder(
                itemCount: deliveries.length,
                itemBuilder: (context, index) {
                  final delivery = deliveries[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text('Livraison du ${delivery['jour']}'),
                      subtitle: Text(
                          'Dépôt : ${delivery['depot']}\nProduit : ${delivery['produit']} - Qté: ${delivery['qte']}'),
                      onTap: () {
                        _showDeliveryDetails(context, delivery);
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  void _showDeliveryDetails(
      BuildContext context, Map<String, dynamic> delivery) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Détails de la Livraison'),
          content: Text(
            'Nom : ${delivery['adherent']}\n'
            'Adresse : ${delivery['adresse_id']}\n' // Adresse à récupérer correctement
            'Dépôt : ${delivery['depot']}\n'
            'Produit : ${delivery['produit']}\n'
            'Quantité : ${delivery['qte']}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}

// Page des Notifications
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Notifications',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
