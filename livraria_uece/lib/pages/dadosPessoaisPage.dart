import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livraria_uece/extra/textformfield.dart';

class DadosPessoaisPage extends StatefulWidget {
  @override
  _DadosPessoaisState createState() => _DadosPessoaisState();
}

class _DadosPessoaisState extends State<DadosPessoaisPage> {
  final _formKey = GlobalKey<FormState>();

  final _tEmail = TextEditingController();

  final _tSenha = TextEditingController();

  final _tNome = TextEditingController();

  final _tIdade = TextEditingController();

  final _tEndereco = TextEditingController();

  final _focusSenha = FocusNode();

  final _focusNome = FocusNode();

  final _focusIdade = FocusNode();

  final _focusEndereco = FocusNode();

  bool _cadastroVerified = true;

  FirebaseAuth auth = FirebaseAuth.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final _streamController = new StreamController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(context),
    );
  }

  void _carregarDadosPessoais() async {
    if (auth.currentUser != null) {
      CollectionReference users = firestore.collection('users');

      _streamController.add(await users.doc(auth.currentUser.uid).get());
    }
  }

  _body(BuildContext context) {
    _carregarDadosPessoais();
    return Scaffold(
        appBar: AppBar(
          title: Text("Dados Pessoais"),
          centerTitle: true,
        ),
        body: StreamBuilder(
          stream: _streamController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Erro ao acessar os dados."));
            }
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            Map<String, dynamic> data = new Map();
            if (snapshot.hasData) {
              data = snapshot.data.data();
            }

            return Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.only(top: 20, left: 40, right: 40),
                child: ListView(
                  children: <Widget>[
                    textformfield("Email", "Digite seu email", false,
                        controller: _tEmail..text = data['email'],
                        validator: _validateEmail,
                        textInputAction: TextInputAction.next,
                        nextFocus: _focusNome),
                    SizedBox(
                      height: 15,
                    ),
                    textformfield(
                      "Nome",
                      "Digite seu nome",
                      false,
                      controller: _tNome..text = data['nome'],
                      validator: _validateNome,
                      keyboardType: TextInputType.text,
                      focusNode: _focusNome,
                      nextFocus: _focusIdade,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    textformfield(
                      "Idade",
                      "Digite sua idade",
                      false,
                      controller: _tIdade..text = data['idade'].toString(),
                      validator: _validateIdade,
                      keyboardType: TextInputType.number,
                      focusNode: _focusIdade,
                      nextFocus: _focusEndereco,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    textformfield(
                      "Endereço",
                      "Digite seu endereço",
                      false,
                      controller: _tEndereco..text = data['endereco'],
                      validator: _validateEndereco,
                      keyboardType: TextInputType.text,
                      focusNode: _focusEndereco,
                      nextFocus: _focusSenha,
                    ),
                    SizedBox(height: 15),
                    textformfield(
                      "Nova Senha",
                      "Digite sua senha",
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
                        visible: _cadastroVerified,
                        child: Container(
                          child: FlatButton(
                            color: Colors.pink,
                            child: Text(
                              "Salvar",
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
            );
          },
        ));
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Erro"),
          content: new Text("Uma conta com esse email já está cadastrada."),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onButtonClick(BuildContext context) async {
    FocusScope.of(context).unfocus();
    bool formOk = _formKey.currentState.validate();
    if (!formOk) {
      return;
    }

    String email = _tEmail.text;
    String senha = _tSenha.text;
    String nome = _tNome.text;
    int idade = int.parse(_tIdade.text);
    String endereco = _tEndereco.text;

    setState(() {
      _cadastroVerified = false;
    });

    try {
      if (auth.currentUser == null) {
        return;
      }

      CollectionReference users = firestore.collection('users');

      List<Future<dynamic>> futures = new List();

      futures.add(auth.currentUser.updateEmail(email));

      if (senha.isNotEmpty) {
        futures.add(auth.currentUser
            .updatePassword(senha)
            .then((value) => print("Password Updated"))
            .catchError((error) => print("Failed to update password: $error")));
      }

      futures.add(users
          .doc(auth.currentUser.uid)
          .update({
            'nome': nome,
            'email': email,
            'endereco': endereco,
            'idade': idade,
            'nivel': 0
          })
          .then((value) => print("User Updated"))
          .catchError((error) => print("Failed to update user: $error")));

      await Future.wait(futures);

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
      return null;
    }
    if (text.length < 6) {
      return "A senha está inválida";
    }

    return null;
  }

  String _validateNome(String text) {
    if (text.isEmpty) {
      return "O nome deve ser preenchido";
    }
    return null;
  }

  String _validateIdade(String text) {
    if (text.isEmpty) {
      return "A idade deve ser preenchida";
    }
    if (int.parse(text) < 16) {
      return "Proibido menores de 16 anos";
    }
    return null;
  }

  String _validateEndereco(String text) {
    if (text.isEmpty) {
      return "O endereço deve ser preenchido";
    }

    return null;
  }
}
