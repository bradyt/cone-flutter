import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(ConeApp());

final String title = 'cone';

class ConeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      theme: ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.amberAccent,
      ),
      routes: {
        '/': (context) => Home(),
        '/add-transaction': (context) => AddTransaction(),
      },
    );
  }
}

Widget coneAppBar(context) {
  return AppBar(
    title: Text(title),
  );
}

class Home extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: coneAppBar(context),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/add-transaction');
          },
          child: Text('Add transaction'),
        ),
      ),
    );
  }
}

// https://grokonez.com/flutter/flutter-read-write-file-example-path-provider-dartio-example
class AddTransaction extends StatelessWidget {
  final FocusNode dateFocus = FocusNode();
  final FocusNode descriptionFocus = FocusNode();
  final FocusNode accountFocus = FocusNode();
  final FocusNode amountFocus = FocusNode();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: coneAppBar(context),
      body: Center(
        child: Column(
          children: <Widget>[
            TextFormField(
              textInputAction: TextInputAction.next,
              autofocus: true,
              // try fixing the focus issue by basing off of
              // https://github.com/liemvo/Flutter_bmi
              focusNode: dateFocus,
              onFieldSubmitted: (term) {
                dateFocus.unfocus();
                descriptionFocus.unfocus();
                accountFocus.unfocus();
                amountFocus.unfocus();
                FocusScope.of(context).requestFocus(descriptionFocus);
              },
              decoration: InputDecoration(
                labelText: 'Enter date',
                suffixIcon: IconButton(
                  onPressed: () => showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(0),
                        lastDate: DateTime(2050),
                      ),
                  icon: Icon(
                    Icons.calendar_today,
                  ),
                ),
              ),
            ),
            TextFormField(
              focusNode: descriptionFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (term) {
                dateFocus.unfocus();
                descriptionFocus.unfocus();
                accountFocus.unfocus();
                amountFocus.unfocus();
                FocusScope.of(context).requestFocus(accountFocus);
              },
              decoration: InputDecoration(labelText: 'Enter description'),
            ),
            TextFormField(
              focusNode: accountFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (term) {
                dateFocus.unfocus();
                descriptionFocus.unfocus();
                accountFocus.unfocus();
                amountFocus.unfocus();
                FocusScope.of(context).requestFocus(amountFocus);
              },
              decoration: InputDecoration(labelText: 'Enter account'),
            ),
            TextFormField(
              focusNode: amountFocus,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (term) {
                dateFocus.unfocus();
                descriptionFocus.unfocus();
                accountFocus.unfocus();
                amountFocus.unfocus();
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter amount'),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class Configuration extends StatefulWidget {
  ConfigurationState createState() => ConfigurationState();
}

class ConfigurationState extends State<Configuration> {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/hello.txt');
  }

  Future<File> writeCounter() async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('hello world!');
  }

  String ledgerFileName;
  TextEditingController textController = TextEditingController();

  void initState() {
    super.initState();
    loadLedgerFileName();
  }

  loadLedgerFileName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ledgerFileName = prefs.getString('ledger-file');
      prefs.setString('ledger-file', '$_localFile');
      if (ledgerFileName == null) {
        prefs.setString('ledger-file', '$_localFile');
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: coneAppBar(context),
      body: Column(
        children: <Widget>[
          TextField(
            controller: textController,
          ),
          RaisedButton(
            onPressed: () {
              setState(() {
                textController.text = ledgerFileName;
                writeCounter();
              });
            },
            child: Text('Submit'),
          ),
          RaisedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Done'),
          ),
        ],
      ),
    );
  }
}

class AddTransactionForm extends StatefulWidget {
  AddTransactionFormState createState() {
    return AddTransactionFormState();
  }
}

class AddTransactionFormState extends State<AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text('Processing Data')));
                    }
                  },
                  child: Text('Submit'),
                ),
              ),
            ]));
  }
}

class TransactionStorage {
  Future<String> get _localPath async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String packageName = packageInfo.packageName;
    final directory = await getExternalStorageDirectory();
    return p.join(directory.path, 'Android', 'data', packageName, 'files');
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/.cone.ledger');
  }

  Future<File> writeTransaction(String transaction) async {
    final file = await _localFile;
    return file.writeAsString('$transaction');
  }
}
