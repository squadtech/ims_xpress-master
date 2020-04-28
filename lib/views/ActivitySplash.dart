import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ims_xpress/const/Constants.dart';
import 'package:ims_xpress/views/ActivityDashBoard.dart';

class ActivitySplash extends StatefulWidget {
  @override
  _ActivitySplashState createState() => _ActivitySplashState();
}

class _ActivitySplashState extends State<ActivitySplash> {
  int _count = 0;
  StreamSubscription _subscription;

  @override
  void initState() {
    _subscription = _startTimer ( )
        .listen ( // listens to the stream that emits data after every second
      (number) {
        if (number == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ActivityDashBoard()),
          );
        }
      },
    );
    super.initState();
  }

  @override
  void dispose ( ) {
    // cancels the stream subscription which avoids memory leaks
    _subscription.cancel ( );
    super.dispose ( );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,

      child: Center(
        child: Container(
          height: 250,
          width: 200,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('images/logo.png'),)
          ),
          child: Padding(
            padding: const EdgeInsets.only(top:220),
            child: Center(child: Text('POS BOX',style: TextStyle(color: Colors.blue,fontSize: 32),)),
          ),
        ),
      ),
    );
  }

  Stream<int> _startTimer ( ) async* {
    // this function starts the stream that will emit data for four seconds
    while (_count < 4) {
      await Future.delayed(
        Duration(seconds: 1),
      );
      yield _count;
      _count++;
      if (_count == 4) {
        _subscription.cancel();
      }
    }
  }
}
