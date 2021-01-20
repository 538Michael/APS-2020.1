import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/livro/livro.dart';

class LivroDetalhePage extends StatefulWidget {
  Livro _livro;

  LivroDetalhePage({Livro livro}) {
    _livro = livro;
  }

  @override
  _LivroDetalheState createState() => _LivroDetalheState(livro: _livro);
}

class _LivroDetalheState extends State<LivroDetalhePage> {
  final _formKey = GlobalKey<FormState>();
  Livro _livro;

  _LivroDetalheState({Livro livro}) {
    _livro = livro;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  _body() {
    return Scaffold(
        appBar: AppBar(
          title: Text("Detalhes do Livro"),
          centerTitle: true,
        ),
        body: Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.only(top: 20, left: 40, right: 40),
            )

        )
    );
  }
}