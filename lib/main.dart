import 'package:flutter/material.dart';
import 'package:sql_crud/models/contact.dart';

import 'db/database_helper.dart';

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
  Contact _contact = Contact();
  List<Contact> contactList = [];
  DatabaseHelper? _dbHelper;
  final _ctrlName = TextEditingController();
  final _ctrlMobile = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper.instance;
    _refreshContactList();
  }

  _refreshContactList() async {
    List<Contact> x = await _dbHelper!.fetchContacts();
    setState(() {
      contactList = x;
    });
  }

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
                  controller: _ctrlName,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  onSaved: (newValue) => setState(() {
                    _contact.name = newValue;
                  }),
                  validator: (value) =>
                      (value!.isEmpty ? "this field is required" : null),
                ),
                TextFormField(
                  controller: _ctrlMobile,
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
                    onPressed: () async {
                      var form = _formKey.currentState;
                      if (form!.validate()) {
                        form.save();
                        await _dbHelper!.insertContact(_contact);
                        form.reset();
                        await _refreshContactList();
                        await _dbHelper!.updateContact(_contact);
                        _resetForm();
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
                    onTap: () {
                      _showForEdit(index);
                    },
                    trailing: IconButton(
                        icon: const Icon(Icons.delete_sweep),
                        onPressed: () async {
                          await _dbHelper!
                              .deleteContact(contactList[index].id!);
                          _resetForm();
                          _refreshContactList();
                        }),
                  ),
                  const Divider(height: 5),
                ],
              );
            },
            itemCount: contactList.length,
          ),
        ),
      );

  _showForEdit(index) {
    setState(() {
      _contact = contactList[index];
      _ctrlName.text = contactList[index].name!;
      _ctrlName.text = contactList[index].mobile!;
    });
  }

  _resetForm() {
    setState(() {
      _formKey.currentState!.reset();
      _ctrlName.clear();
      _ctrlMobile.clear();
      _contact.id = null;
    });
  }
}
