import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ims_xpress/views/ActivityLowStock.dart';
import 'package:ims_xpress/views/ActivityProductDetails.dart';

class TextFields {
  // this entire class creates the simple text fields
  static Widget getTextField(
      {TextEditingController controller,
        String title,
        String hint,
        bool isDecimel} ) {
    return Container(
      margin: EdgeInsets.only(left: 32.0, right: 32.0, bottom: 0.0),
      height: 80.0,
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 15.0),
          ),
          TextField(
            keyboardType: isDecimel ? TextInputType.number : TextInputType.text,
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
            ),
          ),
        ],
      ),
    );
  }

  static Widget getTitleTextField(
      {TextEditingController controller, String hint}) {
    return Container(
      margin: EdgeInsets.only(left: 32.0, right: 32.0, bottom: 0.0),
      height: 80.0,
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: 22.0,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: hint,
        ),
      ),
    );
  }


  static Widget getText ( String val, String title ) {
    return Container (
      margin: EdgeInsets.only ( left: 32.0, right: 32.0),
      height: 40.0,
      child: ListView (
        physics: NeverScrollableScrollPhysics ( ),
        children: <Widget>[
          Text (
            title,
            style: TextStyle ( fontSize: 15.0, color: Colors.black54 ),
          ),
          Text ( val, style: TextStyle (
              fontWeight: FontWeight.bold,
              color: Colors.black87
          ), ),
        ],
      ),
    );
  }

  static Widget getTitleText ( String val ) {
    return Container (
      margin: EdgeInsets.only ( left: 32.0, right: 32.0, top: 8.0 ),
      height: 30.0,
      child: Text ( val,
        style: TextStyle (
          fontSize: 22.0,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static getLowStockRowDesign ( BuildContext context,
      DocumentSnapshot snapshot, ActivityLowStock obj ) {
    return GestureDetector (
      onTap: (){
        Navigator.pushReplacement ( context, MaterialPageRoute (
            builder: ( context ) =>
                ActivityProductDetails ( snapshot, obj ) ) );
      },
      child: Container (
        color: Colors.transparent,
        height: 75.0,
        margin: EdgeInsets.only ( left: 32.0, right: 32.0 ),
        child: Center (
          child: Column (
            children: <Widget>[
              SizedBox (
                height: 13.0,
              ),
              Row (
                children: <Widget>[
                  Expanded (
                    flex: 8,
                    child: Column (
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text ( snapshot['title'],
                          style: TextStyle (
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            fontSize: 18.0,
                          ), ),
                        Text ( '${snapshot['quantity']} items remaining',
                          style: TextStyle (
                              color: Colors.black54
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded (
                    flex: 2,
                    child: Icon ( Icons.chevron_right ),
                  ),
                ],
              ),
              SizedBox (
                height: 8.0,
              ),
              Divider (
                thickness: 1.0,
              )
            ],
          ),
        ),
      ),
    );
  }

}
