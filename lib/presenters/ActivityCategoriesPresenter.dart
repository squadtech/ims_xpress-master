import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ims_xpress/contracts/ActivityCategoriesContracts.dart';

class ActivityCategoriesPresenter implements IPresenter {
  IView _view;
  List<DocumentSnapshot> _list = List();

  ActivityCategoriesPresenter(this._view);

  @override
  void fetchCategoriesData ( ) {
    // this function fetches categories from firestore
    Firestore.instance.collection ( 'categories' ).getDocuments ( ).then ( (
        snapshot ) { // called when process is a success
      snapshot.documents.forEach((documentSnapshot) {
        _list.add(documentSnapshot);
      });
      _view.onFetchCategoriesDataResult(true, _list, null);
    } ).catchError ( ( error ) { // called when process failesA
      _view.onFetchCategoriesDataResult(false, null, error.message);
    });
  }
}
