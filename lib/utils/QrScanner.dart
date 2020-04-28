import 'package:flutter/material.dart';
import 'package:ims_xpress/const/Constants.dart';
import 'package:ims_xpress/utils/Others.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';

class QrScanner extends StatefulWidget {
  @override
  _QrScannerState createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  // this class creates the qr code scanner
  GlobalKey _key = GlobalKey();
  String qrText = '';
  QRViewController _controller;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, '');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Scan QR Code'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.white,
              ),
              onPressed: () {
                _showTextDialog();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.done,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, qrText);
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 9,
              child: QRView(
                key: _key,
                overlay: QrScannerOverlayShape(
                    borderColor: Constants.redLight,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 200),
                onQRViewCreated: _onQrViewCreated,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: Text(
                  'QR Result = $qrText',
                  style: TextStyle(fontSize: 17.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onQrViewCreated(QRViewController controller) {
    // this function listens to the continuous data from the camera
    this._controller = controller;
    _controller.scannedDataStream.listen((data) {
      setState(() {
        qrText = data;
      });
    });
  }

  _showTextDialog() {
    var controller = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter qr code manually'),
            content: Container(
              height: 120.0,
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(labelText: 'qr code here'),
                  ),
                  RaisedButton(
                    onPressed: () {
                      var code = controller.text.toString().trim();
                      if (code.isEmpty) {
                        Others.showToast('Enter qr code first', true);
                      } else {
                        Navigator.pop(context);
                        Navigator.pop(context, code);
                      }
                    },
                    color: Constants.redLight,
                    child: Text(
                      'Set',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
