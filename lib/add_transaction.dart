import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:cone/appbar.dart';

// enum Currency { USD, EUR, JPY, GBP, AUD, CAD, CHF, CNH, SEK, NZD }
List<String> currencies = [
  'USD',
  'EUR',
  'JPY',
  'GBP',
  'AUD',
  'CAD',
  'CHF',
  'CNY',
  'SEK',
  'NZD',
];

String showTransaction(
  String date,
  String description,
  String account1,
  String amount1,
  String currency1,
  String account2,
  String amount2,
  String account3,
  String amount3,
  String account4,
  String amount4,
) {
  return '''

$date $description
  $account1  $amount1 $currency1
  $account2  $amount2 USD
  $account3  $amount3 USD
  $account4  $amount4 USD
''';
}

// https://grokonez.com/flutter/flutter-read-write-file-example-path-provider-dartio-example
class AddTransaction extends StatefulWidget {
  AddTransactionState createState() => AddTransactionState();
}

class AddTransactionState extends State<AddTransaction> {
  var dateController = TextEditingController();
  var descriptionController = TextEditingController();
  var account1Controller = TextEditingController();
  var amount1Controller = TextEditingController();
  var currency1Controller = TextEditingController();
  var account2Controller = TextEditingController();
  var amount2Controller = TextEditingController();
  var account3Controller = TextEditingController();
  var amount3Controller = TextEditingController();
  var account4Controller = TextEditingController();
  var amount4Controller = TextEditingController();

  String date,
      description,
      account1,
      amount1,
      currency1,
      account2,
      amount2,
      account3,
      amount3,
      account4,
      amount4;

  final FocusNode dateFocus = FocusNode();
  final FocusNode descriptionFocus = FocusNode();
  final FocusNode account1Focus = FocusNode();
  final FocusNode amount1Focus = FocusNode();
  final FocusNode currency1Focus = FocusNode();
  final FocusNode account2Focus = FocusNode();
  final FocusNode amount2Focus = FocusNode();
  final FocusNode account3Focus = FocusNode();
  final FocusNode amount3Focus = FocusNode();
  final FocusNode account4Focus = FocusNode();
  final FocusNode amount4Focus = FocusNode();

  var _formKey = GlobalKey<FormState>();

  void initState() {
    super.initState();
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    account1Controller.text = 'expenses:';
    currency1 = 'USD';
    account2Controller.text = 'assets:checking';
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: coneAppBar(context),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              dateFormField(context),
              descriptionFormField(context),
              postings(context),
              Builder(
                builder: (BuildContext context) {
                  return RaisedButton(
                    child: Text('Add'),
                    onPressed: () {
                      _formKey.currentState.save();
                      String result = showTransaction(
                        date,
                        description,
                        account1,
                        amount1,
                        currency1,
                        account2,
                        amount2,
                        account3,
                        amount3,
                        account4,
                        amount4,
                      );
                      final snackBar = SnackBar(
                        content: Text(result),
                      );
                      TransactionStorage.writeTransaction(result);
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
      ),
    );
  }

  Widget postings(BuildContext context) {
    return Column(
      children: <Widget>[
        account1FormField(context),
        Row(
          children: <Widget>[
            Expanded(
              child: amount1FormField(context),
            ),
            currency1FormField(context),
          ],
        ),
        account2FormField(context),
        amount2FormField(context),
        account3FormField(context),
        amount3FormField(context),
        account4FormField(context),
        amount4FormField(),
      ],
    );
  }

  TextFormField dateFormField(BuildContext context) {
    return TextFormField(
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
        fieldFocusChange(context, descriptionFocus, account1Focus);
      },
      decoration: InputDecoration(labelText: 'Enter description'),
    );
  }

  TextFormField account1FormField(BuildContext context) {
    return TextFormField(
      controller: account1Controller,
      focusNode: account1Focus,
      textInputAction: TextInputAction.next,
      onSaved: (value) {
        account1 = value;
      },
      onFieldSubmitted: (term) {
        fieldFocusChange(context, account1Focus, amount1Focus);
      },
      decoration: InputDecoration(labelText: 'Enter account one'),
    );
  }

  TextFormField amount1FormField(BuildContext context) {
    return TextFormField(
      controller: amount1Controller,
      focusNode: amount1Focus,
      textInputAction: TextInputAction.next,
      onSaved: (value) {
        amount1 = value;
      },
      onFieldSubmitted: (term) {
        fieldFocusChange(context, amount1Focus, account2Focus);
      },
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: 'Enter amount one'),
    );
  }

  DropdownButton currency1FormField(BuildContext context) {
    return DropdownButton(
        value: currency1,
        items: currencies.map((String val) {
          return DropdownMenuItem<String>(
            value: val,
            child: Text(val),
          );
        }).toList(),
        // hint: Text('Enter currency one'),
        iconSize: 40.0,
        onChanged: (newVal) {
          currency1 = newVal;
          this.setState(() {});
        });
  }

  TextFormField account2FormField(BuildContext context) {
    return TextFormField(
      controller: account2Controller,
      focusNode: account2Focus,
      textInputAction: TextInputAction.next,
      onSaved: (value) {
        account2 = value;
      },
      onFieldSubmitted: (term) {
        fieldFocusChange(context, account2Focus, amount2Focus);
      },
      decoration: InputDecoration(labelText: 'Enter account two'),
    );
  }

  TextFormField amount2FormField(BuildContext context) {
    return TextFormField(
      controller: amount2Controller,
      focusNode: amount2Focus,
      textInputAction: TextInputAction.next,
      onSaved: (value) {
        amount2 = value;
      },
      onFieldSubmitted: (term) {
        fieldFocusChange(context, amount2Focus, account3Focus);
      },
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: 'Enter amount two'),
    );
  }

  TextFormField account3FormField(BuildContext context) {
    return TextFormField(
      controller: account3Controller,
      focusNode: account3Focus,
      textInputAction: TextInputAction.next,
      onSaved: (value) {
        account3 = value;
      },
      onFieldSubmitted: (term) {
        fieldFocusChange(context, account3Focus, amount3Focus);
      },
      decoration: InputDecoration(labelText: 'Enter account three'),
    );
  }

  TextFormField amount3FormField(BuildContext context) {
    return TextFormField(
      controller: amount3Controller,
      focusNode: amount3Focus,
      textInputAction: TextInputAction.next,
      onSaved: (value) {
        amount3 = value;
      },
      onFieldSubmitted: (term) {
        fieldFocusChange(context, amount3Focus, account4Focus);
      },
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: 'Enter amount three'),
    );
  }

  TextFormField account4FormField(BuildContext context) {
    return TextFormField(
      controller: account4Controller,
      focusNode: account4Focus,
      textInputAction: TextInputAction.next,
      onSaved: (value) {
        account4 = value;
      },
      onFieldSubmitted: (term) {
        fieldFocusChange(context, account4Focus, amount4Focus);
      },
      decoration: InputDecoration(labelText: 'Enter account four'),
    );
  }

  TextFormField amount4FormField() {
    return TextFormField(
      controller: amount4Controller,
      focusNode: amount4Focus,
      textInputAction: TextInputAction.done,
      onSaved: (value) {
        amount4 = value;
      },
      onFieldSubmitted: (term) {
        amount4Focus.unfocus();
      },
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: 'Enter amount four'),
    );
  }
}

class TransactionStorage {
  static Future<String> get _localPath async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String packageName = packageInfo.packageName;
    final directory = await getExternalStorageDirectory();
    return p.join(directory.path, 'Android', 'data', packageName, 'files');
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/.cone.ledger.txt');
  }

  static Future<File> writeTransaction(String transaction) async {
    final file = await _localFile;
    print(file);
    return file.writeAsString('$transaction', mode: FileMode.append);
  }
}
