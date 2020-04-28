import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ims_xpress/models/GraphModel.dart';

class Others {
  static Widget getQrScannerLayout ( String qrValue ) {
    // this function returns the layout that when tapped on, opens qr scanner, this is called in the edit and add product screen
    return Container(
      height: 80.0,
      width: 80.0,
      margin: EdgeInsets.only(left: 32.90),
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          qrValue.isEmpty ? Text ( 'QR Code' ) : Text ( qrValue ),
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 8.0,
                ),
                Image(
                  image: AssetImage('images/scan.png'),
                  width: 35.0,
                  height: 35.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static showToast ( String message, bool isError ) {
    // this function shows toast
    Fluttertoast.showToast (
        msg: message,
        toastLength: isError ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 3,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  static loadingContainer ( ) {
    // this function shows the loading bar when loading process is undergoing
    return Container (
      child: Center (
        child: CircularProgressIndicator ( ),
      ),
    );
  }

  static List<GraphModel> getProfit ( List<DocumentSnapshot> list ) {
    // this function prepares list for the graph by extracting profit data
    List<GraphModel> profitList = List ( );
    List<int> mList = List ( );

    for ( var i = 1; i <= 12; i++ ) { // filter data according to months
      var month = false;
      for ( var j = 0; j < list.length; j++ ) {
        var obj = list[j];
        if ( obj['date']
            .toDate ( )
            .month == i ) {
          month = true;
        }
      }
      if ( month ) {
        mList.add ( i );
      }
    }

    for ( var i in mList ) { // calculates profit
      double profit = 0;
      var model = GraphModel ( );
      list.forEach ( ( documentSnapshot ) {
        if ( documentSnapshot['date']
            .toDate ( )
            .month == i ) {
          profit += documentSnapshot['profit'];
        }
      } );
      model.month = i;
      model.profit = profit;
      profitList.add ( model );
    }

    for ( var i = 0; i <
        profitList.length; i++ ) { // gives names according to month number
      var model = profitList[i];
      switch ( model.month ) {
        case 1 :
          {
            model.monthName = "Jan";
            break;
          }
        case 2 :
          {
            model.monthName = "Feb";
            break;
          }
        case 3 :
          {
            model.monthName = "Mar";
            break;
          }
        case 4 :
          {
            model.monthName = "Apr";
            break;
          }
        case 5 :
          {
            model.monthName = "May";
            break;
          }
        case 6 :
          {
            model.monthName = "Jun";
            break;
          }
        case 7 :
          {
            model.monthName = "Jul";
            break;
          }
        case 8 :
          {
            model.monthName = "Aug";
            break;
          }
        case 9 :
          {
            model.monthName = "Sep";
            break;
          }
        case 10 :
          {
            model.monthName = "Oct";
            break;
          }
        case 11 :
          {
            model.monthName = "Nov";
            break;
          }
        case 2 :
          {
            model.monthName = "Dec";
            break;
          }
      }
    }
    return profitList;
  }

  static double calculateAnnualProfit ( List<DocumentSnapshot> list,
      int year ) {
    // this function calculates annual profit
    double profit = 0;
    for ( DocumentSnapshot i in list ) {
      if ( i['date']
          .toDate ( )
          .year == year ) {
        profit += i['profit'];
      }
    }
    return profit;
  }

  static String calculateItemQuantity ( List<DocumentSnapshot> list ) {
    // this function calculates total quantity of the products
    int quantity = 0;
    for ( DocumentSnapshot i in list ) {
      quantity += i['quantity'];
    }
    return quantity.toString ( );
  }

  static double calculateNetWorth ( List<DocumentSnapshot> list ) {
    // this function calculates the total net worth in millions
    double worth = 0;
    for ( DocumentSnapshot i in list ) {
      worth += i['profit'];
    }
    worth /= 1000000;
    return worth;
  }

}
