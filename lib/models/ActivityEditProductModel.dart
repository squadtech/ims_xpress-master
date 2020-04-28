import 'dart:io';

import 'package:ims_xpress/contracts/ActivityEditProductContracts.dart';

class ActivityEditProductModel implements IModel {
  String _title,
      _quantity,
      _buyingPrice,
      _sellingPrice,
      _specialNote,
      _tag,
      _imageUrl,
      _qrCode;
  File _image;

  ActivityEditProductModel(
      this._title,
      this._quantity,
      this._buyingPrice,
      this._sellingPrice,
      this._specialNote,
      this._tag,
      this._qrCode,
      this._imageUrl,
      this._image);

  @override
  bool validate() =>
      _title.isNotEmpty &&
      _quantity.isNotEmpty &&
      _buyingPrice.isNotEmpty &&
      _sellingPrice.isNotEmpty &&
      _specialNote.isNotEmpty &&
      _tag.isNotEmpty &&
      _qrCode.isNotEmpty &&
      (_image != null || _imageUrl.isNotEmpty);
}
