import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(ConeApp());

final String title = 'cone';

class ConeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      initialRoute: '/',
      theme: ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.yellowAccent,
      ),
      routes: {
        '/': (context) => Home(),
        '/add-transaction': (context) => AddTransaction(),
        '/configuration': (context) => Configuration(),
      },
    );
  }
}

Widget coneAppBar(context) {
  return AppBar(
    title: Text(title),
    actions: <Widget>[
      IconButton(
        icon: Icon(Icons.settings),
        onPressed: () {
          Navigator.pushNamed(context, '/configuration');
        },
      )
    ],
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: coneAppBar(context),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Submit'),
        ),
      ),
    );
  }
}

// Future<String> setLedgerFile() async {
//   final prefs = SharedPreferences.getInstance();
//   return prefs.setString('ledger-file', '.cone.ledger');
// }

// Future<String> getLedgerFile() async {
//   final prefs = SharedPreferences.getInstance();
//   return prefs.getString('ledger-file');
// }

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

  // String _filePath;

  // void getFilePath() async {
  //   try {
  //     String filePath = await FilePicker.getFilePath(type: FileType.ANY);
  //     if (filePath == '') {
  //       return;
  //     }
  //     print("File path: " + filePath);
  //     setState(() {
  //       this._filePath = filePath;
  //     });
  //   } on PlatformException catch (e) {
  //     print("Error while picking the file: " + e.toString());
  //   }
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return new Scaffold(
  //     appBar: new AppBar(
  //       title: new Text('File Picker Example'),
  //     ),
  //     body: new Center(
  //       child: _filePath == null
  //           ? new Text('No file selected.')
  //           : new Text('Path' + _filePath),
  //     ),
  //     floatingActionButton: new FloatingActionButton(
  //       onPressed: getFilePath,
  //       tooltip: 'Select file',
  //       child: new Icon(Icons.sd_storage),
  //     ),
  //   );
  // }
}

class OldHome extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {},
            )
          ],
        ),
        body: AddTransactionForm(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
        ),
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
