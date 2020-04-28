import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ims_xpress/contracts/ActivityEditProductContracts.dart';
import 'package:ims_xpress/models/ActivityEditProductModel.dart';

class ActivityEditProductPresenter implements IPresenter {
  IView _view;
  IModel _model;
  String _title,
      _quantity,
      _buyingPrice,
      _sellingPrice,
      _specialNote,
      _tag,
      _qrCode,
      _category;
  File _image;
  String _imageUrl;
  String _documentKey;

  ActivityEditProductPresenter(this._view);

  @override
  void initValidation(
    String title,
    String quantity,
    String buyingPrice,
    String sellingPrice,
    String specialNote,
    String tag,
    String qrCode,
    String category,
    String imageUrl,
    String documentKey,
    File image,
      ) {
    // initiates validation
    this._title = title;
    this._quantity = quantity;
    this._buyingPrice = buyingPrice;
    this._sellingPrice = sellingPrice;
    this._specialNote = specialNote;
    this._tag = tag;
    this._qrCode = qrCode;
    this._category = category;
    this._imageUrl = imageUrl;
    this._documentKey = documentKey;
    this._image = image;
    _model = ActivityEditProductModel(_title, _quantity, _buyingPrice,
        _sellingPrice, _specialNote, _tag, _qrCode, _imageUrl, _image);
    _view.onValidationResult(_model.validate());
  }

  @override
  void saveImage ( ) async {
    // saves image to firebase storage
    StorageReference ref =
    FirebaseStorage.instance.ref ( ).child (
        'products/$_documentKey.jpg' ); // storage reference of the image
    StorageUploadTask uploadTask = ref.putFile(_image);
    uploadTask.onComplete.then((result) {
      result.ref.getDownloadURL().then((url) {
        _imageUrl = url;
        print(url);
        _view.onSaveImageResult(true, null);
      }).catchError((error) {
        print(error.message);
        _view.onSaveImageResult(false, 'Download link error');
      });
    }).catchError((error) {
      print(error.message);
      _view.onSaveImageResult(false, 'Image upload error');
    });
  }

  @override
  void storeDataToFirebase ( ) {
    // stores data tp firestore
    DocumentReference ref =
        Firestore.instance.collection('products').document(_documentKey);
    Map map = Map<String, Object>();
    map['title'] = _title;
    map['quantity'] = int.parse(_quantity);
    map['buying_price'] = double.parse(_buyingPrice);
    map['selling_price'] = double.parse(_sellingPrice);
    map['special_note'] = _specialNote;
    map['tag'] = _tag;
    map['category'] = _category;
    map['qr_code_data'] = _qrCode;
    map['image_url'] = _imageUrl;
    map['timestamp'] = Timestamp.now();
    ref.updateData(map).then((snapshot) {
      _view.onStoreDataToFirebaseResult(true, null);
    }).catchError((error) {
      print(error.message);
      _view.onStoreDataToFirebaseResult(false, 'Firestore error');
    });
  }
}
