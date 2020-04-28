import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ims_xpress/const/Constants.dart';
import 'package:ims_xpress/utils/Others.dart';
import 'package:ims_xpress/utils/TextFields.dart';
import 'package:ims_xpress/views/ActivityCategoryProducts.dart';
import 'package:ims_xpress/views/ActivityCheckList.dart';
import 'package:ims_xpress/views/ActivityDashBoard.dart';
import 'package:ims_xpress/views/ActivityLowStock.dart';

class ActivityProductDetails extends StatefulWidget {
  DocumentSnapshot _snapshot;
  Object _obj;

  ActivityProductDetails(this._snapshot, this._obj);

  @override
  _ActivityProductDetailsState createState() =>
      _ActivityProductDetailsState(_snapshot, _obj);
}

class _ActivityProductDetailsState extends State<ActivityProductDetails> {
  DocumentSnapshot _snapshot;
  Object _obj;
  bool _isAdding = false;

  _ActivityProductDetailsState(this._snapshot, this._obj);

  double _totalValue;

  @override
  Widget build(BuildContext context) {
    _totalValue = _snapshot['quantity'] * _snapshot['selling_price'];
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => _obj is ActivityLowStock
                ? ActivityLowStock()
                : _obj is ActivityDashBoard
                    ? ActivityDashBoard()
                    : ActivityCategoryProducts(_snapshot['category']),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Product Details'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => _obj is ActivityLowStock
                      ? ActivityLowStock()
                      : ActivityCategoryProducts(_snapshot['category']),
                ),
              );
            },
          ),
        ),
        body: Stack(
          children: <Widget>[
            _isAdding ? Others.loadingContainer() : _getBody(),
          ],
        ),
      ),
    );
  }

  _getBody() {
    return ListView(
      children: <Widget>[
        Container(
          height: 200.0,
          color: Colors.black12,
          child: Image.network(_snapshot['image_url']),
        ),
        SizedBox(
          height: 8.0,
        ),
        TextFields.getTitleText(_snapshot['title']),
        Divider(),
        SizedBox(
          height: 24.0,
        ),
        TextFields.getText(_snapshot['quantity'].toString(), 'Quantity'),
        Divider(),
        SizedBox(
          height: 24.0,
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: TextFields.getText(
                  '\$${_snapshot['buying_price']}', 'Buying Price'),
            ),
            Expanded(
              child: TextFields.getText(
                  '\$${_snapshot['selling_price']}', 'Selling Price'),
            ),
          ],
        ),
        Divider(),
        SizedBox(
          height: 24.0,
        ),
        TextFields.getText(
            '\$${_totalValue.toStringAsFixed(3)}', 'Total Value'),
        Divider(),
        SizedBox(
          height: 24.0,
        ),
        TextFields.getText(_snapshot['special_note'], "Special Note"),
        Divider(),
        SizedBox(
          height: 24.0,
        ),
        TextFields.getText(_snapshot['tag'], 'Tag'),
        Divider(),
        SizedBox(
          height: 24.0,
        ),
        Others.getQrScannerLayout(_snapshot['qr_code_data']),
        SizedBox(
          height: 16.0,
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 32.0, right: 32.0, bottom: 16.0),
                child: RaisedButton(
                    child: Text(
                      'Add to Checklist',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    color: Constants.redLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    onPressed: _addProductToCheckList),
              ),
            )
          ],
        ),
      ],
    );
  }

  _addProductToCheckList() {
    // saves data to checklist
    if (_snapshot['quantity'] <= 0) {
      Others.showToast('Cannot add this item to checklist', true);
    } else {
      setState(() {
        _isAdding = true;
      });
      Map map = _snapshot.data;
      map['product_id'] = _snapshot.documentID;
      Firestore.instance
          .collection('checklist')
          .document(_snapshot.documentID)
          .setData(map)
          .then((val) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return ActivityCheckList();
        }));
      }).catchError((error) {
        Others.showToast('There was an error', true);
        setState(() {
          _isAdding = false;
        });
      });
    }
  }
}
