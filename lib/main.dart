import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
class AddTransaction extends StatefulWidget {
  AddTransactionState createState() => AddTransactionState();
}

class AddTransactionState extends State<AddTransaction> {
  var dateController = TextEditingController();
  var descriptionController = TextEditingController();
  var accountController = TextEditingController();
  var amountController = TextEditingController();

  String date, description, account, amount;

  final FocusNode dateFocus = FocusNode();
  final FocusNode descriptionFocus = FocusNode();
  final FocusNode accountFocus = FocusNode();
  final FocusNode amountFocus = FocusNode();

  var _formKey = GlobalKey<FormState>();

  void initState() {
    super.initState();
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Widget build(BuildContext context) {
    // dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return Scaffold(
      appBar: coneAppBar(context),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            dateFormField(context),
            descriptionFormField(context),
            accountFormField(context),
            amountFormField(),
            Builder(
              builder: (BuildContext context) {
                return RaisedButton(
                  child: Text('Add'),
                  onPressed: () {
                    _formKey.currentState.save();
                    final snackBar = SnackBar(
                      content: Text(
                        '''$date $description
  $account  $amount
  assets:checking''',
                      ),
                    );
                    Scaffold.of(context).showSnackBar(snackBar);
                  },
                );
              },
            ),
            RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField dateFormField(BuildContext context) {
    return TextFormField(
      // initialValue: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      controller: dateController,
      textInputAction: TextInputAction.next,
      focusNode: dateFocus,
      onFieldSubmitted: (term) {
        fieldFocusChange(context, dateFocus, descriptionFocus);
      },
      onSaved: (value) {
        date = value;
      },
      decoration: InputDecoration(
        labelText: 'Enter date',
        suffixIcon: IconButton(
          onPressed: () {
            chooseDate(context, dateController.text);
          },
          icon: Icon(
            Icons.calendar_today,
          ),
        ),
      ),
    );
  }

  fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Future chooseDate(BuildContext context, String initialDateString) async {
    DateTime now = DateTime.now();
    DateTime initialDate = convertToDate(initialDateString) ?? now;
    DateTime result = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (result == null) return;

    setState(() {
      dateController.text = DateFormat('yyyy-MM-dd').format(result);
    });
    fieldFocusChange(context, dateFocus, descriptionFocus);
  }

  DateTime convertToDate(String input) {
    try {
      var d = new DateFormat('yyyy-MM-dd').parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  TextFormField descriptionFormField(BuildContext context) {
    return TextFormField(
      controller: descriptionController,
      autofocus: true,
      focusNode: descriptionFocus,
      textInputAction: TextInputAction.next,
      onSaved: (value) {
        description = value;
      },
      onFieldSubmitted: (term) {
        fieldFocusChange(context, descriptionFocus, accountFocus);
      },
      decoration: InputDecoration(labelText: 'Enter description'),
    );
  }

  TextFormField accountFormField(BuildContext context) {
    return TextFormField(
      controller: accountController,
      focusNode: accountFocus,
      textInputAction: TextInputAction.next,
      onSaved: (value) {
        account = value;
      },
      onFieldSubmitted: (term) {
        fieldFocusChange(context, accountFocus, amountFocus);
      },
      decoration: InputDecoration(labelText: 'Enter account'),
    );
  }

  TextFormField amountFormField() {
    return TextFormField(
      controller: amountController,
      focusNode: amountFocus,
      textInputAction: TextInputAction.done,
      onSaved: (value) {
        amount = value;
      },
      onFieldSubmitted: (term) {
        amountFocus.unfocus();
      },
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: 'Enter amount'),
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
