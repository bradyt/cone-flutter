import 'package:flutter/material.dart';

import 'package:cone/home.dart';
import 'package:cone/add_transaction.dart';
// import 'package:cone/prototype-posting.dart';
// import 'package:cone/prototype-postings.dart';

void main() => runApp(ConeApp());

class ConeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cone',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      theme: ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.amberAccent,
      ),
      routes: {
        '/': (context) => Home(),
        '/add-transaction': (context) => AddTransaction(),
        // '/prototype-posting': (context) => PostingPage(),
        // '/prototype-postings': (context) => Postings(),
      },
    );
  }
}
