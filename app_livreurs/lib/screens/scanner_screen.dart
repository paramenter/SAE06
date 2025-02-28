import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String scannedResult = 'Scan a QR Code';
  String? capturedResult;

  @override
  void dispose() {
    controller?.dispose(); // Dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner QR Code'),
        centerTitle: true,
        elevation: 4,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                scannedResult,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _captureQRCode,
            child: Text('Capture QR Code'),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller; // Initialize the controller
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        scannedResult = scanData.code ?? 'No data found';
      });
    });
  }

  void _captureQRCode() async {
    if (scannedResult != 'Scan a QR Code' && scannedResult != 'No data found') {
      setState(() {
        capturedResult = scannedResult;
      });

      // Call the API to get the meaning of the QR code
      final meaning = await _getQRCodeMeaning(capturedResult!);

      // Navigate to a new screen with the captured result and its meaning
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScannedResultScreen(
            result: capturedResult!,
            meaning: meaning,
          ),
        ),
      );
    }
  }

  Future<String> _getQRCodeMeaning(String qrCodeData) async {
    // Replace with your API endpoint
    final apiUrl = 'https://api.example.com/decode-qr';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({'qr_code': qrCodeData}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['meaning'] ?? 'No meaning found';
      } else {
        return 'Failed to fetch meaning';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}

class ScannedResultScreen extends StatelessWidget {
  final String result;
  final String meaning;

  ScannedResultScreen({required this.result, required this.meaning});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanned Result'),
        centerTitle: true,
        elevation: 4,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Scanned Result: $result',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Meaning: $meaning',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ScannerScreen(),
  ));
}