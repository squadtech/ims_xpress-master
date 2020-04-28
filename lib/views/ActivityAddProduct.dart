import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ims_xpress/const/Constants.dart';
import 'package:ims_xpress/contracts/ActivityAddProductContracts.dart';
import 'package:ims_xpress/presenters/ActivityAddProductPresenter.dart';
import 'package:ims_xpress/utils/Others.dart';
import 'package:ims_xpress/utils/QrScanner.dart';
import 'package:ims_xpress/utils/TextFields.dart';
import 'package:ims_xpress/views/ActivityCategories.dart';
import 'package:ims_xpress/views/ActivityCategoryProducts.dart';

class ActivityAddProduct extends StatefulWidget {
  String _category;

  ActivityAddProduct ( this._category );

  @override
  _ActivityAddProductState createState ( ) =>
      _ActivityAddProductState ( _category );
}

class _ActivityAddProductState extends State<ActivityAddProduct>
    implements IView {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _buyingPriceController = TextEditingController ( );
  TextEditingController _sellingPriceController = TextEditingController();
  TextEditingController _specialNoteController = TextEditingController();
  TextEditingController _tagController = TextEditingController();
  IPresenter _presenter;
  File _image = null;
  String _qrText = '';
  String _category = '';
  bool _isUploadingData = false;

  _ActivityAddProductState ( this._category );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: ( context ) => ActivityCategoryProducts ( _category ),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Product'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: ( context ) =>
                      ActivityCategoryProducts ( _category ),
                ),
              );
            },
          ),
        ),
        body: Stack (
          children: <Widget>[
            ListView (
              children: <Widget>[
                GestureDetector (
                  onTap: ( ) async {
                    _openSelectionDialog ( );
                  },
                  child: Container (
                    height: 200.0,
                    padding: EdgeInsets.all ( 45.0 ),
                    color: Colors.black12,
                    child: _image == null ? Image (
                      image: AssetImage ( 'images/gallery.png' ),
                      color: Colors.white,
                    ) : Image.file ( _image ),
                  ),
                ),
                SizedBox (
                  height: 8.0,
                ),
                TextFields.getTitleTextField (
                  controller: _titleController,
                  hint: 'product title',
                ),
                TextFields.getTextField (
                  controller: _quantityController,
                  title: 'Quantity',
                  hint: 'e.g 32',
                  isDecimel: true,
                ),
                Row (
                  children: <Widget>[
                    Expanded (
                      child: TextFields.getTextField (
                        controller: _buyingPriceController,
                        title: 'Buying Price',
                        hint: 'e.g \$300.00',
                        isDecimel: true,
                      ),
                    ),
                    Expanded (
                      child: TextFields.getTextField (
                        controller: _sellingPriceController,
                        title: 'Selling Price',
                        hint: 'e.g \$330.00',
                        isDecimel: true,
                      ),
                    ),
                  ],
                ),
                TextFields.getTextField (
                  controller: _specialNoteController,
                  title: 'Special Note',
                  hint: 'e.g product description here',
                  isDecimel: false,
                ),
                TextFields.getTextField (
                  controller: _tagController,
                  title: 'Tag',
                  hint: 'e.g expired',
                  isDecimel: false,
                ),
                GestureDetector (
                  onTap: ( ) async {
                    _qrText =
                    await Navigator.push ( context, MaterialPageRoute (
                        builder: ( context ) => QrScanner ( ) ) );
                  },
                  child: Others.getQrScannerLayout (
                      _qrText.isEmpty ? 'QR Code' : _qrText ),
                ),
                SizedBox (
                  height: 16.0,
                ),
                Row (
                  children: <Widget>[
                    Expanded (
                      child: Padding (
                        padding:
                        EdgeInsets.only (
                            left: 32.0, right: 32.0, bottom: 16.0 ),
                        child: RaisedButton (
                          child: Text (
                            'Add',
                            style: TextStyle (
                              color: Colors.white,
                            ),
                          ),
                          color: Constants.redLight,
                          shape: RoundedRectangleBorder (
                            borderRadius: BorderRadius.circular ( 4.0 ),
                          ),
                          onPressed: ( ) {
                            _initValidation ( );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
            _isUploadingData ? Container (
              color: Colors.black12,
              child: Center (
                child: CircularProgressIndicator ( ),
              ),
            ) : Container ( )
          ],
        ),
      ),
    );
  }

  _openSelectionDialog ( ) {
    showDialog (
      context: context,
      builder: ( context ) {
        return AlertDialog (
          content: Container (
            height: 150.0,
            child: Row (
              children: <Widget>[
                Expanded (
                  child: GestureDetector (
                    onTap: _openCamera,
                    child: Image ( image: AssetImage ( 'images/camera.png' ),
                      width: 70.0,
                      height: 70.0,
                    ),
                  ),
                ),
                Expanded (
                  child: GestureDetector (
                    onTap: _openGallery,
                    child: Image ( image: AssetImage ( 'images/gallery.png' ),
                      width: 70.0,
                      height: 70.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _openGallery ( ) async {
    Navigator.pop ( context );
    // this function opens gallery for image selection
    _image = await ImagePicker.pickImage ( source: ImageSource.gallery );
    setState ( ( ) {} );
  }

  _openCamera ( ) async {
    // this function opens camera for image capture
    Navigator.pop ( context );
    _image = await ImagePicker.pickImage ( source: ImageSource.camera );
    setState ( ( ) {} );
  }

  _initValidation ( ) {
    // this function invokes the validation
    _presenter = ActivityAddProductPresenter ( this );
    String title = _titleController.text.trim ( );
    String quantity = _quantityController.text.trim ( );
    String buyingPrice = _buyingPriceController.text.trim ( );
    String sellingPrice = _sellingPriceController.text.trim ( );
    String specialNote = _specialNoteController.text.trim ( );
    String tag = _tagController.text.trim ( );
    _presenter.initValidation (
        title,
        quantity,
        buyingPrice,
        sellingPrice,
        specialNote,
        tag,
        _qrText,
        _category,
        _image );
  }

  @override
  void onValidationResult ( bool valid ) {
    // handles validation result
    if ( valid ) {
      setState ( ( ) {
        _isUploadingData = true;
      } );
      _presenter.saveImage();
    } else {
      Others.showToast ( 'Invalid entries', true );
    }
  }

  @override
  void onSaveImageResult ( bool success, String exception ) {
    // handles image upload result
    if ( success ) {
      _presenter.storeDataToFirebase ( );
      setState ( ( ) {
        _isUploadingData = true;
      } );
    } else {
      Others.showToast ( exception, true );
      setState ( ( ) {
        _isUploadingData = false;
      } );
    }
  }

  @override
  void onStoreDataToFirebaseResult ( bool success, String exception ) {
    // handles save data to firestore result
    if(success) {
      Others.showToast ( 'Product Added', false );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ActivityCategories(),
        ),
      );
    } else {
      Others.showToast ( exception, true );
    }
    setState ( ( ) {
      _isUploadingData = false;
    } );
  }

}
