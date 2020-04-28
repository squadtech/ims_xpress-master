import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ims_xpress/contracts/ActivityDashBoardContracts.dart';

class ActivityDashBoardPresenter implements IPresenter {
  IView _view;
  List<DocumentSnapshot> _productList;

  ActivityDashBoardPresenter(this._view);

  @override
  void fetchData ( List<DocumentSnapshot> categoryList ) {
    // this function fetches all products from firestore
    _productList = List ( );
    Firestore.instance
        .collection ( 'products' ).orderBy ( 'timestamp', descending: true)
        .getDocuments()
        .then ( ( querySnapshot ) { // called when task completes successfully
      if (querySnapshot.documents.length > 0) {
        querySnapshot.documents.forEach((documentSnapshot) {
          _productList.add ( documentSnapshot );
        });
        Firestore.instance.collection ( 'categories' ) // fetches categories
            .getDocuments ( ).then ( ( querySnapshot ) {
          if ( querySnapshot.documents.length > 0 ) {
            querySnapshot.documents.forEach ( ( documentSnapshot ) {
              categoryList.add ( documentSnapshot );
            } );
            _view.onFetchDataResult ( true, _productList );
          } else {
            _view.onFetchDataResult ( true, _productList );
          }
        } ).catchError ( ( error ) {
          _view.onFetchDataResult ( true, _productList );
        } );
      } else {
        _view.onFetchDataResult(false, null);
      }
    }).catchError((error) {
      _view.onFetchDataResult(false, null);
    });
  }
}

// catchError() is called whene there is an error while executing of a task
