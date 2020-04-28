import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ims_xpress/contracts/ActivityAddCategoryContracts.dart';
import 'package:ims_xpress/models/ActivityAddCategoryModel.dart';

class ActivityAddCategoryPresenter implements IPresenter {
  IView _view;
  IModel _model;
  String _category;

  ActivityAddCategoryPresenter(this._view);

  @override
  void initValidation ( String category ) {
    // initiates data validation
    this._category = category;
    _model = ActivityAddCategoryModel(category);
    _view.onValidationResult(_model.validate());
  }

  @override
  void addCategoryToFirebase ( ) {
    // this function adds a new category to firebase
    Map map = Map<String, String>();
    map['category_name'] = _category;
    Firestore.instance.collection ( 'categories' ).add ( map ).then ( (
        result ) { // then is called after the task is done successfully
      _view.onAddCategoryToFirebaseResult(true, null);
    } ).catchError ( ( error ) { // called when there is an error
      _view.onAddCategoryToFirebaseResult(false, error.message);
    });
  }
}
