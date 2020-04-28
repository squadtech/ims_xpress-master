import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ims_xpress/contracts/ActivitySalesHistoryContracts.dart';
import 'package:ims_xpress/presenters/ActivitySalesHistoryPresenter.dart';
import 'package:ims_xpress/utils/Others.dart';
import 'package:ims_xpress/views/ActivityDashBoard.dart';
import 'package:ims_xpress/views/ActivityReceipt.dart';

class ActivitySalesHistory extends StatefulWidget {
  @override
  _ActivitySalesHistoryState createState() => _ActivitySalesHistoryState();
}

class _ActivitySalesHistoryState extends State<ActivitySalesHistory>
    implements IView {
  List<DocumentSnapshot> _dataList;
  List<DocumentSnapshot> _filteredList;
  IPresenter _presenter;
  bool _isFetchingData = true;

  @override
  void initState() {
    _filteredList = List();
    _dataList = List();
    _presenter = ActivitySalesHistoryPresenter(this);
    _presenter.fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Sales History'),
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
        body: Stack(
          children: <Widget>[
            _body(),
          ],
        ),
      ),
      onWillPop: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityDashBoard(),
          ),
        );
      },
    );
  }

  Widget _body() {
    return Stack(
      children: <Widget>[
        _getSearchBox(),
        _isFetchingData
            ? Others.loadingContainer()
            : Padding(
                padding: EdgeInsets.only(top: 75.0),
                child: _getList(),
              ),
      ],
    );
  }

  Widget _getSearchBox() {
    return Container(
      height: 70.0,
      padding: EdgeInsets.only(left: 28.0, right: 28.0, top: 16.0),
      child: TextField(
        onChanged: _filterData,
        decoration: InputDecoration(
          hintText: 'search receipt number',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  _filterData ( String data ) {
    // this function provides the search functionality
    _filteredList.clear();
    setState(() {
      _dataList.forEach((documentSnapshot) {
        print(documentSnapshot['receipt_no']);
        String word = documentSnapshot['receipt_no'].toString().toLowerCase();
        if (word.contains(data.toLowerCase()) || word == data.toLowerCase()) {
          _filteredList.add(documentSnapshot);
        }
      });
    });
  }

  Widget _getList() {
    return ListView.builder(
      itemCount:
          _filteredList.isEmpty ? _dataList.length : _filteredList.length,
      itemBuilder: (context, position) {
        return GestureDetector(
          onTap: () {
            Navigator.of ( context ).pushReplacement (
                MaterialPageRoute ( builder: ( context ) =>
                    ActivityReceipt ( _filteredList.isEmpty
                        ? _dataList[position]
                        : _filteredList[position] ) ) );
          },
          child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.only(left: 32.0, right: 32.0),
            height: 80.0,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  _filteredList.isEmpty
                      ? 'Receipt #${_dataList[position]['receipt_no']}'
                      : 'Receipt #${_filteredList[position]['receipt_no']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                    fontSize: 17.0,
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Divider(
                  thickness: 0.8,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  onFetchDataResult ( bool success, List<DocumentSnapshot> list ) {
    // this function handles the fetch data result
    try {
      setState(() {
        _isFetchingData = false;
      });
    } catch (error) {}
    if (success) {
      _dataList = list;
    } else {
      Others.showToast('No receipt found', true);
    }
  }
}
