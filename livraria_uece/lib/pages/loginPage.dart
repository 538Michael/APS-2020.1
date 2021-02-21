import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/services/request.dart';
import 'package:livraria_uece/extra/textformfield.dart';

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
      if (auth.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }

      await auth
          .signInWithEmailAndPassword(email: email, password: senha)
          .then((value) {
        BotToast.closeAllLoading();

        BotToast.showNotification(
          leading: (cancel) => SizedBox.fromSize(
              size: const Size(40, 40),
              child: IconButton(
                icon: Icon(Icons.assignment_turned_in, color: Colors.green),
                onPressed: cancel,
              )),
          title: (_) => Text('Login efetuado com sucesso!'),
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
          _loginVerified = true;
        });

        Navigator.of(context).pop(true);

        Request(loadShoppingCart: true);
      });

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');

        BotToast.closeAllLoading();

        BotToast.showNotification(
          leading: (cancel) => SizedBox.fromSize(
              size: const Size(40, 40),
              child: IconButton(
                icon: Icon(Icons.warning_rounded, color: Colors.red),
                onPressed: cancel,
              )),
          title: (_) => Text('Ocorreu um erro ao efetuar o login!'),
          subtitle: (_) => Text('Nenhum usuário encontrado com esse email.'),
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
          _loginVerified = true;
        });

      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');

        BotToast.closeAllLoading();

        BotToast.showNotification(
          leading: (cancel) => SizedBox.fromSize(
              size: const Size(40, 40),
              child: IconButton(
                icon: Icon(Icons.warning_rounded, color: Colors.red),
                onPressed: cancel,
              )),
          title: (_) => Text('Ocorreu um erro ao efetuar o login!'),
          subtitle: (_) => Text('Senha incorreta.'),
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
          _loginVerified = true;
        });
      }
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
}
