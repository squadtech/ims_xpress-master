import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:ims_xpress/const/Constants.dart';
import 'package:ims_xpress/contracts/ActivityCategoriesContracts.dart';
import 'package:ims_xpress/presenters/ActivityCategoriesPresenter.dart';
import 'package:ims_xpress/utils/Others.dart';
import 'package:ims_xpress/views/ActivityAddCategory.dart';
import 'package:ims_xpress/views/ActivityCategoryProducts.dart';
import 'package:ims_xpress/views/ActivityDashBoard.dart';

class ActivityCategories extends StatefulWidget {
  @override
  _ActivityCategoriesState createState() => _ActivityCategoriesState();
}

class _ActivityCategoriesState extends State<ActivityCategories>
    implements IView {
  List<DocumentSnapshot> _dataList;
  List<DocumentSnapshot> _filteredList;
  IPresenter _presenter;
  bool _isFetchingData = true;

  @override
  void initState ( ) {
    _presenter = ActivityCategoriesPresenter ( this );
    _presenter.fetchCategoriesData ( );
    _filteredList = List ( );
    super.initState ( );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Inventory'),
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
        body: _body ( ),
        floatingActionButton: FloatingActionButton (
          backgroundColor: Constants.redLight,
          onPressed: ( ) {
            Navigator.pushReplacement ( context, MaterialPageRoute (
              builder: ( context ) => ActivityAddCategory ( ),
            ),
            );
          }, child: Icon ( Icons.add ),
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

  Widget _body ( ) {
    return Stack (
      children: <Widget>[
        _getSearchBox ( ),
        _isFetchingData ? Others.loadingContainer ( ) : Padding (
          padding: EdgeInsets.only ( top: 75.0 ), child: _getList ( ), ),
      ],
    );
  }

  Widget _getSearchBox ( ) {
    return Container (
      height: 70.0,
      padding: EdgeInsets.only ( left: 28.0, right: 28.0, top: 16.0 ),
      child: TextField (
        onChanged: _filterData,
        decoration: InputDecoration (
          hintText: 'search category',
          border: OutlineInputBorder (
            borderRadius: BorderRadius.circular ( 8.0 ),
          ),
        ),
      ),
    );
  }

  _filterData ( String data ) { // this function procides the search functionality
    _filteredList.clear ( );
    setState ( ( ) {
      _dataList.forEach ( ( documentSnapshot ) {
        print ( documentSnapshot['category_name'] );
        String word = documentSnapshot['category_name']
            .toString ( )
            .toLowerCase ( );
        if ( word.contains (
            data.toLowerCase ( ) ) || word == data.toLowerCase ( ) ) {
          _filteredList.add ( documentSnapshot );
        }
      } );
    } );
  }

  Widget _getList ( ) {
    return ListView.builder (
      itemCount: _filteredList.isEmpty ? _dataList.length : _filteredList
          .length,
      itemBuilder: ( context, position ) {
        return GestureDetector (
          onTap: ( ) {
            Navigator.pushReplacement ( context, MaterialPageRoute (
                builder: ( context ) =>
                    ActivityCategoryProducts ( _filteredList.isEmpty
                        ? _dataList[position]['category_name']
                        : _filteredList[position]['category_name'] ) ) );
          },
          onLongPress: ( ) {
            _showDeleteConfirmationDialog ( position );
          },
          child: Container (
            color: Colors.transparent,
            padding: EdgeInsets.only ( left: 32.0, right: 32.0 ),
            height: 80.0,
            width: MediaQuery.of(context).size.width,
            child: Column (
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text (
                  _filteredList.isEmpty
                      ? _dataList[position]['category_name']
                      : _filteredList[position]['category_name'],
                  style: TextStyle (
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                    fontSize: 17.0,
                  ),
                ),
                SizedBox (
                  height: 8.0,
                ),
                Divider (
                  thickness: 0.8,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _showDeleteConfirmationDialog ( int position ) {
    showDialog ( context: context, builder: ( context ) {
      return AlertDialog (
        title: Text ( 'Warning!' ),
        content: Text (
            'This category will be permanently deleted, are you sure you want to proceed?' ),
        actions: <Widget>[
          FlatButton (
            onPressed: ( ) {
              Navigator.pop ( context );
            },
            child: Text ( 'Cancel' ),
          ),
          FlatButton (
            onPressed: ( ) {
              Navigator.pop ( context );
              _deleteCategory ( _filteredList.isEmpty
                  ? _dataList[position].documentID
                  : _filteredList[position].documentID, position,
                  _filteredList.isEmpty ? false : true );
            },
            child: Text ( 'Delete' ),
          ),
        ],
      );
    } );
  }

  _deleteCategory ( String key, int position, bool filteredList ) {
    // this function deletes the category
    // first, this function checks if there are any products related to this category
    // if there are products, it will throw an error message
    // else it will delete the category
    setState ( ( ) {
      _isFetchingData = true;
    } );
    Firestore.instance.collection ( 'products' ).where (
        'category', isEqualTo: filteredList
        ? _filteredList[position]['category_name']
        : _dataList[position]['category_name'] ).getDocuments ( )
        .then ( ( querySnapshot ) {
      if ( querySnapshot.documents.length > 0 ) {
        setState ( ( ) {
          _isFetchingData = false;
          Others.showToast (
              'This category is not empty, delete all item first in order to delete this category',
              true );
        } );
      } else {
        Firestore.instance.collection ( 'categories' ).document ( key )
            .delete ( )
            .then ( ( response ) {
          setState ( ( ) {
            if ( filteredList ) {
              _filteredList.removeAt ( position );
            } else {
              _dataList.removeAt ( position );
            }
            _isFetchingData = false;
            Others.showToast ( 'Category deleted', false );
          } );
        } )
            .catchError ( ( error ) {
          setState ( ( ) {
            _isFetchingData = false;
            Others.showToast ( 'There was an error deleting category', false );
          } );
        } );
      }
    } )
        .catchError ( ( error ) {
      setState ( ( ) {
        _isFetchingData = false;
        Others.showToast ( 'There was an error deleting this category', true );
      } );
    } );
  }

  @override
  void onFetchCategoriesDataResult ( bool success, List<DocumentSnapshot> list,
      String exception ) { // handles fetch data result

    if ( success ) {
      _dataList = list;
    }
    else {
      Others.showToast ( exception, true );
    }
    try {
      setState ( ( ) {
        _isFetchingData = false;
      } );
    } catch ( error ) {}
  }

}
