import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ims_xpress/contracts/ActivityAddProductContracts.dart';
import 'package:ims_xpress/models/ActivityAddProuctModel.dart';

class ActivityAddProductPresenter implements IPresenter {
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

  ActivityAddProductPresenter(this._view);

  @override
  void initValidation(String title, String quantity, String buyingPrice,
      String sellingPrice, String specialNote, String tag, String qrCode,
      String category,
      File image ) {
    // initiates data validation
    this._title = title;
    this._quantity = quantity;
    this._buyingPrice = buyingPrice;
    this._sellingPrice = sellingPrice;
    this._specialNote = specialNote;
    this._tag = tag;
    this._qrCode = qrCode;
    this._category = category;
    this._image = image;
    _model = ActivityAddProductModel(_title, _quantity, _buyingPrice,
        _sellingPrice,
        _specialNote,
        _tag,
        _qrCode,
        _image );
    _view.onValidationResult(_model.validate());
  }

  @override
  void saveImage ( ) async {
    // this function saves image to firebase storage
    Firestore.instance.collection ( 'products' )
        .where ( 'qr_code_data', isEqualTo: _qrCode ).getDocuments ( )
        .then ( ( querySnapshot ) {
      if ( querySnapshot.documents.length > 0 ) {
        _view.onSaveImageResult ( false, 'Product already exists' );
      } else {
        _documentKey = Firestore.instance
            .collection ( 'products' )
            .document ( )
            .documentID
            .toString ( );
        StorageReference ref = FirebaseStorage.instance.ref ( ).child (
            'products/$_documentKey.jpg' ); // storage reference of the file that is being uploaded
        StorageUploadTask uploadTask = ref.putFile (
            _image ); // initiates upload
        uploadTask.onComplete.then ( (
            result ) { // onComplete is called when file uploads successfully
          result.ref.getDownloadURL ( ).then ( (
              url ) { // gets download url of the file
            _imageUrl = url;
            print ( url );
            _view.onSaveImageResult ( true, null );
          } ).catchError ( ( error ) { // called when there is an error
            print ( error.message );
            _view.onSaveImageResult ( false, 'Download link error' );
          } );
        } ).catchError ( ( error ) { // called when there is an error
          print ( error.message );
          _view.onSaveImageResult ( false, 'Image upload error' );
        } );
      }
    } ).catchError ( ( error ) {
      print(error.message);
      _view.onSaveImageResult ( false, 'There was an error' );
    } );
  }

  @override
  void storeDataToFirebase ( ) {
    // this function stores data to firebase firestore
    DocumentReference ref = Firestore.instance.collection ( 'products' )
        .document (
        _documentKey ); // reference to the document that will store the data
    Map map = Map<String, Object> ( );
    map['title'] = _title;
    map['quantity'] = int.parse ( _quantity );
    map['buying_price'] = double.parse ( _buyingPrice );
    map['selling_price'] = double.parse ( _sellingPrice );
    map['special_note'] = _specialNote;
    map['tag'] = _tag;
    map['category'] = _category;
    map['qr_code_data'] = _qrCode;
    map['image_url'] = _imageUrl;
    map['timestamp'] = Timestamp.now ( );
    ref.setData ( map ) // saves data to firestore
        .then ( ( snapshot ) { // called when data upload is successfull
      _view.onStoreDataToFirebaseResult ( true, null );
    } )
        .catchError ( ( error ) { // called when there is an error
      print(error.message);
      _view.onStoreDataToFirebaseResult ( false, 'Firestore error' );
    } );
  }
}
