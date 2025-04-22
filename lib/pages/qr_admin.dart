import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:easy_localization/easy_localization.dart';
import 'consts.dart';

class QrAdmin extends StatefulWidget {
  const QrAdmin({super.key});

  @override
  State<QrAdmin> createState() => _QrAdminState();
}

class _QrAdminState extends State<QrAdmin> {
  bool _isScanned = false;

  void _handleBarcode(Barcode barcode) {
    if (!_isScanned && barcode.rawValue != null) {
      setState(() {
        _isScanned = true;
      });

      final code = barcode.rawValue!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("QR Code scanned successfully: $code"),
          backgroundColor: Colors.green,
        ),
      );

      // Reset after 3 seconds to allow scanning again
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _isScanned = false;
        });
      });
    }
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
                final List<Barcode> barcodes = barcodeCapture.barcodes;
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
