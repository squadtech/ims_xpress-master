import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ims_xpress/const/Constants.dart';
import 'package:ims_xpress/models/CheckListModel.dart';
import 'package:ims_xpress/utils/InventoryScanner.dart';
import 'package:ims_xpress/utils/Others.dart';
import 'package:ims_xpress/utils/QrScanner.dart';
import 'package:ims_xpress/views/ActivityCategories.dart';
import 'package:ims_xpress/views/ActivityDashBoard.dart';

class ActivityCheckList extends StatefulWidget {
  @override
  _ActivityCheckListState createState() => _ActivityCheckListState();
}

class _ActivityCheckListState extends State<ActivityCheckList> {
  TextEditingController _searchController = TextEditingController();
  List<CheckListModel> _dataList = List();
  List<DocumentSnapshot> _documentList = List();
  List<CheckListModel> _filteredList = List();
  bool _isLoading = true;
  var _subTotal = 0.0;
  var _tax = 0.0;
  var _total = 0.0;
  var _profit = 0.0;
  var _revenue = 0.0;
  int _count;

  @override
  void initState() {
    _getData();
    super.initState();
  }

  _getSearchBox() {
    return Container(
      height: 120.0,
      margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0),
      child: Card(
        elevation: 3.0,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return InventoryScanner();
                      },
                    ),
                  );
                },
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image(
                        image: AssetImage('images/scan.png'),
                        width: 55.0,
                        height: 55.0,
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        'SCAN',
                        style: TextStyle(fontSize: 17.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            VerticalDivider(
              thickness: 2.0,
            ),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  _showSearchDialog();
                },
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image(
                        image: AssetImage('images/img_search.png'),
                        width: 55.0,
                        height: 55.0,
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        'SEARCH',
                        style: TextStyle(fontSize: 17.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            VerticalDivider(
              thickness: 2.0,
            ),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (context) {
                    return ActivityCategories();
                  }));
                },
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image(
                        image: AssetImage('images/img_add.png'),
                        width: 55.0,
                        height: 55.0,
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        'ADD',
                        style: TextStyle(fontSize: 17.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
          centerTitle: true,
          title: Text('Checklist'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityDashBoard(),
                ),
              );
            },
          ),
        ),
        body: _isLoading
            ? Others.loadingContainer()
            : Stack(
          children: <Widget>[
            Container(
              height: 140.0,
              color: Constants.redLight,
            ),
            _getSearchBox(),
            Container(
              color: Colors.transparent,
              margin: EdgeInsets.only(
                  left: 32.0, right: 32.0, bottom: 32.0, top: 150.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _filteredList.clear();
                  });
                },
                child: Text(
                  'All Items',
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: 32.0, right: 32.0, bottom: 32.0, top: 170.0),
              child: _getListData(),
            ),
            _getCheckoutContainer(),
            _getCheckoutButton(),
          ],
        ),
      ),
    );
  }

  _getCheckoutButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 70.0,
        color: Constants.redLight,
        child: Row(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (context) {
                    return ActivityDashBoard();
                  }));
                },
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17.0,
                    ),
                  ),
                ),
              ),
              flex: 1,
            ),
            VerticalDivider(
              thickness: 2.0,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_dataList.isNotEmpty) {
                    _initUpload();
                  } else {
                    Others.showToast('No data', true);
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Text(
                    'Charge\n${_total.toStringAsFixed(3)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17.0,
                    ),
                  ),
                ),
              ),
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }

  _getListData() {
    return Container(
      height: 390.0,
      child: ListView.builder(
        itemCount:
        _filteredList.isEmpty ? _dataList.length : _filteredList.length,
        itemBuilder: (context, position) => _getRowDesign(position),
      ),
    );
  }

  _getRowDesign(int position) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 8.0),
      height: 105.0,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Divider(
            color: Colors.black54,
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(4.0),
                  margin: EdgeInsets.only(right: 4.0, top: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54, width: 1.0),
                  ),
                  child: GestureDetector(
                    onLongPress: () {
                      _removeItem(position);
                    },
                    child: Image.network(
                      _filteredList.isEmpty
                          ? _dataList[position].image_url
                          : _filteredList[position].image_url,
                      height: 70.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  height: 75.0,
                  margin: EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _filteredList.isEmpty
                            ? _dataList[position].title
                            : _filteredList[position].title,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        'Quantity',
                        style: TextStyle(color: Colors.black54),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      _getQuantityCounter(position),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _removeItem(int position) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Message!'),
            content: Text(
                'Are you sure you want to remove this item from checklist'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    String documentID = _filteredList.isNotEmpty
                        ? _documentList[
                    _dataList.indexOf(_filteredList[position])]
                        .documentID
                        : _documentList[position].documentID;
                    print(documentID);
                    Firestore.instance
                        .collection('checklist')
                        .document(documentID)
                        .delete();

                    if (_filteredList.isNotEmpty) {
                      _documentList
                          .removeAt(_dataList.indexOf(_filteredList[position]));
                      _dataList
                          .removeAt(_dataList.indexOf(_filteredList[position]));
                    } else {
                      _dataList.removeAt(position);
                      _documentList.removeAt(position);
                    }
                    _filteredList.clear();
                    _count = _dataList.length;
                    _calculateSubTotal();
                  });
                },
                child: Text('Remove'),
              ),
            ],
          );
        });
  }

  _getQuantityCounter(int position) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            _negate(position);
          },
          child: Container(
            height: 24.0,
            width: 24.0,
            margin: EdgeInsets.only(right: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54, width: 1.0),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Center(
              child: Icon(
                Icons.remove,
                size: 16.0,
              ),
            ),
          ),
        ),
        Text(_filteredList.isEmpty
            ? _dataList[position].quantity.toString()
            : _filteredList[position].quantity.toString()),
        GestureDetector(
          onTap: () {
            _add(position);
          },
          child: Container(
            height: 24.0,
            width: 24.0,
            margin: EdgeInsets.only(left: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54, width: 1.0),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Center(
              child: Icon(
                Icons.add,
                size: 16.0,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 24.0),
          child: Text(
            'Price: \$${_filteredList.isEmpty ? _dataList[position].selling_price.toString() : _filteredList[position].selling_price.toString()}',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }

  _negate(int position) {
    if (_filteredList.isEmpty) {
      if (_dataList[position].quantity > 1) {
        setState(() {
          _dataList[position].quantity--;
          _calculateSubTotal();
        });
      }
    } else {
      if (_filteredList[position].quantity > 1) {
        print(_filteredList[position].quantity.toString());
        setState(() {
          //_filteredList[position].quantity--;
          int index = _dataList.indexOf(_filteredList[position]);
          _dataList[index].quantity--;
          _calculateSubTotal();
        });
      }
    }
  }

  _add(int position) {
    setState(() {
      var quantity = _filteredList.isEmpty
          ? _dataList[position].quantity
          : _filteredList[position].quantity;
      var maxLimit = _filteredList.isEmpty
          ? _dataList[position].maxLimit
          : _filteredList[position].maxLimit;
      if (++quantity <= maxLimit) {
        if (_filteredList.isEmpty) {
          _dataList[position].quantity++;
        } else {
          //    _filteredList[position].quantity++;
          int index = _dataList.indexOf(_filteredList[position]);
          _dataList[index].quantity++;
        }
        _calculateSubTotal();
      }
    });
  }

  _getCheckoutContainer() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.transparent,
        height: 180.0,
        child: ListView(
          children: <Widget>[
            Divider(
              color: Colors.black54,
            ),
            SizedBox(
              height: 8.0,
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
                      '\$${_subTotal.toStringAsFixed(3)}',
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
                      '\$${_tax.toStringAsFixed(3)}',
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
                      '\$${_total.toStringAsFixed(3)}',
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
      ),
    );
  }

  _initUpload() {
    setState(() {
      _isLoading = true;
    });
    int receiptNo = 0;
    Firestore.instance
        .collection('receipts')
        .getDocuments()
        .then((querySnapshot) {
      receiptNo += querySnapshot.documents.length;
      Map map = HashMap<String, Object>();
      map['date'] = Timestamp.now();
      map['receipt_no'] = receiptNo;
      map['revenue'] = _revenue;
      map['profit'] = _profit;
      var key = Firestore.instance.collection('receipts').document().documentID;
      Firestore.instance
          .collection('receipts')
          .document(key)
          .setData(map)
          .then((snapshot) {
        _saveData(key);
      }).catchError((error) {
        setState(() {
          _isLoading = false;
          Others.showToast('Error adding receipt no', true);
        });
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
        Others.showToast('Error fetching receipt no', true);
      });
    });
  }

  _saveData(String documentKey) {
    // this function saves data to checklist collection
    if (_count > 0) {
      var map = Map<String, Object>();
      map['title'] = _dataList[_count - 1].title;
      map['quantity'] = _dataList[_count - 1].quantity;
      map['image_url'] = _dataList[_count - 1].image_url;
      map['selling_price'] = _dataList[_count - 1].selling_price;
      map['buying_price'] = _dataList[_count - 1].buying_price;
      Firestore.instance
          .collection('receipts')
          .document(documentKey)
          .collection('items')
          .document()
          .setData(map)
          .then((response) async {
        var quantity =
            _dataList[_count - 1].maxLimit - _dataList[_count - 1].quantity;
        var quantityMap = HashMap<String, Object>();
        quantityMap['quantity'] = quantity;
        await Firestore.instance
            .collection('products')
            .document(_dataList[_count - 1].product_id)
            .updateData(quantityMap);
        _count--;
        _saveData(documentKey);
      }).catchError((error) {
        print(error.toString());
        setState(() {
          _isLoading = false;
          Others.showToast('There was an error', true);
        });
      });
    } else {
      _documentList.forEach((snapshot) {
        Firestore.instance
            .collection('checklist')
            .document(snapshot.documentID)
            .delete();
      });
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => ActivityDashBoard()));
    }
  }

  _getData() {
    // this function fetches the checklist data
    Firestore.instance
        .collection('checklist')
        .getDocuments()
        .then((querySnapshot) {
      if (querySnapshot.documents.length > 0) {
        _count = querySnapshot.documents.length;
        querySnapshot.documents.forEach((documentSnapshot) {
          CheckListModel model = CheckListModel();
          model.title = documentSnapshot['title'];
          model.timestamp = documentSnapshot['timestamp'];
          model.tag = documentSnapshot['tag'];
          model.special_note = documentSnapshot['special_note'];
          model.selling_price = documentSnapshot['selling_price'];
          model.quantity = 1;
          model.maxLimit = documentSnapshot['quantity'];
          model.qr_code_data = documentSnapshot['qr_code_data'];
          model.image_url = documentSnapshot['image_url'];
          model.category = documentSnapshot['category'];
          model.buying_price = documentSnapshot['buying_price'];
          model.product_id = documentSnapshot['product_id'];
          _dataList.add(model);
          _documentList.add(documentSnapshot);
        });
        print(_dataList.length.toString());
        _calculateSubTotal();
      } else {
        Others.showToast('No product found', true);
      }
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      print(error);
      setState(() {
        _isLoading = false;
        Others.showToast('No product found', true);
      });
    });
  }

  _calculateSubTotal() {
    // this function calculates the subtotal
    _subTotal = 0;
    for (var i in _dataList) {
      _subTotal += (i.selling_price * i.quantity);
    }
    _calculateProfit();
    _calculateTax();
    setState(() {
      _total = _subTotal + _tax;
    });
  }

  _calculateProfit() {
    // this function calculates the profit
    _dataList.forEach((obj) {
      _profit += ((obj.selling_price - obj.buying_price) * obj.quantity);
      _revenue += (obj.selling_price * obj.quantity);
    });
  }

  _calculateTax() {
    // this function calculates the total tax
    var percentage = _subTotal > 163706.25 ? 40 : 20;
    _tax = ((percentage * _subTotal) / 100);
  }

  _showSearchDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter title to search'),
            content: Container(
              height: 150.0,
              width: 100.0,
              child: ListView(
                children: <Widget>[
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(labelText: 'search product'),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  RaisedButton(
                    child: Text(
                      'Search',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Constants.redLight,
                    onPressed: () {
                      var text = _searchController.text.toString().trim();
                      if (text.isNotEmpty) {
                        _filterData(text);
                        _searchController.text = '';
                        Navigator.of(context).pop();
                      } else {
                        Others.showToast('Enter a value to search', false);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _filterData(String data) {
    // filters data on the bases of either qr code or the search term
    _filteredList.clear();
    setState(() {
      _dataList.forEach((obj) {
        String title = obj.title.toString().toLowerCase();
        String qrCode = obj.qr_code_data.toString().toLowerCase();
        if (title.contains(data.toLowerCase()) ||
            title == data.toLowerCase() ||
            qrCode == data.toLowerCase()) {
          _filteredList.add(obj);
        }
      });
    });
  }
}
