import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IView {
  onFetchDataResult(bool success, List<DocumentSnapshot> list);
}

abstract class IPresenter {
  fetchData();
}
