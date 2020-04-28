import 'package:flutter/material.dart';
import 'package:ims_xpress/const/Constants.dart';
import 'package:ims_xpress/contracts/ActivityAddCategoryContracts.dart';
import 'package:ims_xpress/presenters/ActivityAddCategoryPresenter.dart';
import 'package:ims_xpress/utils/Others.dart';
import 'package:ims_xpress/utils/TextFields.dart';
import 'package:ims_xpress/views/ActivityCategories.dart';

class ActivityAddCategory extends StatefulWidget {
  @override
  _ActivityAddCategoryState createState() => _ActivityAddCategoryState();
}

class _ActivityAddCategoryState extends State<ActivityAddCategory>
    implements IView {
  var _categoryController = TextEditingController();
  IPresenter _presenter;
  bool _isAdding = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text('Add Category'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ActivityCategories()));
                },
              ),
            ),
            body: Stack(
              children: <Widget>[
                Center(
                  child: Container(
                    height: 350.0,
                    child: Card(
                      margin: EdgeInsets.all(32.0),
                      elevation: 3.0,
                      child: ListView(
                        children: <Widget>[
                          SizedBox(
                            height: 32.0,
                          ),
                          TextFields.getTextField(
                              title: 'Inventory Name',
                              isDecimel: false,
                              hint: 'inventory name',
                              controller: _categoryController),
                          Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: RaisedButton(
                                    onPressed: _pressListener,
                                    child: Text(
                                      'Add Inventory',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    color: Constants.redLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _isAdding
                    ? Container(
                        color: Colors.black12,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Container()
              ],
            )),
        onWillPop: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ActivityCategories()));
        });
  }

  _pressListener() {
    _presenter = ActivityAddCategoryPresenter(this);
    String category = _categoryController.text.toString().trim();
    _presenter.initValidation(category);
  }

  @override
  void onValidationResult(bool success) {
    // handles validation results
    if (success) {
      _presenter.addCategoryToFirebase();
    } else {
      Others.showToast('Enter inventory name first', true);
    }
    setState(() {
      _isAdding = success;
    });
  }

  @override
  void onAddCategoryToFirebaseResult(bool success, String exception) {
    // handles add data to firebase result
    if (success) {
      Others.showToast('ADDED', false);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => ActivityCategories()));
    } else {
      Others.showToast(exception, true);
    }
    setState(() {
      _isAdding = false;
    });
  }
}
