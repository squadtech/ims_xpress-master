import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ims_xpress/const/Constants.dart';
import 'package:ims_xpress/utils/Others.dart';
import 'package:ims_xpress/views/ActivityCheckList.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';

class InventoryScanner extends StatefulWidget {
  @override
  _InventoryScannerState createState() => _InventoryScannerState();
}

class _InventoryScannerState extends State<InventoryScanner> {
  // this class creates the qr code scanner
  List<DocumentSnapshot> _products = List();
  GlobalKey _key = GlobalKey();
  String _qrText = '';
  QRViewController _controller;
  bool _isLoading = true;
  DocumentSnapshot _product;

  @override
  void initState() {
    Firestore.instance
        .collection('products')
        .getDocuments()
        .then((querySnapshot) {
      if (querySnapshot.documents.isNotEmpty) {
        querySnapshot.documents.forEach((documentSnapshot) {
          _products.add(documentSnapshot);
        });
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          Others.showToast('No products in database', true);
        });
      }
    }).catchError((error) {
      setState(() {
        _isLoading = false;
        Others.showToast(error.message, true);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ActivityCheckList();
            },
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Scan QR/Bar Code'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ActivityCheckList();
                  },
                ),
              );
            },
          ),
        ),
        body: _isLoading
            ? Others.loadingContainer()
            : Column(
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
                        'Result = $_qrText',
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
        _products.forEach((documentSnapshot) {
          if (documentSnapshot['qr_code_data'] == data) {
            this._product = documentSnapshot;
          }
        });
        if (_product == null) {
          _qrText = 'Item not in database';
        } else if (_product['quantity'] == 0) {
          _qrText = 'Item quantity is zero';
        } else {
          _addDataToCheckList();
        }
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
                    decoration: InputDecoration(labelText: 'enter code here'),
                  ),
                  RaisedButton(
                    onPressed: () {
                      var code = controller.text.toString().trim();
                      if (code.isEmpty) {
                        Others.showToast('Enter qr code first', true);
                      } else {
                        Navigator.pop(context);
                        _qrText = code;
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

  _addDataToCheckList() {
    if (_product != null) {
      var map = _product.data;
      map['product_id'] = _product.documentID;
      setState(() {
        _isLoading = true;
      });
      Firestore.instance
          .collection('checklist')
          .document(_product.documentID)
          .setData(map)
          .then((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ActivityCheckList();
            },
          ),
        );
      }).catchError((error) {
        setState(() {
          _isLoading = false;
          Others.showToast(error.message, true);
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
