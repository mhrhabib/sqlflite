import 'package:flutter/material.dart';
import 'package:sql_crud/models/contact.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLFlite Crud',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'SQL Crud'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final Contact _contact = Contact();
  List<Contact> contactList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _form(),
            _list(),
          ],
        ),
      ),
    );
  }

  _form() => Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  onSaved: (newValue) => setState(() {
                    _contact.name = newValue;
                  }),
                  validator: (value) =>
                      (value!.isEmpty ? "this field is required" : null),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Mobile'),
                  onSaved: (newValue) => setState(() {
                    _contact.mobile = newValue;
                  }),
                  validator: (value) => (value!.length < 11
                      ? "At least 11 character required"
                      : null),
                ),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    child: const Text("Submit"),
                    onPressed: () {
                      var form = _formKey.currentState;
                      if (form!.validate()) {
                        form.save();
                        setState(() {
                          contactList.add(
                            Contact(
                              id: null,
                              name: _contact.name,
                              mobile: _contact.mobile,
                            ),
                          );
                        });
                        print(_contact.name);
                      }
                    },
                  ),
                ),
              ],
            )),
      );

  _list() => Expanded(
        child: Card(
          margin: const EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: ListView.builder(
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ListTile(
                    tileColor: Colors.grey[200],
                    leading: const Icon(
                      Icons.account_circle,
                      color: Colors.blue,
                      size: 50,
                    ),
                    title: Text(contactList[index].name!.toUpperCase()),
                    subtitle: Text(contactList[index].mobile!),
                  ),
                  const Divider(height: 5),
                ],
              );
            },
            itemCount: contactList.length,
          ),
        ),
      );
}
