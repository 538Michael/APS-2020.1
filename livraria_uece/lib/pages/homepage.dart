import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/carrinhodecompra/carrinhodecompra.dart';
import 'package:livraria_uece/classes/livro/autor.dart';
import 'package:livraria_uece/classes/livro/categoria.dart';
import 'package:livraria_uece/classes/livro/editora.dart';
import 'package:livraria_uece/classes/livro/livro.dart';
import 'package:livraria_uece/classes/services/request.dart';
import 'package:livraria_uece/pages/dadosPessoaisPage.dart';
import 'package:livraria_uece/pages/loginPage.dart';
import 'package:livraria_uece/pages/shoppingCartPage.dart';

import 'adminPage.dart';
import 'cadastroPage.dart';
import 'livrodetalhePage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CarrinhoDeCompra carrinho = new CarrinhoDeCompra();

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
      drawer: DrawerTest(callback: (isOpen) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isOpen == false) {
            request.init();
            _streamController.sink;
          }
        });
      }),
      body: _body(context),
      //drawer: DrawerListAluno(/*user: user*/),
    );
  }

  final _streamController = new StreamController();
  final request = new Request();

  _setStreamController() async {
    await request.isReady;

    List<Map<String, dynamic>> recursos = new List();
    recursos.add(request.categorias);
    recursos.add(request.autores);
    recursos.add(request.editoras);
    recursos.add(request.getLivrosFiltered(_filtroLivro, _selectedCategoria));

    _streamController.add(recursos);
  }

  Map<int, bool> visivel = new Map();

  Categoria _selectedCategoria;
  var _controller = TextEditingController();
  String _filtroLivro;

  _body(BuildContext context) {
    _setStreamController();
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

          Map<String, Categoria> categorias = snapshot.data[0];
          Map<String, Autor> autores = snapshot.data[1];
          Map<String, Editora> editoras = snapshot.data[2];
          Map<String, Livro> livros = snapshot.data[3];

          List<String> livrosLista = livros.keys.toList();

          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                automaticallyImplyLeading: false,
                centerTitle: true,
                floating: false,
                pinned: false,
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
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.search_rounded),
                    onPressed: () {
                      //TODO
                    },
                  ),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    margin: EdgeInsets.all(10.0),
                    height: 60.0,
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Busca",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _controller.clear();
                              _filtroLivro = null;
                              _streamController.sink;
                            });
                          },
                          icon: Icon(Icons.clear),
                        ),
                      ),
                      onSubmitted: (String data) {
                        setState(() {
                          _filtroLivro = data;
                          _streamController.sink;
                        });
                      },
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.all(10.0),
                      height: 60.0,
                      child: DropdownSearch<Categoria>(
                        label: "Categoria",
                        hint: "Escolha uma categoria",
                        selectedItem: categorias["Todas"],
                        mode: Mode.DIALOG,
                        items: categorias.values.toList(),
                        itemAsString: (Categoria u) => u.categoria,
                        onChanged: (Categoria data) {
                          setState(() {
                            _selectedCategoria = data;
                            _streamController.sink;
                          });
                        },
                        showSearchBox: true,
                      )),
                ]),
              ),
              SliverPadding(
                padding: EdgeInsets.all(10.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 186.0,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                    childAspectRatio: 0.5,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return InkWell(
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
                                        heightFactor: 1.08,
                                        child: Image.network(
                                          livros[livrosLista[index]].url_capa ??
                                              'https://livrariacultura.vteximg.com.br/arquivos/ids/19870049/2112276853.png',
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Divider(),
                                  Container(
                                    height: 45,
                                    child: Center(
                                      child: Text(
                                        livros[livrosLista[index]].titulo,
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
                                  ),
                                  Container(
                                    height: 35,
                                    child: Center(
                                      child: Text(
                                        (livros[livrosLista[index]].autores ==
                                                    null ||
                                                livros[livrosLista[index]]
                                                        .autores
                                                        .length ==
                                                    0)
                                            ? "Nenhum"
                                            : (livros[livros.keys
                                                            .toList()[index]]
                                                        .autores
                                                        .length ==
                                                    1)
                                                ? livros[livros.keys
                                                        .toList()[index]]
                                                    .autores
                                                    .first
                                                    .autor
                                                : "Varios Autores",
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
                                    ),
                                  ),
                                  Container(
                                    height: 30,
                                    child: Center(
                                      child: Text(
                                        "R\$ " +
                                            livros[livros.keys.toList()[index]]
                                                .preco
                                                .toStringAsFixed(2),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Raleway',
                                          fontSize: 20,
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
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
                          });
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

class DrawerTest extends StatefulWidget {
  DrawerTest({
    Key key,
    this.callback,
  }) : super(key: key);

  @override
  _DrawerTestState createState() => _DrawerTestState();

  final DrawerCallback callback;
}

class _DrawerTestState extends State<DrawerTest> {
  final _streamController = new StreamController();

  FirebaseAuth auth = FirebaseAuth.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    if (widget.callback != null) {
      widget.callback(true);
    }

    super.initState();
  }

  @override
  void dispose() {
    if (widget.callback != null) {
      widget.callback(false);
    }
    super.dispose();
  }

  void _loadData() async {
    if (auth.currentUser != null) {
      CollectionReference users = firestore.collection('users');

      _streamController.add(await users.doc(auth.currentUser.uid).get());
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadData();
    return SafeArea(
      child: Drawer(
        child: StreamBuilder(
          stream: _streamController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Erro ao acessar os dados."));
            }
            if (!snapshot.hasData && auth.currentUser != null) {
              return Center(child: CircularProgressIndicator());
            }
            Map<String, dynamic> data = new Map();
            if (snapshot.hasData) {
              data = snapshot.data.data();
            }

            return ListView(
              children: <Widget>[
                Container(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                  color: Theme.of(context).primaryColor,
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_circle_rounded,
                        size: 100,
                        color: Colors.white,
                      ),
                      Visibility(
                        visible: auth.currentUser == null,
                        child: Text(
                          "Entre ou Registre-se",
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
                        replacement: Expanded(
                          child: Text(
                            data['nome'] ?? "",
                            maxLines: 3,
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
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: auth.currentUser == null,
                  child: ListTile(
                    leading: Icon(Icons.apps),
                    title: Text("Entrar"),
                    subtitle: Text("Mais Informações..."),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () async {
                      if (await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      )) {
                        setState(() {});
                      }
                    },
                  ),
                ),
                Visibility(
                  visible: auth.currentUser == null,
                  child: ListTile(
                    leading: Icon(Icons.apps),
                    title: Text("Cadastrar"),
                    subtitle: Text("Mais Informações..."),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CadastroPage()),
                      );
                    },
                  ),
                ),
                Visibility(
                  visible: auth.currentUser != null && data['nivel'] == 1,
                  child: ListTile(
                    leading: Icon(Icons.apps),
                    title: Text("Administrar"),
                    subtitle: Text("Mais Informações..."),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminPage(),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                ),
                Visibility(
                  visible: auth.currentUser != null,
                  child: ListTile(
                    leading: Icon(Icons.apps),
                    title: Text("Editar dados pessoais"),
                    subtitle: Text("Mais Informações..."),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DadosPessoaisPage(),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                ),
                Visibility(
                  visible: auth.currentUser != null,
                  child: ListTile(
                    leading: Icon(Icons.apps),
                    title: Text("Sair"),
                    subtitle: Text("Sair da conta"),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      setState(() {});
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
