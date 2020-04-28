import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ims_xpress/const/Constants.dart';
import 'package:ims_xpress/contracts/ActivityCategoryProductsContracts.dart';
import 'package:ims_xpress/presenters/ActivityCategoryProductsPresenter.dart';
import 'package:ims_xpress/utils/Others.dart';
import 'package:ims_xpress/utils/QrScanner.dart';
import 'package:ims_xpress/views/ActivityAddProduct.dart';
import 'package:ims_xpress/views/ActivityCategories.dart';
import 'package:ims_xpress/views/ActivityEditProduct.dart';
import 'package:ims_xpress/views/ActivityProductDetails.dart';

import 'ActivityDashBoard.dart';

class ActivityCategoryProducts extends StatefulWidget {
  String _category;

  ActivityCategoryProducts(this._category);

  @override
  _ActivityCategoryProductsState createState() =>
      _ActivityCategoryProductsState(_category);
}

class _ActivityCategoryProductsState extends State<ActivityCategoryProducts>
    implements IView {
  TextEditingController _searchController = TextEditingController();
  String _category;
  List<DocumentSnapshot> _dataList;
  List<DocumentSnapshot> _filteredList;
  IPresenter _presenter;
  bool _isOperationRunning = true;
  int _deletedIndex;

  _ActivityCategoryProductsState(this._category);

  @override
  void initState() {
    _dataList = List();
    _filteredList = List();
    _presenter = ActivityCategoryProductsPresenter(this);
    _presenter.fetchData(_category);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ActivityCategories()));
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Inventory Items'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityCategories(),
                ),
              );
            },
          ),
        ),
        body: _isOperationRunning ? Others.loadingContainer() : _body(),
      ),
    );
  }

  Widget _body() {
    return Stack(
      children: <Widget>[
        Container(
          height: 130.0,
          color: Constants.redLight,
        ),
        _getSearchBox(),
        _isOperationRunning
            ? Others.loadingContainer()
            : Padding(
                padding: EdgeInsets.only(top: 190.0, left: 16.0),
                child: Column(
                  children: <Widget>[
                    Align(
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
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      alignment: Alignment.topLeft,
                    ),
                    Expanded(
                      flex: 1,
                      child: _getList(),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _getList() {
    return Container(
      margin: EdgeInsets.only(top: 8.0),
      color: Colors.transparent,
      child: ListView.builder(
        itemCount:
            _filteredList.isEmpty ? _dataList.length : _filteredList.length,
        itemBuilder: (context, position) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => ActivityProductDetails(
                      _filteredList.isEmpty
                          ? _dataList[position]
                          : _filteredList[position],
                      this)));
            },
            onLongPress: () {
              _showOptionDialog(position);
            },
            child: Container(
              color: Colors.transparent,
              height: 80.0,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 24.0,
                        backgroundImage: NetworkImage(
                          _filteredList.isEmpty
                              ? _dataList[position]['image_url']
                              : _filteredList[position]['image_url'],
                        ),
                      ),
                      SizedBox(
                        width: 24.0,
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _filteredList.isEmpty
                                  ? _dataList[position]['title']
                                  : _filteredList[position]['title'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 19.0,
                              ),
                            ),
                            Text(
                              _filteredList.isEmpty
                                  ? _dataList[position]['quantity'].toString()
                                  : _filteredList[position]['quantity']
                                      .toString(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${_filteredList.isEmpty ? _dataList[position]['selling_price'] : _filteredList[position]['selling_price'].toString()}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19.0,
                              color: Colors.black54),
                        ),
                      )
                    ],
                  ),
                  Divider(
                    thickness: 1.0,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _getSearchBox() {
    return Container(
      height: 120.0,
      margin: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Card(
        elevation: 3.0,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () async {
                  var text = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return QrScanner();
                      },
                    ),
                  );
                  _filterData(text);
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
                    return ActivityAddProduct(_category);
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

  _filterData(String data) {
    // filters data on the bases of either qr code or the search term
    _filteredList.clear();
    setState(() {
      _dataList.forEach((documentSnapshot) {
        String title = documentSnapshot['title'].toString().toLowerCase();
        String qrCode =
            documentSnapshot['qr_code_data'].toString().toLowerCase();
        if (title.contains(data.toLowerCase()) ||
            title == data.toLowerCase() ||
            qrCode == data.toLowerCase()) {
          _filteredList.add(documentSnapshot);
        }
      });
    });
  }

  @override
  onFetchDataResult(bool success, List<DocumentSnapshot> list) {
    // handles fetch data result
    if (success) {
      _dataList = list;
      print(_dataList.length.toString());
    } else {
      Others.showToast('No product found', true);
    }
    setState(() {
      _isOperationRunning = false;
    });
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

  _showOptionDialog(int position) {
    // shows options dialog for deletion or edition of the product
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Options'),
            content: Text('What do you want to do with this item'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (context) {
                    return ActivityEditProduct(_filteredList.isEmpty
                        ? _dataList[position]
                        : _filteredList[position]);
                  }));
                },
                child: Text('Edit'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showConfirmationDialog(position);
                },
                child: Text('Delete'),
              ),
            ],
          );
        });
  }

  _showConfirmationDialog(int position) {
    // this method creates the confirmation alert dialog
    _deletedIndex = position;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Warning!'),
            content: Text('Are you sure you want to delete this product?'),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('Delete'),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _isOperationRunning = true;
                  });
                  _presenter.deleteImage(_filteredList.isEmpty
                      ? _dataList[position].documentID
                      : _filteredList[position].documentID);
                },
              ),
            ],
          );
        });
  }

  @override
  onDeleteImageResult(bool success) {
    // this function handles the delete image result
    if (success) {
      _presenter.deleteDocument();
    } else {
      Others.showToast('Error deleting product', true);
      setState(() {
        _isOperationRunning = false;
      });
    }
  }

  @override
  onDeleteDocumentResult(bool success) {
    // this function handles the delete document reuslt
    if (success) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ActivityCategories()));
      Others.showToast('Product deleted', false);
    } else {
      Others.showToast('There was an error deleting this product', true);
    }
  }
}
