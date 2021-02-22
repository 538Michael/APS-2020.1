import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:livraria_uece/classes/carrinhodecompra/carrinhodecompra.dart';
import 'package:livraria_uece/classes/livro/livro.dart';
import 'package:livraria_uece/classes/services/request.dart';
import 'package:livraria_uece/extra/showAlertDialog.dart';

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
  CollectionReference shoppingCart =
      FirebaseFirestore.instance.collection('shopping_cart');

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  bool _verified = true;

  void deletarLivro() async {
    setState(() {
      _verified = false;
    });

    BotToast.showLoading(
      clickClose: false,
      allowClick: false,
      crossPage: false,
      backButtonBehavior: BackButtonBehavior.none,
      animationDuration: Duration(milliseconds: 200),
      animationReverseDuration: Duration(milliseconds: 200),
      backgroundColor: Color(0x42000000),
    );

    if (_livro.url_capa != null && _livro.url_capa.isNotEmpty) {
      List<Future> futures = new List();
      if (_livro.url_capa[0] != null) {
        futures.add(firebase_storage.FirebaseStorage.instance
            .ref()
            .child('covers')
            .child('${_livro.id}-1')
            .delete()
            .then((value) {
          print("Cover Deleted");
        }).catchError((error) => print("Failed to delete cover1: $error")));
      }
      if (_livro.url_capa[1] != null) {
        futures.add(firebase_storage.FirebaseStorage.instance
            .ref()
            .child('covers')
            .child('${_livro.id}-2')
            .delete()
            .then((value) {
          print("Cover 2 Deleted");
        }).catchError((error) => print("Failed to delete cover2: $error")));
      }
      if (_livro.url_capa[2] != null) {
        futures.add(firebase_storage.FirebaseStorage.instance
            .ref()
            .child('covers')
            .child('${_livro.id}-3')
            .delete()
            .then((value) {
          print("Cover 3 Deleted");
        }).catchError((error) => print("Failed to delete cover3: $error")));
      }
      await Future.wait(futures);
    }

    //Deleta dos Carrinhos
    List<String> queryIds = new List();
    request.removeShoppingCart(_livro, removeCompleto: true);
    await shoppingCart.get().then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        if (element.data()['items'].containsKey(_livro.id))
          queryIds.add(element.id);
      });
    }).catchError((error) => print("Failed to get queries: $error"));

    queryIds.forEach((element) {
      shoppingCart
          .doc(element)
          .update({'items.' + _livro.id: FieldValue.delete()})
          .then((value) => print('Book removed successfully from ' + element))
          .catchError((error) => print('Failed to remove book from' + element));
    });
    //

    await books.doc(_livro.id).delete().then((value) {
      print("Book Deleted");

      BotToast.closeAllLoading();

      BotToast.showNotification(
        leading: (cancel) => SizedBox.fromSize(
            size: const Size(40, 40),
            child: IconButton(
              icon: Icon(Icons.assignment_turned_in, color: Colors.green),
              onPressed: cancel,
            )),
        title: (_) => Text('Livro deletado com sucesso!'),
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

      if (!mounted) return;

      setState(() {
        _verified = true;
      });

      Navigator.of(context).pop();
    }).catchError(
      (error) {
        print("Failed to delete book: $error");

        BotToast.closeAllLoading();

        BotToast.showNotification(
          leading: (cancel) => SizedBox.fromSize(
              size: const Size(40, 40),
              child: IconButton(
                icon: Icon(Icons.warning_rounded, color: Colors.red),
                onPressed: cancel,
              )),
          title: (_) => Text('Ocorreu um erro ao deletar livro!'),
          subtitle: (_) => Text('$error'),
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

        if (!mounted) return;

        setState(() {
          _verified = true;
        });
      },
    );
  }

  void _showDialog() {
    showAlertDialog(
      BackButtonBehavior.none,
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      title: 'Remover Livro',
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Tem certeza que deseja remover esse livro?'),
          ],
        ),
      ),
      confirm: deletarLivro,
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
          Iterable<String> urlCapa =
              _livro.url_capa.where((element) => element != null);
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
                                child: FractionallySizedBox(
                                  alignment: Alignment.topCenter,
                                  widthFactor: 1,
                                  heightFactor: 1,
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
                              Visibility(
                                visible: auth.currentUser != null &&
                                    data['nivel'] == 1,
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: InkWell(
                                    child: Container(
                                      margin: EdgeInsets.all(7),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        border: Border.all(
                                            width: 1.0, color: Colors.black),
                                      ),
                                      child: Icon(
                                        Icons.delete_forever,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onTap: () {
                                      _showDialog();
                                    },
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
                              "Editora: ${(livro.editora != null) ? livro.editora.editora : "Nenhuma"}",
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
                              "Autores: ${(livro.autores != null && livro.autores.isNotEmpty) ? _getAutors() : "Nenhum"}",
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
        child: InkWell(
          splashColor: Colors.blueGrey,
          child: Container(
            alignment: Alignment.center,
            child: Text("Adicionar ao Carrinho",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          onTap: () async {
            setState(() {
              _verified = false;
            });

            BotToast.showLoading(
              clickClose: false,
              allowClick: false,
              crossPage: false,
              backButtonBehavior: BackButtonBehavior.none,
              animationDuration: Duration(milliseconds: 200),
              animationReverseDuration: Duration(milliseconds: 200),
              backgroundColor: Color(0x42000000),
            );

            await request.addShoppingCart(livro);

            BotToast.closeAllLoading();

            BotToast.showNotification(
              leading: (cancel) => SizedBox.fromSize(
                  size: const Size(40, 40),
                  child: IconButton(
                    icon: Icon(Icons.assignment_turned_in, color: Colors.green),
                    onPressed: cancel,
                  )),
              title: (_) => Text('Livro adicionado ao carrinho com sucesso!'),
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

            if (!mounted) return;

            setState(() {
              _verified = true;
            });

            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
