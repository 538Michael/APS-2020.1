import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/extra/textformfield.dart';

class CadastrarEditoraPage extends StatefulWidget {
  @override
  _CadastrarEditoraPageState createState() => _CadastrarEditoraPageState();
}

class _CadastrarEditoraPageState extends State<CadastrarEditoraPage> {
  final _formKey = GlobalKey<FormState>();

  final _tNome = TextEditingController();

  bool _cadastroVerified = true;

  FirebaseAuth auth = FirebaseAuth.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  _body() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastrar Editora"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.only(top: 20, left: 40, right: 40),
          child: ListView(
            children: <Widget>[
              textformfield("Nome", "Digite o nome", false,
                  controller: _tNome,
                  validator: _validateNome,
                  textInputAction: TextInputAction.next),
              SizedBox(height: 15),
              Container(
                child: Visibility(
                  visible: _cadastroVerified,
                  child: Container(
                    child: FlatButton(
                      color: Colors.pink,
                      child: Text(
                        "Cadastrar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      onPressed: () {
                        _onButtonClick(context);
                      },
                    ),
                  ),
                  replacement: Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _validateNome(String text) {
    if (text.isEmpty) {
      return "O nome deve ser preenchido";
    }
    return null;
  }

  void _onButtonClick(BuildContext context) async {
    FocusScope.of(context).unfocus();
    bool formOk = _formKey.currentState.validate();
    if (!formOk) {
      return;
    }

    String nome = _tNome.text;

    setState(() {
      _cadastroVerified = false;
    });

    try {
      if (auth.currentUser == null) {
        return;
      }

      CollectionReference users = firestore.collection('users');

      DocumentSnapshot data = await users.doc(auth.currentUser.uid).get();

      if (data.data()['nivel'] != 1) {
        return;
      }

      CollectionReference autors = firestore.collection('publishers');

      await autors
          .add({
        'nome': nome,
      })
          .then((value) => print("Editora Added"))
          .catchError((error) => print("Failed to add editora: $error"));

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      _cadastroVerified = true;
    });
  }
}
