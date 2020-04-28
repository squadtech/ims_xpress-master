import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ims_xpress/contracts/ActivitySalesHistoryContracts.dart';

class ActivitySalesHistoryPresenter implements IPresenter {
  IView _view;
  List<DocumentSnapshot> _list = List();

  ActivitySalesHistoryPresenter(this._view);

  @override
  fetchData ( ) {
    // this function fetches receipt data in ascending order
    Firestore.instance
        .collection('receipts')
        .orderBy ( 'receipt_no', descending: false )
        .getDocuments()
        .then((querySnapshot) {
      if (querySnapshot.documents.length > 0) {
        querySnapshot.documents.forEach((documentSnapshot) {
          _list.add(documentSnapshot);
        });
        _view.onFetchDataResult(true, _list);
      } else {
        _view.onFetchDataResult(false, null);
      }
    }).catchError((error) {
      _view.onFetchDataResult(false, null);
    });
  }
}
