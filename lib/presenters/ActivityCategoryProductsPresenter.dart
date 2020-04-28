import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ims_xpress/contracts/ActivityCategoryProductsContracts.dart';

class ActivityCategoryProductsPresenter implements IPresenter {
  IView _view;
  String _documentKey;
  ActivityCategoryProductsPresenter(this._view);

  @override
  fetchData ( String category ) {
    // this function fetches producyts of a specific category from firestore
    List<DocumentSnapshot> list = List();
    Firestore.instance
        .collection('products')
        .where('category', isEqualTo: category)
        .getDocuments()
        .then ( ( querySnapshot ) { // called when process is successful
      if (querySnapshot.documents.length > 0) {
        querySnapshot.documents.forEach((documentSnapshot) {
          list.add(documentSnapshot);
        });
        _view.onFetchDataResult(true, list);
      } else {
        _view.onFetchDataResult(false, null);
      }
    } ).catchError ( ( error ) { // called when process is a failure
      _view.onFetchDataResult(false, null);
    });
  }

  @override
  deleteImage ( String documentKey ) {
    print ( 'lil' );
    this._documentKey = documentKey;
    FirebaseStorage.instance.ref ( ).child ( 'products/${_documentKey}.jpg' )
        .delete ( ).then ( ( response ) {
      print ( 'deleted' );
      _view.onDeleteImageResult ( true );
    } )
        .catchError ( ( error ) {
      _view.onDeleteImageResult ( false );
    } );
  }

  @override
  deleteDocument ( ) {
    print ( 'lol ' );
    Firestore.instance.collection ( 'products' ).document ( _documentKey )
        .delete ( )
        .then ( ( response ) {
      _view.onDeleteDocumentResult ( true );
    } )
        .catchError ( ( error ) {
      print ( 'called' );
      _view.onDeleteDocumentResult ( false );
    } );
  }
}
