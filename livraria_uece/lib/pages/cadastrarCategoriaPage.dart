import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/extra/textformfield.dart';

class CadastrarCategoriaPage extends StatefulWidget {
  @override
  _CadastrarCategoriaPageState createState() => _CadastrarCategoriaPageState();
}

class _CadastrarCategoriaPageState extends State<CadastrarCategoriaPage> {
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
        title: Text("Cadastrar Categoria"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.only(top: 20, left: 40, right: 40),
          child: ListView(
            children: <Widget>[
              textformfield("Nome", "Digite o nome", false,
                  readOnly: !_cadastroVerified,
                  controller: _tNome,
                  validator: _validateNome,
                  textInputAction: TextInputAction.next),
              SizedBox(height: 15),
              Container(
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

    BotToast.showLoading(
      clickClose: false,
      allowClick: false,
      crossPage: false,
      backButtonBehavior: BackButtonBehavior.none,
      animationDuration: Duration(milliseconds: 200),
      animationReverseDuration: Duration(milliseconds: 200),
      backgroundColor: Color(0x42000000),
    );

    try {
      if (auth.currentUser == null) {
        return;
      }

      CollectionReference users = firestore.collection('users');

      DocumentSnapshot data = await users.doc(auth.currentUser.uid).get();

      if (data.data()['nivel'] != 1) {
        return;
      }

      CollectionReference categories = firestore.collection('categories');

      await categories.add({
        'nome': nome,
      }).then((value) {
        print("Categoria Added: ${value.id}");

        BotToast.closeAllLoading();

        BotToast.showNotification(
          leading: (cancel) => SizedBox.fromSize(
              size: const Size(40, 40),
              child: IconButton(
                icon: Icon(Icons.assignment_turned_in, color: Colors.green),
                onPressed: cancel,
              )),
          title: (_) => Text('Categoria cadastrada com sucesso!'),
          trailing: (cancel) => IconButton(
            icon: Icon(Icons.cancel),
            onPressed: cancel,
          ),
          enableSlideOff: true,
          backButtonBehavior: BackButtonBehavior.none,
          crossPage: true,
          contentPadding: EdgeInsets.all(2),
          onlyOne: true,
          animationDuration: Duration(milliseconds: 200),
          animationReverseDuration: Duration(milliseconds: 200),
          duration: Duration(seconds: 3),
        );

        if (!mounted) return;

        setState(() {
          _cadastroVerified = true;
        });

        Navigator.of(context).pop();
      }).catchError((error) {
        print("Failed to add categoria: $error");

        BotToast.closeAllLoading();

        BotToast.showNotification(
          leading: (cancel) => SizedBox.fromSize(
              size: const Size(40, 40),
              child: IconButton(
                icon: Icon(Icons.warning_rounded, color: Colors.red),
                onPressed: cancel,
              )),
          title: (_) => Text('Ocorreu um erro ao cadastrar categoria!'),
          subtitle: (_) => Text('$error'),
          trailing: (cancel) => IconButton(
            icon: Icon(Icons.cancel),
            onPressed: cancel,
          ),
          enableSlideOff: true,
          backButtonBehavior: BackButtonBehavior.none,
          crossPage: true,
          contentPadding: EdgeInsets.all(2),
          onlyOne: true,
          animationDuration: Duration(milliseconds: 200),
          animationReverseDuration: Duration(milliseconds: 200),
          duration: Duration(seconds: 3),
        );

        if (!mounted) return;

        setState(() {
          _cadastroVerified = true;
        });
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }
}
