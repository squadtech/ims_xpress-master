abstract class IView {
  void onValidationResult(bool success);

  void onAddCategoryToFirebaseResult(bool success, String exception);
}

abstract class IPresenter {
  void initValidation(String category);

  void addCategoryToFirebase();
}

abstract class IModel {
  bool validate();
}


/*
* Contract classes hold the methods that are to be implemented by models, presenters and views*/