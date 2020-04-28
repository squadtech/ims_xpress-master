import 'package:flutter/material.dart';
import 'package:ims_xpress/const/Constants.dart';
import 'package:ims_xpress/views/ActivityAnalyticsAndReports.dart';
import 'package:ims_xpress/views/ActivityCategories.dart';
import 'package:ims_xpress/views/ActivityCheckList.dart';
import 'package:ims_xpress/views/ActivityLowStock.dart';
import 'package:ims_xpress/views/ActivitySalesHistory.dart';

class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

// this class creates the main navigation drawer or the side menu in the dashboard screen
class _MainDrawerState extends State<MainDrawer> {
  @override
  Widget build(BuildContext context) {
    return _getMainDrawer(context);
  }

  Widget _getMainDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          Container(
            height: 32.0,
          ),
          ListTile(
            leading: Icon(
              Icons.event_note,
              color: Constants.redLight,
            ),
            title: Text('Checklist'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityCheckList(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.apps,
              color: Constants.redLight,
            ),
            title: Text('Inventory'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityCategories(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.history,
              color: Constants.redLight,
            ),
            title: Text('Sale History'),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ActivitySalesHistory()));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.trending_down,
              color: Constants.redLight,
            ),
            title: Text('Low Stock'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => ActivityLowStock()));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.assessment,
              color: Constants.redLight,
            ),
            title: Text('Analytics and Reports'),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ActivityAnalyticsAndReports()));
            },
          ),
        ],
      ),
    );
  }
}
