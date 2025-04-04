import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class CarteDepotScreen extends StatefulWidget {
  final String depotId;
  final String tourneeId;
  final String depotName;

  CarteDepotScreen(
      {required this.depotId,
      required this.depotName,
      required this.tourneeId});

  @override
  _CarteDepotScreenState createState() => _CarteDepotScreenState();
}

class _CarteDepotScreenState extends State<CarteDepotScreen> {
  List<dynamic> products = [];
  Map<String, dynamic>? depotDetails;
  bool isLoading = true;
  LatLng? depotCoordinates;

  @override
  void initState() {
    super.initState();
    _fetchDepotDetails();
    _fetchDepotProducts();
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
          depotDetails = data[0];
          if (depotDetails!['localisation'] != null) {
            double longitude = depotDetails!['localisation']['coordinates'][0];
            double latitude = depotDetails!['localisation']['coordinates'][1];
            depotCoordinates = LatLng(latitude, longitude);
          }
        });
      }
    } else {
      print('Erreur lors de la récupération des détails du dépôt');
    }
  }

  Future<void> _fetchDepotProducts() async {
    String today = DateTime.now().toIso8601String().split('T')[0];
    final response = await http.get(
      Uri.parse(
        'https://qjnieztpwnwroinqrolm.supabase.co/rest/v1/detail_livraisons?jour=eq.$today&tournee_id=eq.${widget.tourneeId}&depot_id=eq.${widget.depotId}',
      ),
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqbmllenRwd253cm9pbnFyb2xtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4MTEwNTAsImV4cCI6MjA1MzM4NzA1MH0.orLZFmX3i_qR0H4H6WwhUilNf5a1EAfrFhbbeRvN41M',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqbmllenRwd253cm9pbnFyb2xtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4MTEwNTAsImV4cCI6MjA1MzM4NzA1MH0.orLZFmX3i_qR0H4H6WwhUilNf5a1EAfrFhbbeRvN41M',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
        isLoading = false;
      });
    } else {
      print('Erreur lors de la récupération des produits du dépôt');
      setState(() {
        isLoading = false;
      });
    }
  }
void _openWaze() async {
    if (depotCoordinates != null) {
      final String wazeUrl =
          'https://waze.com/ul?ll=${depotCoordinates!.latitude},${depotCoordinates!.longitude}&navigate=yes';

      if (await canLaunch(wazeUrl)) {
        await launch(wazeUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir Waze')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Coordonnées du dépôt non disponibles')),
      );
    }
  }
  void _openGoogleMaps() async {
    if (depotCoordinates != null) {
      final String googleMapsUrl =
          'https://www.google.com/maps/dir/?api=1&destination=${depotCoordinates!.latitude},${depotCoordinates!.longitude}';

      if (await canLaunch(googleMapsUrl)) {
        await launch(googleMapsUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir Google Maps')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Coordonnées du dépôt non disponibles')),
      );
    }
  }

  Future<void> _envoyerNotification(
      String livraisonId, String adherentId) async {
    const String serverKey = "TON_SERVER_KEY_FCM";
    final String fcmUrl = "https://fcm.googleapis.com/fcm/send";

    final response = await http.get(
      Uri.parse(
        'https://qjnieztpwnwroinqrolm.supabase.co/rest/v1/utilisateurs?adherent_id=eq.$adherentId',
      ),
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqbmllenRwd253cm9pbnFyb2xtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4MTEwNTAsImV4cCI6MjA1MzM4NzA1MH0.orLZFmX3i_qR0H4H6WwhUilNf5a1EAfrFhbbeRvN41M',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqbmllenRwd253cm9pbnFyb2xtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4MTEwNTAsImV4cCI6MjA1MzM4NzA1MH0.orLZFmX3i_qR0H4H6WwhUilNf5a1EAfrFhbbeRvN41M',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> utilisateurs = jsonDecode(response.body);
      if (utilisateurs.isNotEmpty && utilisateurs[0]['fcm_token'] != null) {
        final String fcmToken = utilisateurs[0]['fcm_token'];

        final notificationBody = {
          "to": fcmToken,
          "notification": {
            "title": "Livraison effectuée ✅",
            "body": "Votre panier a été livré au dépôt ${widget.depotName}.",
            "click_action": "FLUTTER_NOTIFICATION_CLICK"
          },
          "data": {
            "livraison_id": livraisonId,
            "depot": widget.depotName,
            "date": DateTime.now().toIso8601String(),
          }
        };

        final responseNotif = await http.post(
          Uri.parse(fcmUrl),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "key=$serverKey",
          },
          body: jsonEncode(notificationBody),
        );

        if (responseNotif.statusCode == 200) {
          print("✅ Notification envoyée avec succès !");
        } else {
          print("❌ Erreur lors de l'envoi de la notification");
        }
      } else {
        print("❌ Aucun token FCM trouvé pour cet adhérent.");
      }
    } else {
      print("❌ Erreur lors de la récupération du token FCM.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dépôt: ${widget.depotName}'),
        elevation: 4,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Depot Information
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dépôt: ${widget.depotName}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'ID du Dépôt: ${widget.depotId}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Adresse: ${depotDetails?['adresse'] ?? 'Non disponible'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Ville: ${depotDetails?['ville'] ?? 'Non disponible'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Code Postal: ${depotDetails?['code_postal'] ?? 'Non disponible'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Téléphone: ${depotDetails?['telephone'] ?? 'Non disponible'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Email: ${depotDetails?['email'] ?? 'Non disponible'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (depotCoordinates != null)
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: _openGoogleMaps,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text('Ouvrir dans Google Maps'),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: _openWaze,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text('Ouvrir dans Waze'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Produits à Livrer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var product = products[index];
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            '${product['livraison_id']} : ${product['produit']} ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quantité: ${product['qte']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Statut: ${product['livre']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.shopping_basket, size: 24),
                            onPressed: () => _envoyerNotification(
                                product['livraison_id'],
                                product['adherent_id']),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}