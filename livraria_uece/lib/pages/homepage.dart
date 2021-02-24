import 'dart:async';

import 'package:badges/badges.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/livro/categoria.dart';
import 'package:livraria_uece/classes/services/request.dart';
import 'package:livraria_uece/pages/carrinhoCompras.dart';
import 'package:livraria_uece/pages/dadosPessoaisPage.dart';
import 'package:livraria_uece/pages/loginPage.dart';
import 'package:livraria_uece/pages/notificacoesPage.dart';

import 'acompanharPedidosPage.dart';
import 'adminPage.dart';
import 'avaliarPedidosPage.dart';
import 'cadastroPage.dart';
import 'detalhesLivroPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
            icon: ValueListenableBuilder(
              valueListenable: request.updating,
              builder: (context, snapshot, widget) {
                int quantidade = 0;

                if (!request.updating.value) {
                  quantidade = request.carrinho.carrinho.length;
                }
                return Badge(
                  badgeContent: Text(quantidade.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                  badgeColor: Colors.black,
                  child: Icon(
                    Icons.shopping_cart,
                    size: 30.0,
                  ),
                );
              },
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CarrinhoComprasPage()),
              );
              setState(() {});
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

  final request = new Request(loadBooks: true, loadShoppingCart: true);

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
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4.0)),
                            gapPadding: 0.0),
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Pesquisar",
                        labelStyle: TextStyle(
                            backgroundColor: Colors.white,
                            decoration: TextDecoration.overline,
                            fontSize: 18),
                        hintText: "Pesquisar...",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _controller.clear();
                              request.filterName = null;
                              request.getLivrosFiltered();
                            });
                            FocusScope.of(context).unfocus();
                          },
                          icon: Icon(Icons.clear,
                              color: Theme.of(context).primaryColor),
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
                        searchBoxDecoration: InputDecoration(
                          hintText: "Pesquisar...",
                          border: OutlineInputBorder(
                              borderSide: const BorderSide(),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4.0)),
                              gapPadding: 0.0),
                        ),
                        dropdownSearchDecoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                          filled: true,
                          labelStyle: TextStyle(
                              backgroundColor: Colors.white,
                              decoration: TextDecoration.overline,
                              fontSize: 18),
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderSide: const BorderSide(),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4.0)),
                              gapPadding: 0.0),
                        ),
                        selectedItem: request.filterCategory ??
                            request.categorias["Todas"],
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
              Visibility(
                visible: request.livros.isNotEmpty,
                replacement: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    color: Theme.of(context).backgroundColor,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Nenhum livro encontrado",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                ),
                child: SliverPadding(
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
                        Iterable<String> urlCapa = request
                            .livros[livrosLista[index]].url_capa
                            .where((element) => element != null);
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
                                          child: (urlCapa.length == 0)
                                              ? Image.network(
                                                  'https://livrariacultura.vteximg.com.br/arquivos/ids/19870049/2112276853.png',
                                                  fit: BoxFit.fill,
                                                )
                                              : CarouselSlider(
                                                  options: CarouselOptions(
                                                      disableCenter: true,
                                                      autoPlay: true,
                                                      viewportFraction: 1.0,
                                                      enableInfiniteScroll:
                                                          urlCapa.length > 1),
                                                  items: urlCapa
                                                      .map(
                                                        (item) => Container(
                                                          child: Image.network(
                                                            item.toString(),
                                                            fit: BoxFit.fill,
                                                          ),
                                                          color: Colors.green,
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
                                        ),
                                      ),
                                    ),
                                    Divider(),
                                    Container(
                                      height: 45,
                                      child: Center(
                                        child: Text(
                                          request.livros[livrosLista[index]]
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
                                    ),
                                    Container(
                                      height: 35,
                                      child: Center(
                                        child: Text(
                                          (request.livros[livrosLista[index]]
                                                          .autores ==
                                                      null ||
                                                  request
                                                          .livros[livrosLista[
                                                              index]]
                                                          .autores
                                                          .length ==
                                                      0)
                                              ? "Nenhum"
                                              : (request
                                                          .livros[request
                                                              .livros.keys
                                                              .toList()[index]]
                                                          .autores
                                                          .length ==
                                                      1)
                                                  ? request
                                                      .livros[request
                                                          .livros.keys
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
                                              request
                                                  .livros[request.livros.keys
                                                      .toList()[index]]
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
                                            color:
                                                Theme.of(context).primaryColor,
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
                                        livro: request.livros[request
                                            .livros.keys
                                            .toList()[index]])),
                              );
                              setState(() {});
                            });
                      },
                      childCount: request.livros.length,
                    ),
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
                        child: Expanded(
                          child: Text(
                            "Entre ou Registre-se",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
                      await Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                      setState(() {});
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
                    subtitle: Text("Avaliar pedidos entregues..."),
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
                    title: Text("Notificações"),
                    subtitle: Text("Mais informações..."),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificacoesPage(),
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
                      BotToast.showLoading(
                        clickClose: false,
                        allowClick: false,
                        crossPage: false,
                        backButtonBehavior: BackButtonBehavior.none,
                        animationDuration: Duration(milliseconds: 200),
                        animationReverseDuration: Duration(milliseconds: 200),
                        backgroundColor: Color(0x42000000),
                      );

                      await FirebaseAuth.instance.signOut();

                      BotToast.closeAllLoading();

                      BotToast.showNotification(
                        leading: (cancel) => SizedBox.fromSize(
                            size: const Size(40, 40),
                            child: IconButton(
                              icon: Icon(Icons.assignment_turned_in,
                                  color: Colors.green),
                              onPressed: cancel,
                            )),
                        title: (_) => Text('Deslogado com sucesso!'),
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
