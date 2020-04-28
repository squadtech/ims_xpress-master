import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IViews {
  void onFetchDataResult(bool success, List<DocumentSnapshot> list);
}

abstract class IPresenter {
  void fetchData(int threshold);
}
