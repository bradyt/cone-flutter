import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:cone/transaction.dart';
import 'package:cone/posting_widget.dart';
import 'package:cone/posting_controller.dart';

class AddTransaction extends StatefulWidget {
  AddTransactionState createState() => AddTransactionState();
}

class AddTransactionState extends State<AddTransaction> {
  var dateController = TextEditingController();
  var descriptionController = TextEditingController();

  final FocusNode dateFocus = FocusNode();
  final FocusNode descriptionFocus = FocusNode();

  var _formKey = GlobalKey<FormState>();

  List<PostingController> postingControllers = [];

  void initState() {
    super.initState();
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    postingControllers.add(PostingController(
      key: UniqueKey(),
      accountController: TextEditingController(text: 'expenses:'),
      amountController: TextEditingController(),
      currencyController: TextEditingController(text: 'USD'),
    ));
    postingControllers.add(PostingController(
      key: UniqueKey(),
      accountController: TextEditingController(text: 'assets:checking'),
      amountController: TextEditingController(),
      currencyController: TextEditingController(text: 'USD'),
    ));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('cone'),
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () => submitTransaction(context),
                ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              dateAndDescriptionWidget(context),
            ]..addAll(
                List<int>.generate(postingControllers.length, (i) => i)
                    .map((i) {
                  final postingController = postingControllers[i];
                  return Dismissible(
                      key: postingController.key,
                      onDismissed: (direction) {
                        setState(() {
                          postingControllers.removeAt(i);
                        });
                      },
                      child: PostingWidget(
                        context: context,
                        index: i,
                        accountController: postingController.accountController,
                        amountController: postingController.amountController,
                        currencyController:
                            postingController.currencyController,
                      ));
                }),
              ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => setState(() => addPosting()),
      ),
    );
  }

  void addPosting() {
    postingControllers.add(PostingController(
      key: UniqueKey(),
      accountController: TextEditingController(),
      amountController: TextEditingController(),
      currencyController: TextEditingController(),
    ));
  }

  void submitTransaction(BuildContext context) {
    _formKey.currentState.save();
    Transaction txn = Transaction(
      dateController.text,
      descriptionController.text,
      postingControllers
          .map((pc) => Posting(
                account: pc.accountController.text,
                amount: pc.amountController.text,
                currency: pc.currencyController.text,
              ))
          .toList(),
    );
    print(txn);
    if (_formKey.currentState.validate()) {
      String result = txn.toString();
      final snackBar = SnackBar(
        content: RichText(
          text: TextSpan(
            text: result,
            style: TextStyle(
              fontFamily: "RobotoMono",
            ),
          ),
        ),
      );
      TransactionStorage.writeTransaction('\n\n' + result);
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  Row dateAndDescriptionWidget(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: dateFormField(context),
        ),
        Expanded(
          child: descriptionFormField(context),
        ),
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
        dateController.text = value;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Date',
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
    // fieldFocusChange(context, dateFocus, descriptionFocus);
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
      validator: (value) {
        if (value.isEmpty) {
          return 'Please add a description, e.g., "Towel"';
        }
      },
      onSaved: (value) {
        descriptionController.text = value;
      },
      onFieldSubmitted: (term) {
        descriptionFocus.unfocus();
        if (postingControllers.length != 0) {
          // FocusScope.of(context).requestFocus();
        }
      },
      decoration: InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
      ),
    );
  }

  fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

// class AccountFormField extends TextFormField {
//   AccountFormField(int index, )
//           child: TextFormField(
//             decoration: InputDecoration(labelText: 'Account $n'),
//             initialValue:
//                 (n == 0) ? 'expenses:' : ((n == 1) ? 'assets:checking' : null),
//           ),

// }

}

class PostingFieldStuff {
  TextEditingController accountController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController currencyController = TextEditingController();

  final FocusNode accountFocus = FocusNode();
  final FocusNode amountFocus = FocusNode();
  final FocusNode currencyFocus = FocusNode();
}

class PostingForm extends StatefulWidget {
  PostingFormState createState() => PostingFormState();
}

class PostingFormState extends State<PostingForm> {
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[],
    );

    //   TextFormField account1FormField(BuildContext context) {
    //     return TextFormField(
    //       controller: account1Controller,
    //       focusNode: account1Focus,
    //       textInputAction: TextInputAction.next,
    //       onSaved: (value) {
    //         account1 = value;
    //       },
    //       onFieldSubmitted: (term) {
    //         fieldFocusChange(context, account1Focus, amount1Focus);
    //       },
    //       decoration: InputDecoration(labelText: 'Account one'),
    //     );
    //   }

    //   ;

    //   TextFormField amount1FormField(BuildContext context) {
    //     return TextFormField(
    //       controller: amount1Controller,
    //       focusNode: amount1Focus,
    //       textInputAction: TextInputAction.next,
    //       validator: (value) {
    //         if (value.isEmpty) {
    //           return 'Please enter a first amount';
    //         }
    //       },
    //       onSaved: (value) {
    //         amount1 = value;
    //       },
    //       onFieldSubmitted: (term) {
    //         fieldFocusChange(context, amount1Focus, account4Focus);
    //       },
    //       keyboardType: TextInputType.number,
    //       decoration: InputDecoration(labelText: 'Amount one'),
    //     );
    //   }

    //   DropdownButton currency1FormField(BuildContext context) {
    //     return DropdownButton(
    //         value: currency1,
    //         items: currencies.map((String val) {
    //           return DropdownMenuItem<String>(
    //             value: val,
    //             child: Text(val),
    //           );
    //         }).toList(),
    //         // hint: Text('Enter currency one'),
    //         iconSize: 40.0,
    //         onChanged: (newVal) {
    //           currency1 = newVal;
    //           this.setState(() {});
    //         });
    //   }

    //   return null;
    // }
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

enum Fields { date, description, account, amount, currency }

List<String> accounts = [
  'assets:checking',
  'assets:cash',
  'expenses:food',
  'expenses:groceries',
  'expenses:transportation',
  'expenses:rent',
  'expenses:miscellaneous',
  'equity',
];

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
