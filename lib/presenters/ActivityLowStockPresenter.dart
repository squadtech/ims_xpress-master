import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ims_xpress/contracts/ActivityLowStockContracts.dart';
import 'package:ims_xpress/utils/Others.dart';

class ActivityLowStockPresenter implements IPresenter {
  IViews _view;
  List<DocumentSnapshot> _list = List();

  ActivityLowStockPresenter(this._view);

  @override
  void fetchData ( int threshold ) {
    // this function fetches products having quantity less than or equal to 50
    Firestore.instance
        .collection('products')
        .where ( 'quantity', isLessThanOrEqualTo: threshold )
        .getDocuments()
        .then((querysnapshot) {
      if (querysnapshot.documents.length > 0) {
        querysnapshot.documents.forEach((documentsnapshot) {
          _list.add(documentsnapshot);
        });
        _view.onFetchDataResult(true, _list);
      } else {
        Others.showToast('No item found', true);
        _view.onFetchDataResult(false, null);
      }
    }).catchError((error) {
      Others.showToast(error.message, true);
      _view.onFetchDataResult(false, null);
    });
  }
}
