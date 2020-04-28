import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IView {
  void onFetchCategoriesDataResult ( bool success, List<DocumentSnapshot> list,
      String error );
}

abstract class IPresenter {
  void fetchCategoriesData ( );
}