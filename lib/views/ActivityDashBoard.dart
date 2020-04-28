import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ims_xpress/contracts/ActivityDashBoardContracts.dart';
import 'package:ims_xpress/models/GraphModel.dart';
import 'package:ims_xpress/presenters/ActivityDashBoardPresenter.dart';
import 'package:ims_xpress/utils/MainDrawer.dart';
import 'package:ims_xpress/utils/Others.dart';
import 'package:ims_xpress/utils/ProfitChart.dart';

import 'ActivityProductDetails.dart';

class ActivityDashBoard extends StatefulWidget {
  @override
  _ActivityDashBoardState createState() => _ActivityDashBoardState();
}

class _ActivityDashBoardState extends State<ActivityDashBoard>
    implements IView {
  List<DocumentSnapshot> _productsList;
  List<DocumentSnapshot> _recentList;
  List<DocumentSnapshot> _categoryList;
  List<DocumentSnapshot> _datedList;
  List<DocumentSnapshot> _receiptList;
  List<GraphModel> _profitList;
  List _yearList = [2022, 2021, 2020, 2019, 2018];
  int _selectedYear = 2020;
  IPresenter _presenter;
  bool _isFetchingData = true;

  @override
  void initState() {
    _profitList = List();
    _recentList = List();
    _productsList = List();
    _categoryList = List();
    _datedList = List();
    _receiptList = List();
    _presenter = ActivityDashBoardPresenter(this);
    _presenter.fetchData(_categoryList);
    _getReceipts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _getProfitList();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Dashboard'),
      ),
      body: Stack(
        children: <Widget>[
          _isFetchingData
              ? Others.loadingContainer()
              : Padding(
            padding: EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                _getGraphSection(),
                SizedBox(
                  height: 32.0,
                ),
                Text(
                  'INVENTORY DETAILS',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                SizedBox(
                  height: 16.0,
                ),
                _getInventory(),
                SizedBox(
                  height: 24.0,
                ),
                Text(
                  'RECENT ITEMS',
                  style: TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.bold),
                ),
                _getRecentItemList(),
              ],
            ),
          ),
        ],
      ),
      drawer: MainDrawer(),
    );
  }

  _getRecentItemList() {
    _recentList.clear();
    int count = 0;

    for (DocumentSnapshot snapshot in _productsList) {
      if (count <= 10) {
        _recentList.add(snapshot);
      }
      count++;
    }

    return Container(
      margin: EdgeInsets.only(top: 8.0, bottom: 16.0),
      height: 200.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recentList.length,
        itemBuilder: (context, position) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) =>
                      ActivityProductDetails(_recentList[position], ActivityDashBoard())));
            },
            child: Container(
              margin: EdgeInsets.only(left: 4.0),
              width: 160.0,
              height: 200.0,
              child: Card(
                elevation: 3.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Image.network(
                      _recentList[position]['image_url'],
                      height: 100.0,
                      width: 160.0,
                      fit: BoxFit.fill,
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        _recentList[position]['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '${_recentList[position]['quantity']} Qty',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _getInventory() {
    return Container(
      height: 268.0,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 130.0,
                  margin: EdgeInsets.only(right: 8.0),
                  child: Card(
                    elevation: 3.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: AssetImage('images/items.png'),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          _productsList.length.toString(),
                          style: TextStyle(
                              fontSize: 17.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Items',
                          style:
                          TextStyle(fontSize: 12.0, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                flex: 1,
              ),
              Expanded(
                child: Container(
                  height: 130.0,
                  margin: EdgeInsets.only(left: 8.0),
                  child: Card(
                    elevation: 3.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: AssetImage('images/categories.png'),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          _categoryList.length.toString(),
                          style: TextStyle(
                              fontSize: 17.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Categories',
                          style:
                          TextStyle(fontSize: 12.0, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                flex: 1,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 130.0,
                  margin: EdgeInsets.only(right: 8.0, top: 8.0),
                  child: Card(
                    elevation: 3.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: AssetImage('images/quantity.png'),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          Others.calculateItemQuantity(_productsList),
                          style: TextStyle(
                              fontSize: 17.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Quantity',
                          style:
                          TextStyle(fontSize: 12.0, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                flex: 1,
              ),
              Expanded(
                child: Container(
                  height: 130.0,
                  margin: EdgeInsets.only(left: 8.0, top: 8.0),
                  child: Card(
                    elevation: 3.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: AssetImage('images/net_worth.png'),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          '${Others.calculateNetWorth(_receiptList).toStringAsFixed(3)} M',
                          style: TextStyle(
                              fontSize: 17.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Net Worth',
                          style:
                          TextStyle(fontSize: 12.0, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                flex: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }

  _getGraphSection() {
    return Container(
      height: 330.0,
      child: Card(
        elevation: 5.0,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Net: \$${Others.calculateAnnualProfit(_receiptList, _selectedYear).toStringAsFixed(3)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17.0,
                          color: Colors.black54),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Text('Profit year:  '),
                        DropdownButton<int>(
                          underline: SizedBox(),
                          items: _yearList.map((year) {
                            return DropdownMenuItem<int>(
                              child: Text(year.toString()),
                              value: year,
                            );
                          }).toList(),
                          onChanged: (year) {
                            setState(() {
                              _selectedYear = year;
                              _profitList.clear();
                              _datedList.clear();
                              _getReceipts();
                            });
                          },
                          value: _selectedYear,
                        ),
                      ],
                    ),
                    flex: 1,
                  ),
                ],
              ),
            ),
            Container(
              height: 250.0,
              padding: EdgeInsets.all(8.0),
              child: ProfitChart(_profitList),
            )
          ],
        ),
      ),
    );
  }

  _getProfitList() {
    setState(() {
      _profitList.clear();
      _profitList = Others.getProfit(_datedList);
    });
  }

  @override
  void onFetchDataResult(bool success, List<DocumentSnapshot> list) {
    // handles the fetch data result
    setState(() {
      _isFetchingData = false;
    });
    if (success) {
      this._productsList = list;
    } else {
      Others.showToast('No data found', true);
    }
  }

  _getReceipts() {
    _receiptList.clear();
    Firestore.instance
        .collection('receipts')
        .getDocuments()
        .then((querySnapshot) {
      if (querySnapshot.documents.isNotEmpty) {
        _datedList.clear();
        querySnapshot.documents.forEach((documentSnapshot) {
          _receiptList.add(documentSnapshot);
        });
        _receiptList.forEach((documentSnapshot) {
          Timestamp timestamp = documentSnapshot['date'];
          int year = timestamp.toDate().year;
          if (year == _selectedYear) {
            _datedList.add(documentSnapshot);
          }
        });
        setState(() {});
      } else {
        Others.showToast('No sales found', false);
      }
    }).catchError((error) {
      Others.showToast(error.message, true);
    });
  }
}
