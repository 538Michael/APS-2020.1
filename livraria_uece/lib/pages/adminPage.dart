import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/livro/autor.dart';
import 'package:livraria_uece/classes/livro/categoria.dart';
import 'package:livraria_uece/classes/livro/editora.dart';
import 'package:livraria_uece/classes/services/request.dart';
import 'package:livraria_uece/pages/cadastrarAutorPage.dart';
import 'package:livraria_uece/pages/cadastrarCategoriaPage.dart';
import 'package:livraria_uece/pages/cadastrarEditoraPage.dart';
import 'package:livraria_uece/pages/cadastrarLivroPage.dart';
import 'package:livraria_uece/pages/gerenciarAutoresPage.dart';
import 'package:livraria_uece/pages/gerenciarCategoriasPage.dart';
import 'package:livraria_uece/pages/gerenciarContasPage.dart';
import 'package:livraria_uece/pages/gerenciarEditorasPage.dart';
import 'package:livraria_uece/pages/gerenciarPedidosPage.dart';
import 'package:livraria_uece/pages/relatorioVendasPage.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
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
                    title: Text("Relatório de Vendas", style: style),
                    subtitle: Text("Mais Informações..."),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RelatorioVendasPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.apps),
                    title: Text("Cadastrar Livro", style: style),
                    subtitle: Text("Mais Informações..."),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CadastrarLivroPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.apps),
                    title: Text("Gerênciar Autores", style: style),
                    subtitle: Text("Mais Informações..."),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GerenciarAutoresPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.apps),
                    title: Text("Gerênciar Categorias", style: style),
                    subtitle: Text("Mais Informações..."),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GerenciarCategoriasPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.apps),
                    title: Text("Gerênciar Editoras", style: style),
                    subtitle: Text("Mais Informações..."),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GerenciarEditoras(),
                        ),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GerenciarPedidosPage()),
                      );
                    },
                  ),
                ],
              );
            }),
      ),
    );
  }
}
