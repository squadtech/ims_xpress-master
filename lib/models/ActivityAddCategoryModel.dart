import 'package:ims_xpress/contracts/ActivityAddCategoryContracts.dart';

class ActivityAddCategoryModel implements IModel {
  String _category;

  ActivityAddCategoryModel(this._category);

  @override
  bool validate() {
    return _category.isNotEmpty;
  }
}
//Models work with data validation and implement the respective IModel contract from contracts package