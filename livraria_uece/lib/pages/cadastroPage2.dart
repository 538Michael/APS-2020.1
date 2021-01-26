import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/conta/conta.dart';
import 'package:livraria_uece/extra/textformfield.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CadastroPagePart2 extends StatefulWidget {
  Conta conta;

  CadastroPagePart2({Key key, this.conta}) : super(key: key);

  @override
  _CadastroPageStatePart2 createState() => _CadastroPageStatePart2(conta);
}

class _CadastroPageStatePart2 extends State<CadastroPagePart2> {

  Conta conta;

  _CadastroPageStatePart2(Conta conta){
    this.conta = conta;
  }

  final _formKey = GlobalKey<FormState>();

  final _tCPF = TextEditingController();

  final _tNome = TextEditingController();

  final _tEndereco = TextEditingController();

  final _focusCPF = FocusNode();

  final _focusEndereco = FocusNode();

  final maskFormatter = new MaskTextInputFormatter(
      mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});

  bool _cadastroVerified = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  _body() {
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
              textformfield("Nome", "Digite seu nome", false,
                  controller: _tNome,
                  validator: _validateNome,
                  textInputAction: TextInputAction.next,
                  nextFocus: _focusCPF),
              SizedBox(height: 15),
              textformfield(
                "CPF",
                "Digite seu CPF",
                false,
                controller: _tCPF,
                validator: _validateCPF,
                keyboardType: TextInputType.number,
                focusNode: _focusCPF,
                nextFocus: _focusEndereco,
                inputFormatters: [maskFormatter],
              ),
              SizedBox(
                height: 15,
              ),
              textformfield("Endereço", "Digite seu Endereço", false,
                  controller: _tEndereco,
                  validator: _validateEndereco,
                  keyboardType: TextInputType.text,
                  focusNode: _focusEndereco),
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
          content: new Text("Uma conta com esse cpf já está cadastrada."),
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

  void _onButtonClick(context) async {
    bool formOk = _formKey.currentState.validate();
    if (!formOk) {
      return;
    }

    String nome = _tNome.text;
    int cpf = int.parse(maskFormatter.getUnmaskedText());
    String endereco = _tEndereco.text;

    setState(() {
      _cadastroVerified = false;
    });

    var response =
        await http.post("https://ddc.community/michael/getConta.php?cpf=$cpf");

    if (response.statusCode == 200) {
      Map mapResponse = json.decode(response.body);
      List<dynamic> data = mapResponse["result"];

      if (data != null && data.length > 0) {
        _showDialog(context);
      } else if(conta != null) {
        conta.nome = nome;
        conta.cpf = cpf;
        conta.endereco = endereco;

        conta.imprimir();

        print("https://ddc.community/michael/addConta.php?cpf=${conta.cpf}&nome=${conta.nome}&idade=${conta.idade}&senha=${conta.senha}&email=${conta.email}&endereco=${conta.endereco}&nivel=${conta.nivel}");

        var response = await http.post("https://ddc.community/michael/addConta.php?cpf=${conta.cpf}&nome=${conta.nome}&idade=${conta.idade}&senha=${conta.senha}&email=${conta.email}&endereco=${conta.endereco}&nivel=${conta.nivel}");

        if (response.statusCode == 200) {
          Map mapResponse = json.decode(response.body);
          if (mapResponse["result"] == false) {
            _showDialog(context);
          } else {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          }

        }
      }
    }

    setState(() {
      _cadastroVerified = true;
    });
  }

  String _validateNome(String text) {
    if (text.isEmpty) {
      return "O nome deve ser preenchido";
    }
    return null;
  }

  String _validateCPF(String text) {
    if (text.isEmpty) {
      return "O CPF deve ser preenchida";
    }
    if (text.length < 11) {
      return "O CPF está inválido";
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
