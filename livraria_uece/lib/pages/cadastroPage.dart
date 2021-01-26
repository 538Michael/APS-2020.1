import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livraria_uece/classes/conta/conta.dart';
import 'package:livraria_uece/extra/textformfield.dart';
import 'package:http/http.dart' as http;

import 'cadastroPage2.dart';

class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();

  final _tEmail = TextEditingController();

  final _tSenha = TextEditingController();

  final _tIdade = TextEditingController();

  final _focusSenha = FocusNode();

  final _focusIdade = FocusNode();

  bool _cadastroVerified = true;

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
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
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
                        "Próximo",
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
    int idade = int.parse(_tIdade.text);

    setState(() {
      _cadastroVerified = false;
    });
    var response = await http
        .post("https://ddc.community/michael/getConta.php?email=$email");

    if (response.statusCode == 200) {
      Map mapResponse = json.decode(response.body);
      List<dynamic> data = mapResponse["result"];

      if (data != null && data.length > 0) {
        _showDialog(context);
      } else {
        Conta conta = new Conta();
        conta.email = email;
        conta.senha = senha;
        conta.idade = idade;

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CadastroPagePart2(conta: conta)),
        );
      }
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
      return "A senha deve ser preenchida";
    }
    if (text.length < 6) {
      return "A senha está inválida";
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
}
