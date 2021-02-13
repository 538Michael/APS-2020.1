import 'dart:async';

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

import 'acompanharPedidosPage.dart';
import 'adminPage.dart';
import 'avaliarPedidosPage.dart';
import 'cadastroPage.dart';
import 'livrodetalhePage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CarrinhoDeCompra carrinho = new CarrinhoDeCompra();

  CollectionReference books = FirebaseFirestore.instance.collection('books');

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
            //_updateRequest();
          }
        });
      }),
      body: _body(context),
      //drawer: DrawerListAluno(/*user: user*/),
    );
  }

  final _streamController = new StreamController();
  final request = new Request(loadBooks: true);

  Map<int, bool> visivel = new Map();

  var _controller = TextEditingController();

  _body(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: ValueListenableBuilder(
        valueListenable: request.isReady,
        builder: (context, snapshot, widget) {
          if (!request.isReady.value) {
            return Center(child: CircularProgressIndicator());
          }

          List<String> livrosLista = request.livros.keys.toList();

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
                        labelText: "Buscar...",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _controller.clear();
                              request.filterName = null;
                              request.getLivrosFiltered();
                            });
                          },
                          icon: Icon(Icons.clear),
                        ),
                      ),
                      onSubmitted: (String data) {
                        setState(() {
                          request.filterName = data;
                          request.getLivrosFiltered();
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
                        selectedItem: request.filterCategory ?? request.categorias["Todas"],
                        mode: Mode.DIALOG,
                        items: request.categorias.values.toList(),
                        itemAsString: (Categoria u) => u.categoria,
                        onChanged: (Categoria data) {
                          request.filterCategory = data;
                          request.getLivrosFiltered();
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
                                          request.livros[livrosLista[index]].url_capa ??
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
                                        request.livros[livrosLista[index]].titulo,
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
                                        (request.livros[livrosLista[index]].autores ==
                                                    null ||
                                            request.livros[livrosLista[index]]
                                                        .autores
                                                        .length ==
                                                    0)
                                            ? "Nenhum"
                                            : (request.livros[request.livros.keys
                                                            .toList()[index]]
                                                        .autores
                                                        .length ==
                                                    1)
                                                ? request.livros[request.livros.keys
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
                                            request.livros[request.livros.keys.toList()[index]]
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
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LivroDetalhePage(
                                      livro:
                                      request.livros[request.livros.keys.toList()[index]])),
                            );
                          });
                    },
                    childCount: request.livros.length,
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
                    title: Text("Meus pedidos"),
                    subtitle: Text("Acompanhar pedidos..."),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AcompanharPedidoPage(),
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
                    title: Text("Avaliar Pedidos"),
                    subtitle: Text("avaliar pedidos entregues..."),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AvaliarPedidoPage(),
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
