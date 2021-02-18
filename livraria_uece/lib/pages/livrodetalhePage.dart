import 'dart:async';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:livraria_uece/classes/carrinhodecompra/carrinhodecompra.dart';
import 'package:livraria_uece/classes/livro/livro.dart';
import 'package:livraria_uece/classes/services/request.dart';
import 'package:livraria_uece/pages/shoppingCartPage.dart';

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

  Livro get livro => _livro;

  final _streamController = new StreamController();

  Request request = new Request();

  set livro(Livro value) {
    _livro = value;
  }

  _LivroDetalheState({Livro livro}) {
    _livro = livro;
  }

  int ratingCount;
  double rating;

  CarrinhoDeCompra carrinho = new CarrinhoDeCompra();

  FirebaseAuth auth = FirebaseAuth.instance;

  CollectionReference books = FirebaseFirestore.instance.collection('books');

  bool _verified = true;

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return StatefulBuilder(
          builder: (context, setState) {
            return Visibility(
              visible: _verified,
              replacement: Center(child: CircularProgressIndicator()),
              child: AlertDialog(
                title: new Text("Remover livro"),
                content: new Text("Tem certeza que deseja remover esse livro?"),
                actions: <Widget>[
                  // define os botões na base do dialogo
                  new FlatButton(
                    child: new Text("Cancelar"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  new FlatButton(
                    child: new Text("Confirmar"),
                    onPressed: () async {
                      setState(() {
                        _verified = false;
                      });
                      await books
                          .doc(_livro.id)
                          .delete()
                          .then((value) => print("Book Deleted"))
                          .catchError(
                              (error) => print("Failed to book user: $error"));
                      setState(() {
                        _verified = true;
                      });
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _loadData() async {
    if (auth.currentUser != null) {
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      _streamController.add(await users.doc(auth.currentUser.uid).get());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes do Livro"),
        actions: <Widget>[
          IconButton(
            icon: Badge(
              badgeContent: Text(request.carrinho.carrinho.length.toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
              badgeColor: Colors.black,
              child: Icon(
                Icons.shopping_cart,
                size: 30.0,
              ),
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
      body: _body(context),
      bottomNavigationBar: _bottomNavigationBar(context),
    );
  }

  _getAutors() {
    List<String> autores = new List();
    _livro.autores.forEach((element) => autores.add(element.autor));
    return autores.join(', ');
  }

  _getRatings() async {
    ratingCount = 0;
    rating = 0.0;
    QuerySnapshot ratings = await FirebaseFirestore.instance
        .collection('ratings')
        .where('book_id', isEqualTo: _livro.id)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        ratingCount++;
        rating += element.data()['rating'];
      });
      return;
    });
    if (rating != 0) rating /= ratingCount;
  }

  _body(BuildContext context) {
    _loadData();
    _getRatings();
    return Container(
      color: Theme.of(context).backgroundColor,
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
          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                automaticallyImplyLeading: false,
                centerTitle: true,
                floating: false,
                pinned: false,
                title: Text(
                  livro.titulo,
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
                    margin: EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 350,
                          width: 240,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 1.0, color: Colors.black),
                          ),
                          child: Stack(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Image.network(
                                    livro.url_capa ??
                                        'https://livrariacultura.vteximg.com.br/arquivos/ids/19870049/2112276853.png',
                                    fit: BoxFit.fill),
                              ),
                              Visibility(
                                visible: auth.currentUser != null &&
                                    data['nivel'] == 1,
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    margin: EdgeInsets.all(7),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                          width: 1.0, color: Colors.black),
                                    ),
                                    child: InkWell(
                                      child: Icon(
                                        Icons.delete_forever,
                                        color: Colors.white,
                                      ),
                                      onTap: () {
                                        _showDialog();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    color: Colors.pink,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Text(
                                "(" + ratingCount.toString() + ") Avaliações: ",
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
                              RatingBar.builder(
                                initialRating: rating,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                ignoreGestures: true,
                                itemSize: 30,
                                itemPadding:
                                    EdgeInsets.symmetric(horizontal: 2.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.white,
                                ),
                                onRatingUpdate: (rating) {},
                              ),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.all(10.0),
                          child: Text(
                            "Preço: R\$ " + livro.preco.toStringAsFixed(2),
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
                        Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.all(10.0),
                            child: Text(
                              "Editora: " + livro.editora.editora,
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
                            )),
                        Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.all(10.0),
                            child: Text(
                              "Autores: " + _getAutors(),
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
                            )),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  _bottomNavigationBar(BuildContext context) {
    return Container(
      height: 60,
      child: Material(
          color: Colors.orangeAccent,
          child: Visibility(
            visible: _verified,
            replacement: Center(child: CircularProgressIndicator()),
            child: InkWell(
                splashColor: Colors.blueGrey,
                child: Container(
                  alignment: Alignment.center,
                  child: Text("Adicionar ao Carrinho",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                onTap: () async {
                  setState(() {
                    _verified = false;
                  });
                  await request.addShoppingCart(livro);
                  setState(() {
                    _verified = true;
                  });
                  Navigator.of(context).pop();
                }),
          )),
    );
  }
}
