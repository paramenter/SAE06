import 'package:flutter/material.dart';
import 'carte_depot_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import 'carte_screen.dart';
import 'scanner_screen.dart';

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
          MaterialPageRoute(builder: (context) => CarteScreen()),
        );
        break;
      case 2:
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
      appBar: AppBar(
        title: Text('Dépôts de la tournée ${widget.tourneeId}'),
        elevation: 4,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: depotIds.length,
        itemBuilder: (context, index) {
          var depotId = depotIds[index];
          var depot = depots[index];
          return Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(
                'Dépôt : $depot',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CarteDepotScreen(depotId: depotId, depotName: depot, tourneeId: widget.tourneeId),
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