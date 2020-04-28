import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IView {
  void onFetchDataResult(bool success, List<DocumentSnapshot> list);
}

abstract class IPresenter {
  void fetchData(List<DocumentSnapshot> categoryList);
}