import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ims_xpress/const/Constants.dart';
import 'package:ims_xpress/utils/Others.dart';
import 'package:ims_xpress/views/ActivityDashBoard.dart';
import 'package:ims_xpress/views/ActivityLowStock.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityAnalyticsAndReports extends StatefulWidget {
  @override
  _ActivityAnalyticsAndReportsState createState() =>
      _ActivityAnalyticsAndReportsState();
}

class _ActivityAnalyticsAndReportsState
    extends State<ActivityAnalyticsAndReports> {
  List<DocumentSnapshot> _lowInventory = List();
  List<DocumentSnapshot> _receipts = List();
  List<DocumentSnapshot> _items = List();
  List<DocumentSnapshot> _lastMonthItems = List();
  double _revenue = 0.0;
  double _profit = 0.0;
  DateTime _currentDate;
  bool _isLoading = true;

  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ActivityDashBoard()));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Analytics And Report'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => ActivityDashBoard()));
            },
          ),
        ),
        body: _isLoading ? Others.loadingContainer() : _body(),
      ),
    );
  }

  _body() {
    return Container(
      margin: EdgeInsets.only(left: 32.0, right: 32.0, top: 8.0),
      child: ListView(
        children: <Widget>[
          _lowInventory.isEmpty ? Container() : _getLowStockBlock(),
          SizedBox(
            height: 24.0,
          ),
          _currentDate == null
              ? Text(
                  'No sales record for last month',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Constants.redLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 21.0,
                  ),
                )
              : Text(
                  '${_currentDate.day}/${_currentDate.month}/${_currentDate.year}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Constants.redLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 21.0,
                  ),
                ),
          SizedBox(
            height: 24.0,
          ),
          _currentDate != null
              ? _getMidSection(
                  'Revenue', _revenue.toStringAsFixed(3), 'images/revenue.png')
              : Container(),
          SizedBox(
            height: 8.0,
          ),
          _currentDate != null
              ? _getMidSection(
                  'Profit', _profit.toStringAsFixed(3), 'images/profit.png')
              : Container(),
          SizedBox(
            height: 8.0,
          ),
          _currentDate != null
              ? _getMidSection('Sales', _lastMonthItems.length.toString(),
                  'images/sales.png')
              : Container(),
        ],
      ),
    );
  }

  _getMidSection(String title, String amount, String imagePath) {
    String value = title == 'Sales' ? amount : '\$${amount}';
    return Container(
      height: 100,
      child: Card(
        elevation: 3.0,
        child: Padding(
          padding: EdgeInsets.only(
            left: 32.0,
          ),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundImage: AssetImage(imagePath),
                radius: 32.0,
              ),
              SizedBox(
                width: 16.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(color: Colors.black54, fontSize: 17.0),
                  ),
                  Text(
                    value,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 21.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getLowStockBlock() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ActivityLowStock()));
      },
      child: Container(
        height: 150.0,
        color: Colors.transparent,
        child: Card(
          elevation: 3.0,
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Low Stock Inventory',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15.0,
                  ),
                ),
                SizedBox(
                  height: 4.0,
                ),
                Text(
                  '${_lowInventory[0]['title']}',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 21.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 4.0,
                ),
                Text(
                  '${_lowInventory[0]['quantity']} items remaining',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 4.0,
                ),
                Text(
                  '${_lowInventory.length - 1} more inventory are low',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _getReceipt() {
    // this function fetches receipts from firestore
    Firestore.instance
        .collection('receipts')
        .getDocuments()
        .then((querySnapshot) {
      if (querySnapshot.documents.isNotEmpty) {
        querySnapshot.documents.forEach((documentSnapshot) {
          _receipts.add(documentSnapshot);
        });
        _getLastMonthReceipts();
      } else {
        setState(() {
          _isLoading = false;
          Others.showToast('No sales found', true);
        });
      }
    }).catchError((error) {
      setState(() {
        _isLoading = false;
        Others.showToast('No sales record found', true);
      });
    });
  }

  _getData() async {
    // this function fetches all products from firestore
    SharedPreferences pref = await SharedPreferences.getInstance();
    int threshold = await pref.getInt('threshold' ?? 50);
    Firestore.instance
        .collection('products')
        .orderBy('timestamp', descending: false)
        .getDocuments()
        .then((querySnapshot) {
      if (querySnapshot.documents.length > 0) {
        querySnapshot.documents.forEach((documentSnapshot) {
          _items.add(documentSnapshot);
          if (documentSnapshot['quantity'] <= threshold) {
            _lowInventory.add(documentSnapshot);
          }
        });
        _getReceipt();
      } else {
        setState(() {
          _isLoading = false;
        });
        Others.showToast('No data found', true);
      }
    }).catchError((error) {
      setState(() {
        Others.showToast('No data found', true);
        _isLoading = false;
      });
    });
  }

  _getLastMonthReceipts() {
    // filters out the last months receipts
    var date = DateTime.now();
    var isJan = false;
    if (date.month == 1) {
      isJan = true;
    }
    _receipts.forEach((documentSnapshot) {
      if (isJan) {
        if (documentSnapshot['date'].toDate().month == 12) {
          _lastMonthItems.add(documentSnapshot);
        }
      } else {
        if (documentSnapshot['date'].toDate().month == date.month - 1) {
          _lastMonthItems.add(documentSnapshot);
        }
      }
    });
    _calculateRevenueAndProfit();
    _currentDate = _lastMonthItems[0]['date'].toDate();
    setState(() {
      _isLoading = false;
    });
  }

  _calculateRevenueAndProfit() {
    // this function calculates total revenue and the profit
    _lastMonthItems.forEach((documentSnapshot) {
      _revenue += documentSnapshot['revenue'];
      _profit += documentSnapshot['profit'];
    });
  }
}
