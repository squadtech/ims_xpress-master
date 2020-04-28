import 'dart:io';

abstract class IModel {
  bool validate();
}

abstract class IPresenter {
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
      File image);

  void saveImage();

  void storeDataToFirebase();
}

abstract class IView {
  void onValidationResult(bool valid);

  void onSaveImageResult(bool success, String exception);

  void onStoreDataToFirebaseResult(bool success, String exception);
}
