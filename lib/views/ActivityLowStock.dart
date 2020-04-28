import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ims_xpress/const/Constants.dart';
import 'package:ims_xpress/contracts/ActivityLowStockContracts.dart';
import 'package:ims_xpress/presenters/ActivityLowStockPresenter.dart';
import 'package:ims_xpress/utils/Others.dart';
import 'package:ims_xpress/utils/TextFields.dart';
import 'package:ims_xpress/views/ActivityDashBoard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityLowStock extends StatefulWidget {
  @override
  _ActivityLowStockState createState() => _ActivityLowStockState(this);
}

class _ActivityLowStockState extends State<ActivityLowStock> implements IViews {
  ActivityLowStock _obj;
  List<DocumentSnapshot> _list = List();
  IPresenter _presenter;
  bool _isFetchingData = true;
  TextEditingController _controller = TextEditingController ( );
  SharedPreferences _prefs;
  int _threshold;

  _ActivityLowStockState(this._obj);

  @override
  void initState ( ) {
    _beginFetch ( );
    super.initState();
  }

  _beginFetch ( ) async {
    _prefs = await SharedPreferences.getInstance ( );
    _threshold = _prefs.getInt ( 'threshold' ) ?? 50;
    _presenter = ActivityLowStockPresenter ( this );
    _presenter.fetchData ( _threshold );
    print ( _threshold.toString ( ) );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Low Stock'),
            centerTitle: true,
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ActivityDashBoard()));
                },
            ),
            actions: <Widget>[
              IconButton (
                icon: Icon ( Icons.settings ),
                onPressed: ( ) {
                  _showThresholdDialog ( );
                },
              ),
            ],
          ),
          body: _getBody(),
        ),
        onWillPop: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ActivityDashBoard()));
        });
  }

  _showThresholdDialog ( ) {
    showDialog (
      context: context,
      builder: ( context ) {
        return AlertDialog (
          title: Text ( 'Set low stock threshold' ),
          content: Container (
            height: 200.0,
            child: Column (
              children: <Widget>[
                TextField (
                  keyboardType: TextInputType.number,
                  controller: _controller,
                  decoration: InputDecoration (
                      hintText: 'threshold here'
                  ),
                ),
                Container (
                  margin: EdgeInsets.only ( top: 64.0 ),
                  child: Row (
                    children: <Widget>[
                      Expanded (
                        child: RaisedButton (
                          color: Constants.redLight,
                          child: Text ( 'Set Threshold',
                            style: TextStyle (
                                color: Colors.white
                            ),
                          ),
                          onPressed: ( ) {
                            _setThreshold ( );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _setThreshold ( ) async {
    if ( _controller.text
        .toString ( )
        .trim ( )
        .isNotEmpty ) {
      int val = int.parse ( _controller.text.toString ( ).trim ( ) );
      _prefs.setInt ( 'threshold', val );
      _threshold = val;
      Navigator.pop ( context );
      Others.showToast ( 'Threshold set successfully', false );
      _controller.text = '';
      setState ( ( ) {
        _isFetchingData = true;
        _list.clear ( );
        _presenter.fetchData ( _threshold );
      } );
    } else {
      Others.showToast ( 'Please enter a value', true );
    }
  }

  _getBody() {
    return Stack(
      children: <Widget>[
        _isFetchingData ? Others.loadingContainer() : _getList(),
      ],
    );
  }

  _getList() {
    return ListView.builder(
      padding: EdgeInsets.only(top: 32.0),
      itemCount: _list.length,
      itemBuilder: (context, position) =>
          TextFields.getLowStockRowDesign(context, _list[position], _obj),
    );
  }

  @override
  void onFetchDataResult ( bool success, List<DocumentSnapshot> list ) {
    // handles fetch data result
    if (success) {
      this._list = list;
    }
    try {
      setState(() {
        _isFetchingData = false;
      });
    } catch (error){}
  }
}
