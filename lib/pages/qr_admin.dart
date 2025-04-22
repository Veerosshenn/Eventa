import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'consts.dart';

class QrAdmin extends StatefulWidget {
  const QrAdmin({super.key});

  @override
  State<QrAdmin> createState() => _QrAdminState();
}

class _QrAdminState extends State<QrAdmin> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isScanned = false;

  void _handleBarcode(Barcode barcode) async {
    if (_isScanned || barcode.rawValue == null) return;

    final scannedUID = barcode.rawValue!;
    setState(() => _isScanned = true);

    try {
      // Search all users
      final usersSnapshot = await _firestore.collection('users').get();

      for (final userDoc in usersSnapshot.docs) {
        final bookedTickets = userDoc.data()['bookedTicket'] as List<dynamic>?;

        if (bookedTickets == null) continue;

        for (final ticket in bookedTickets) {
          if (ticket['boughtTicketUID'] == scannedUID) {
            _showTicketDialog(ticket);
            return;
          }
        }
      }

      // No ticket found
      _showTicketDialog(null);
    } catch (e) {
      debugPrint("Error searching ticket: $e");
      _showTicketDialog(null);
    }

    // Reset scan after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      setState(() => _isScanned = false);
    });
  }

  void _showTicketDialog(Map<String, dynamic>? ticket) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(child: Text(ticket != null ? 'Ticket Details'.tr() : 'Ticket Not Found'.tr())),
        content: ticket != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Icon(Icons.check_circle, color: Colors.green, size: 60)),
                  const SizedBox(height: 16),
                  _buildDetailRow("Event", ticket['title']),
                  _buildDetailRow("Type", ticket['ticketType']),
                  _buildDetailRow("Amount", ticket['ticketAmount'].toString()),
                  _buildDetailRow("Total", "RM${ticket['totalAmount']}"),
                  _buildDetailRow(
                    "Seats",
                    ticket['selectedSeats'] is List
                        ? (ticket['selectedSeats'] as List).join(', ')
                        : ticket['selectedSeats'],
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: Icon(Icons.error, color: Colors.red, size: 60)),
                  SizedBox(height: 10),
                  Text("No matching ticket was found.".tr()),
                ],
              ),
        actions: [
          TextButton(
            child: Text("Close".tr()),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isScanned = false;
              });
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'.tr()),
        backgroundColor: buttonColor,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: MobileScanner(
              onDetect: (barcodeCapture) {
                final barcodes = barcodeCapture.barcodes;
                for (final barcode in barcodes) {
                  _handleBarcode(barcode);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
