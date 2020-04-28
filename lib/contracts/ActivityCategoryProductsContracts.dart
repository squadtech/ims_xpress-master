import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IView {
  onFetchDataResult(bool success, List<DocumentSnapshot> list);

  onDeleteImageResult ( bool success );

  onDeleteDocumentResult ( bool success );
}

abstract class IPresenter {
  fetchData(String category);

  deleteImage ( String documentKey );

  deleteDocument ( );
}
