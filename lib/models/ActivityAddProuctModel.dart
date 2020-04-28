import 'dart:io';

import 'package:ims_xpress/contracts/ActivityAddProductContracts.dart';

class ActivityAddProductModel implements IModel {
  String _title,
      _quantity,
      _buyingPrice,
      _sellingPrice,
      _specialNote,
      _tag,
      _qrCode;
  File _image;

  ActivityAddProductModel(this._title, this._quantity, this._buyingPrice,
      this._sellingPrice, this._specialNote, this._tag, this._qrCode,
      this._image );

  @override
  bool validate() =>
      _title.isNotEmpty &&
          _quantity.isNotEmpty &&
          _buyingPrice.isNotEmpty &&
          _sellingPrice.isNotEmpty &&
          _specialNote.isNotEmpty &&
          _tag.isNotEmpty &&
          _qrCode.isNotEmpty && _image != null;
}
