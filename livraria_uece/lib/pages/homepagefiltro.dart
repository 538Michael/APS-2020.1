import 'dart:async';

import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/livro/autor.dart';
import 'package:livraria_uece/classes/livro/categoria.dart';
import 'package:livraria_uece/classes/livro/editora.dart';
import 'package:livraria_uece/classes/livro/livro.dart';
import 'package:livraria_uece/classes/services/request.dart';
import 'package:livraria_uece/pages/livrodetalhePage.dart';
import 'package:livraria_uece/pages/loginPage.dart';
import 'package:livraria_uece/pages/shoppingCartPage.dart';

import 'cadastroPage.dart';

class HomePageFiltro extends StatefulWidget {

  String _categoria;
  String _autor;
  String _editora;

  HomePageFiltro({String categoria, String autor, String editora}) {
    _categoria = categoria;
    _autor = autor;
    _editora = editora;
  }

  @override
  _HomePageFiltroState createState() => _HomePageFiltroState(_categoria);
}

class _HomePageFiltroState extends State<HomePageFiltro> {
  String categoria;

  _HomePageFiltroState(this.categoria);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Página Inicial"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.account_box_rounded, size: 30.0),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.shopping_cart,
              size: 30.0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShoppingCartPage()),
              );
            },
          ),
        ],
        centerTitle: true,
      ),
      drawer: DrawerTest(),
      body: _body(context),
      //drawer: DrawerListAluno(/*user: user*/),
    );
  }

  final _streamController =  new StreamController();
  final request = new Request();

  _setStreamController(String categoria) async {
    await request.isReady;

    // Map<int,Livro> livros = request.livros;
    Map<int,Livro> livros = new Map();
    request.livros.forEach((key, livro) {
      if(livro.categorias.firstWhere((element) => element.categoria == categoria, orElse: () => null) != null) {
        livros[key] = livro;
      }
    });

    print(livros.values);

    _streamController.add(livros);
  }

  _body(BuildContext context) {
    _setStreamController(categoria);

    return Container(
      color: Theme.of(context).backgroundColor,
      child: StreamBuilder(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Erro ao acessar os dados."));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          Map<int, Livro> livros = snapshot.data;

          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                automaticallyImplyLeading: false,
                centerTitle: true,
                floating: false,
                pinned: true,
                title: Text(
                  "Livros",
                  style: TextStyle(
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(10.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 186.0,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                    childAspectRatio: 0.55,
                  ),

                  delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return Visibility(
                          child: InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                  Border.all(width: 1.0, color: Colors.black),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 5, right: 5, left: 5, bottom: 10),
                                  child: Column(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          child: FractionallySizedBox(
                                            alignment: Alignment.topCenter,
                                            widthFactor: 1,
                                            heightFactor: 1,
                                            child: Image.network(
                                              livros[livros.keys.toList()[index]]
                                                  .url_capa,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Divider(),
                                      Container(
                                        height: 40,
                                        child: Text(
                                          livros[livros.keys.toList()[index]]
                                              .titulo,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Raleway',
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 27,
                                        child: Text(
                                          (livros[livros.keys.toList()[index]]
                                              .autores ==
                                              null
                                              ? "Nenhum"
                                              : (livros[livros.keys.toList()[index]]
                                              .autores
                                              .length ==
                                              1)
                                              ? livros[livros.keys
                                              .toList()[index]]
                                              .autores
                                              .first
                                              .autor
                                              : "Varios Autores"),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Raleway',
                                            fontSize: 12,
                                            letterSpacing: 0,
                                            color: Colors.black,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LivroDetalhePage(
                                          livro:
                                          livros[livros.keys.toList()[index]])),
                                );
                              }
                          )
                      );
                    },
                    childCount: livros.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DrawerTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
          child: ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                color: Theme.of(context).primaryColor,
                child: Row(
                  children: [
                    Icon(
                      Icons.account_circle_rounded,
                      size: 100,
                      color: Colors.white,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          color: Colors.white10,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
                            },
                            child: Column(
                              children: [
                                Row(
                                  children: <Widget>[
                                    Text(
                                      "Login",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    VerticalDivider(),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Colors.white,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          padding: EdgeInsets.all(5),
                          color: Colors.white10,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CadastroPage()),
                              );
                            },
                            child: Column(
                              children: [
                                Row(
                                  children: <Widget>[
                                    Text(
                                      "Cadastre-se",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    VerticalDivider(),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Colors.white,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              /*UserAccountsDrawerHeader(
            accountName: Text(user.nome),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage("assets/images/avatar_icon.png"),
            ),
          ),*/
              ListTile(
                leading: Icon(Icons.apps),
                title: Text("Editar dados pessoais"),
                subtitle: Text("Mais Informações..."),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {},
              ),
            ],
          )),
    );
  }
}
