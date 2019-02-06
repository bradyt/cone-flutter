import 'package:flutter/material.dart';

import 'package:cone/appbar.dart';

class Home extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: coneAppBar(context),
      body: Center(
          child: Column(
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/add-transaction');
            },
            child: Text('Add transaction'),
          ),
          // RaisedButton(
          //   onPressed: () {
          //     Navigator.pushNamed(context, '/prototype-posting');
          //   },
          //   child: Text('Protoype posting'),
          // ),
          // RaisedButton(
          //   onPressed: () {
          //     Navigator.pushNamed(context, '/prototype-postings');
          //   },
          //   child: Text('Protoype postings'),
          // ),
        ],
      )),
    );
  }
}
