import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:ims_xpress/const/Constants.dart';
import 'package:ims_xpress/utils/Others.dart';
import 'package:ims_xpress/views/ActivitySalesHistory.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class ActivityReceipt extends StatefulWidget {
  DocumentSnapshot _snapshot;

  ActivityReceipt(this._snapshot);

  @override
  _ActivityReceiptState createState() => _ActivityReceiptState(_snapshot);
}

class _ActivityReceiptState extends State<ActivityReceipt> {
  DocumentSnapshot _snapshot;
  List<DocumentSnapshot> _items = List();
  File _imageFile;
  ScreenshotController _screenshotController = ScreenshotController ( );
  bool _isLoading = true;
  var _subTotal = 0.0;
  var _tax = 0.0;
  var _total = 0.0;

  _ActivityReceiptState(this._snapshot);

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  _fetchData() {
    Firestore.instance
        .collection('receipts')
        .document(_snapshot.documentID)
        .collection('items')
        .getDocuments()
        .then((querySnapshot) {
      if (querySnapshot.documents.length > 0) {
        querySnapshot.documents.forEach((documentSnapshot) {
          _items.add(documentSnapshot);
        });
        _calculateSubTotal();
        setState ( ( ) {
          _isLoading = false;
        } );
      } else {
        setState(() {
          _isLoading = false;
        });
        Others.showToast('There was an error', true);
      }
    }).catchError((error) {
      setState(() {
        _isLoading = false;
        Others.showToast('There was an error', true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: _isLoading ? Others.loadingContainer ( ) : _body ( ),
        ),
        onWillPop: () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ActivitySalesHistory()));
        });
  }

  _body() {
    return Screenshot (
      controller: _screenshotController,
      child: Container (
        color: Colors.white,
        child: ListView (
          padding: EdgeInsets.only ( top: 32.0 ),
          children: <Widget>[
            Align (
              alignment: Alignment.topRight,
              child: Container (
                margin: EdgeInsets.only ( right: 16.0 ),
                width: 55.0,
                child: RaisedButton (
                  color: Constants.redLight,
                  child: Icon (
                    Icons.clear,
                    color: Colors.white,
                  ),
                  shape: RoundedRectangleBorder (
                    borderRadius: BorderRadius.circular ( 16.0 ),
                  ),
                  onPressed: ( ) {
                    Navigator.of ( context ).pushReplacement (
                        MaterialPageRoute (
                            builder: ( context ) =>
                                ActivitySalesHistory ( ) ) );
                  },
                ),
              ),
            ),
            Align (
              alignment: Alignment.topRight,
              child: Container (
                margin: EdgeInsets.only ( right: 16.0, top: 16.0 ),
                child: Text (
                  'Receipt #${_snapshot['receipt_no']}',
                  style: TextStyle (
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0 ),
                ),
              ),
            ),
            Align (
              alignment: Alignment.topLeft,
              child: Container (
                margin: EdgeInsets.only ( left: 16.0 ),
                child: CircleAvatar (
                  backgroundImage: AssetImage ( 'images/logo.png' ),
                  radius: 55.0,
                ),
              ),
            ),
            Align (
              alignment: Alignment.topLeft,
              child: Container (
                width: 115.0,
                alignment: Alignment.center,
                margin: EdgeInsets.only ( left: 16.0, top: 8.0 ),
                child: Text ( '+9288776754' ),
              ),
            ),
            SizedBox (
              height: 32.0,
            ),
            _getDateQuantityRow ( ),
            Container (
              margin: EdgeInsets.only ( left: 16.0, right: 16.0 ),
              child: Divider (
                thickness: 2.0,
                color: Colors.black87,
              ),
            ),
            _getItems ( ),
            _getTaxSection ( ),
            _getFooter ( ),
          ],
        ),
      ),
    );
  }

  _getFooter() {
    return Container(
      height: 100.0,
      margin: EdgeInsets.only(top: 64.0),
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          GestureDetector(
            onTap: ( ) async {
              final directory = (await getApplicationDocumentsDirectory ( ))
                  .path;
              String fileName = 'receipt';
              var path = '$directory/$fileName.png';
              _screenshotController.capture (
                path: path,
              ).then ( ( image ) {
                _imageFile = image;
                _shareFile ( path );
              } );
            },
            child: Container(
              color: Colors.transparent,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.share,
                    color: Colors.white,
                  ),
                  Text(
                    '   Share',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      color: Constants.redLight,
    );
  }

  Future<void> _shareFile ( path ) async {
    // this function opens share bottom sheet
    await FlutterShare.shareFile(
      title: 'Receipt #${_snapshot['receipt_no']}',
      text: 'Sales record for receipt #${_snapshot['receipt_no']}',
      filePath: path.toString ( ),
    );
  }

  _getTaxSection() {
    return Container(
      color: Colors.transparent,
      height: 130.0,
      child: ListView(
        padding: EdgeInsets.only(top: 8.0),
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Container (
            margin: EdgeInsets.only(left: 16.0, right: 16.0),
            child: Divider (
              color: Colors.black87,
              thickness: 2.0,
            ),
          ),
          SizedBox(
            height: 24.0,
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'SUBTOTAL:',
                    style: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '\$$_subTotal',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'TAX:',
                    style: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '\$$_tax',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'TOTAL:',
                    style: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '\$$_total',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _getItems() {
    return Container(
      height: 160.0,
      child: ListView(
        children: _items.map((item) {
          return Container(
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text(
                    '${item['quantity']}x ${item['title']}',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '\$${item['selling_price']}',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  _getDateQuantityRow() {
    print(_snapshot.data.toString());
    return Container(
      margin: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              '${_items.length} Items',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${_snapshot['date'].toDate().day}/${_snapshot['date'].toDate().month}/${_snapshot['date'].toDate().year}',
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _calculateSubTotal ( ) {
    // this function calculates the subtotal
    _subTotal = 0;
    for (var i in _items) {
      _subTotal += i['selling_price'] * i['quantity'];
    }
    _calculateTax();
    setState(() {
      _total = _subTotal + _tax;
    });
  }

  _calculateTax ( ) {
    // calculates tax
    var percentage = _subTotal > 163706.25 ? 40 : 20;
    _tax = ((percentage * _subTotal) / 100);
  }
}
