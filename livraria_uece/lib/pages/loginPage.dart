import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/extra/textformfield.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:livraria_uece/extra/globals.dart' as globals;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _ExampleMask {
  final TextEditingController textController = TextEditingController();
  final MaskTextInputFormatter formatter;
  final FormFieldValidator<String> validator;
  final String hint;
  _ExampleMask({ @required this.formatter, this.validator, @required this.hint });
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _tEmail = TextEditingController();

  final _tSenha = TextEditingController();

  final _focusSenha = FocusNode();

  bool _loginVerified = true;

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
              SizedBox(height: 15,),
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
