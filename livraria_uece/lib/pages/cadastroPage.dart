import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livraria_uece/extra/textformfield.dart';

class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(context),
    );
  }

  _body(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.only(top: 20, left: 40, right: 40),
          child: ListView(
            children: <Widget>[
              textformfield("Email", "Digite seu email", false,
                  controller: _tEmail,
                  validator: _validateEmail,
                  textInputAction: TextInputAction.next,
                  nextFocus: _focusSenha),
              SizedBox(height: 15),
              textformfield(
                "Senha",
                "Digite sua senha",
                true,
                controller: _tSenha,
                validator: _validateSenha,
                keyboardType: TextInputType.text,
                focusNode: _focusSenha,
                nextFocus: _focusNome,
              ),
              SizedBox(
                height: 15,
              ),
              textformfield(
                "Nome",
                "Digite seu nome",
                false,
                controller: _tNome,
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
                controller: _tIdade,
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
                controller: _tEndereco,
                validator: _validateEndereco,
                keyboardType: TextInputType.text,
                focusNode: _focusEndereco,
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                child: Container(
                  child: FlatButton(
                    color: Colors.pink,
                    child: Text(
                      "Cadastrar-se",
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
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: senha);

      if (auth.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }

      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: senha);

      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      await users
          .doc(userCredential.user.uid)
          .set({
            'nome': nome,
            'email': email,
            'endereco': endereco,
            'idade': idade,
            'nivel': 0
          })
          .then((value) => print("User Added"))
          .catchError((error) {
            print("Failed to add user: $error");
          });

      await FirebaseFirestore.instance.collection('shopping_cart').add({
        'user_id': userCredential.user.uid,
        'items': new Map<String, int>()
      }).then((value) {
        print("Shopping Cart Created");
      }).catchError((error) {
        print("Failed to create shopping cart: $error");
      });

      await FirebaseAuth.instance.signOut();

      BotToast.closeAllLoading();

      BotToast.showNotification(
        leading: (cancel) => SizedBox.fromSize(
            size: const Size(40, 40),
            child: IconButton(
              icon: Icon(Icons.assignment_turned_in, color: Colors.green),
              onPressed: cancel,
            )),
        title: (_) => Text('Cadastro efetuado com sucesso!'),
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
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');

        BotToast.closeAllLoading();

        BotToast.showNotification(
          leading: (cancel) => SizedBox.fromSize(
              size: const Size(40, 40),
              child: IconButton(
                icon: Icon(Icons.warning_rounded, color: Colors.red),
                onPressed: cancel,
              )),
          title: (_) => Text('Ocorreu um erro ao efetuar o login!'),
          subtitle: (_) => Text('Senha muito fraca.'),
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
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');

        BotToast.closeAllLoading();

        BotToast.showNotification(
          leading: (cancel) => SizedBox.fromSize(
              size: const Size(40, 40),
              child: IconButton(
                icon: Icon(Icons.warning_rounded, color: Colors.red),
                onPressed: cancel,
              )),
          title: (_) => Text('Ocorreu um erro ao efetuar o login!'),
          subtitle: (_) => Text('Uma conta com esse email já existe.'),
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
      }
    } catch (e) {
      print(e);
    }
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
      return "Proibido cadastro de menos de 16 anos";
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
