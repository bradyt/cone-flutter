import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:cone/appbar.dart';

// https://grokonez.com/flutter/flutter-read-write-file-example-path-provider-dartio-example
class AddTransaction extends StatefulWidget {
  AddTransactionState createState() => AddTransactionState();
}

class AddTransactionState extends State<AddTransaction> {
  var dateController = TextEditingController();
  var descriptionController = TextEditingController();
  var account1Controller = TextEditingController();
  var amount1Controller = TextEditingController();
  var account2Controller = TextEditingController();
  var amount2Controller = TextEditingController();

  String date, description, account1, amount1, account2, amount2;

  final FocusNode dateFocus = FocusNode();
  final FocusNode descriptionFocus = FocusNode();
  final FocusNode account1Focus = FocusNode();
  final FocusNode amount1Focus = FocusNode();
  final FocusNode account2Focus = FocusNode();
  final FocusNode amount2Focus = FocusNode();

  var _formKey = GlobalKey<FormState>();

  void initState() {
    super.initState();
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    account1Controller.text = 'expenses:';
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
                      final snackBar = SnackBar(
                        content: Text(
                          '''$date $description
  $account1  $amount1
  $account2${(amount2 == null) ? '' : '  ' + amount2}''',
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
      ),
    );
  }

  Widget postings(BuildContext context) {
    return Column(
      children: <Widget>[
        account1FormField(context),
        amount1FormField(),
        account2FormField(context),
        amount2FormField(),
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

  TextFormField amount1FormField() {
    return TextFormField(
      controller: amount1Controller,
      focusNode: amount1Focus,
      textInputAction: TextInputAction.done,
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

  TextFormField amount2FormField() {
    return TextFormField(
      controller: amount2Controller,
      focusNode: amount2Focus,
      textInputAction: TextInputAction.done,
      onSaved: (value) {
        amount2 = value;
      },
      onFieldSubmitted: (term) {
        amount2Focus.unfocus();
      },
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: 'Enter amount two'),
    );
  }
}
