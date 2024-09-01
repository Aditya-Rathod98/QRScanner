import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';


class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: (result != null)
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Result: ${result!.code}'),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (result != null && _isURL(result!.code!)) {
                      _launchURL(result!.code!);
                    }
                  },
                  child: Text('Open Link'),
                ),
              ],
            )
                : Text('Scan a code'),
          ),
        ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      if (result != null && _isURL(result!.code!)) {
        _launchURL(result!.code!);
      }
    });
  }

  bool _isURL(String code) {
    final Uri? uri = Uri.tryParse(code);
    return uri != null && uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }


  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
