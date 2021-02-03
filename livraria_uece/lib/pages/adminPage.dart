import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/livro/autor.dart';
import 'package:livraria_uece/classes/livro/categoria.dart';
import 'package:livraria_uece/classes/livro/editora.dart';
import 'package:livraria_uece/classes/services/request.dart';
import 'package:livraria_uece/pages/cadastrarAutor.dart';
import 'package:livraria_uece/pages/cadastrarCategoria.dart';
import 'package:livraria_uece/pages/cadastrarEditora.dart';
import 'package:livraria_uece/pages/cadastrarLivro.dart';
import 'package:livraria_uece/pages/gerenciarContas.dart';
import 'package:livraria_uece/pages/removerLivro.dart';

class AdminPage extends StatelessWidget {
  final _streamController = new StreamController();

  final request = new Request();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(context),
    );
  }

  void _loadData() async {
    await request.isReady;

    List<Map<String, dynamic>> recursos = new List();

    recursos.add(request.categorias);
    recursos.add(request.autores);
    recursos.add(request.editoras);

    _streamController.add(recursos);
  }

  TextStyle style = TextStyle(fontWeight: FontWeight.bold);

  _body(BuildContext context) {
    _loadData();
    return Scaffold(
      appBar: AppBar(
        title: Text("Administração"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(5),
        child: StreamBuilder(
            stream: _streamController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Erro ao acessar os dados."));
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              Map<String, Categoria> categorias = snapshot.data[0];
              Map<String, Autor> autores = snapshot.data[1];
              Map<String, Editora> editoras = snapshot.data[2];

              return ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.apps),
                    title: Text("Cadastrar Livro", style: style),
                    subtitle: Text("Mais Informações..."),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CadastrarLivroPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.apps),
                    title: Text("Cadastrar Autor", style: style),
                    subtitle: Text("Mais Informações..."),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CadastrarAutorPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.apps),
                    title: Text("Cadastrar Categoria", style: style),
                    subtitle: Text("Mais Informações..."),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CadastrarCategoriaPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.apps),
                    title: Text("Cadastrar Editora", style: style),
                    subtitle: Text("Mais Informações..."),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CadastrarEditoraPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.apps),
                    title: Text("Remover Livro", style: style),
                    subtitle: Text("Mais Informações..."),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                RemoverLivroPage(livros: request.livros)),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.apps),
                    title: Text("Gerenciar Contas", style: style),
                    subtitle: Text("Mais Informações..."),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GerenciarContasPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.apps),
                    title: Text("Gerenciar Pedidos", style: style),
                    subtitle: Text("Mais Informações..."),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {},
                  ),
                ],
              );
            }),
      ),
    );
  }
}
