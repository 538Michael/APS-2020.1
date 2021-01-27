import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livraria_uece/extra/textformfield.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _tEmail = TextEditingController();

  final _tSenha = TextEditingController();

  final _focusSenha = FocusNode();

  bool _loginVerified = true;

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  _body() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.only(top: 20, left: 40, right: 40),
          child: ListView(
            children: <Widget>[
              textformfield("Email", "Digite o email", false,
                  controller: _tEmail,
                  validator: _validateEmail,
                  textInputAction: TextInputAction.next,
                  nextFocus: _focusSenha),
              SizedBox(height: 15),
              textformfield(
                "Senha",
                "Digite a senha",
                true,
                controller: _tSenha,
                validator: _validateSenha,
                keyboardType: TextInputType.text,
                focusNode: _focusSenha,
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                child: Visibility(
                  visible: _loginVerified,
                  child: Container(
                    child: FlatButton(
                      color: Colors.pink,
                      child: Text(
                        "Acessar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      onPressed: () {
                        _onClickLogin(context);
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

  void _onClickLogin(context) async {
    bool formOk = _formKey.currentState.validate();
    if (!formOk) {
      return;
    }

    String email = _tEmail.text;
    String senha = _tSenha.text;

    setState(() {
      _loginVerified = false;
    });

    try {

      if(auth.currentUser != null){
        await FirebaseAuth.instance.signOut();
      }

      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email,
          password: senha
      );

      Navigator.of(context).pop(true);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }

    setState(() {
      _loginVerified = true;
    });
  }

  String _validateEmail(String text) {
    if (text.isEmpty) {
      return "O Email deve ser preenchido";
    }
    if (text.length < 7) {
      return "O Email é inválido";
    }
    return null;
  }

  String _validateSenha(String text) {
    if (text.isEmpty) {
      return "A senha deve ser preenchida";
    }
    if (text.length < 6) {
      return "A senha está inválida";
    }

    return null;
  }
}
