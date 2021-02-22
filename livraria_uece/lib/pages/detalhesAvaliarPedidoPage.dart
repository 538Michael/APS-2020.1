import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:livraria_uece/classes/carrinhodecompra/itemdeavaliacao.dart';
import 'package:livraria_uece/classes/livro/livro.dart';
import 'package:livraria_uece/classes/pedido/pedido.dart';

class DetalhesAvaliarPedidoPage extends StatefulWidget {
  Pedido _pedido;

  DetalhesAvaliarPedidoPage(this._pedido);

  @override
  _DetalhesAvaliarPedidoState createState() =>
      _DetalhesAvaliarPedidoState(_pedido);
}

class _DetalhesAvaliarPedidoState extends State<DetalhesAvaliarPedidoPage> {
  Pedido _pedido;
  final _streamController = new StreamController();

  _DetalhesAvaliarPedidoState(this._pedido);

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalhes do Pedido")),
      body: _body(context),
      bottomNavigationBar: _bottomNavigationBar(context),
    );
  }

  _getLivros() async {
    Map<String, double> avaliacoes = new Map();
    QuerySnapshot ratingQuery = await FirebaseFirestore.instance
        .collection('ratings')
        .where('order_id', isEqualTo: _pedido.ID)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) =>
          avaliacoes[element.data()['book_id']] = element.data()['rating']);
      return;
    });

    List<ItemDeAvaliacao> livros = new List();
    QuerySnapshot bookQuery = await FirebaseFirestore.instance
        .collection('books')
        .where(FieldPath.documentId, whereIn: _pedido.items.keys.toList())
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        livros.add(ItemDeAvaliacao(
          Livro(
            id: element.id,
            titulo: element.data()['name'],
            url_capa: List<String>.from(element.data()['cover_url']),
            preco: _pedido.items[element.id][1],
          ),
          _pedido.items[element.id][0],
          avaliacao: avaliacoes.containsKey(element.id)
              ? avaliacoes[element.id]
              : null,
        ));
      });
      return;
    });
    _streamController.add(livros);
  }

  _body(BuildContext context) {
    _getLivros();
    return StreamBuilder(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Erro ao acessar os dados."));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<ItemDeAvaliacao> livros = snapshot.data;
          return Container(
            color: Theme.of(context).backgroundColor,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      Iterable<String> coverUrl = livros[index].livro.url_capa.where((element) => element != null);
                      String urlCapa = 'https://livrariacultura.vteximg.com.br/arquivos/ids/19870049/2112276853.png';
                      if(coverUrl.isNotEmpty) urlCapa = coverUrl.first;
                      return Container(
                        margin: EdgeInsets.all(5.0),
                        color: Colors.white,
                        padding: const EdgeInsets.all(10.0),
                        height: 175,
                        child: Column(
                          children: [
                            Container(
                              height: 120,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Image.network(
                                    urlCapa,
                                    fit: BoxFit.fitHeight,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 15.0, right: 10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          livros[index].livro.titulo,
                                          textAlign: TextAlign.left,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Raleway',
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          "Quantidade: " +
                                              livros[index]
                                                  .quantidade
                                                  .toString(),
                                          textAlign: TextAlign.left,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Raleway',
                                            fontSize: 20,
                                            letterSpacing: 0,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                              margin: EdgeInsets.only(top: 5.0),
                                              child: Text(
                                                "R\$ " +
                                                    livros[index]
                                                        .livro
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
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(top: 5.0),
                                child: Material(
                                  color: Colors.orangeAccent,
                                  child: Visibility(
                                    visible: livros[index].avaliacao == null,
                                    //TODO se não tiver avaliado ainda
                                    child: InkWell(
                                        splashColor: Colors.blueGrey,
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Text("Avalie seu pedido",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20)),
                                        ),
                                        onTap: () {
                                          _AlertDialog(
                                              context, livros[index].livro);
                                        }),
                                    replacement: Container(
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text("Sua avaliação: ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20)),
                                          RatingBar(
                                            initialRating:
                                                livros[index].avaliacao ?? 0.0,
                                            ignoreGestures: true,
                                            direction: Axis.horizontal,
                                            allowHalfRating: false,
                                            itemCount: 5,
                                            itemSize: 28,
                                            ratingWidget: RatingWidget(
                                              full: Icon(Icons.star),
                                              empty: Icon(Icons.star_border),
                                            ),
                                            itemPadding: EdgeInsets.symmetric(
                                                horizontal: 2.0),
                                            onRatingUpdate: (rating) {},
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: livros.length,
                  ),
                ),
              ],
            ),
          );
        });
  }

  _bottomNavigationBar(BuildContext context) {
    return Container(
      height: 130,
      child: Column(
        children: <Widget>[
          Container(
            height: 40,
            margin: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Subtotal:",
                    maxLines: 1,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text("R\$ " + _pedido.preco.toStringAsFixed(2),
                    maxLines: 1,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          Container(
            height: 40,
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Desconto:",
                    maxLines: 1,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Visibility(
                  visible: _pedido.pagamento == 1,
                  child: Text("0%",
                      maxLines: 1,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  replacement: Text("10%",
                      maxLines: 1,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            margin: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total:",
                    maxLines: 1,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Visibility(
                  visible: _pedido.pagamento == 1,
                  child: Text("R\$ " + _pedido.preco.toStringAsFixed(2),
                      maxLines: 1,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  replacement: Text("R\$ " + (_pedido.preco - _pedido.desconto).toStringAsFixed(2),
                      maxLines: 1,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _AlertDialog(BuildContext context, Livro livro) {
    double rating = 0.0;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RatingBar(
                minRating: 1,
                maxRating: 5,
                initialRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                glow: false,
                ratingWidget: RatingWidget(
                  full: Icon(Icons.star, color: Theme.of(context).primaryColor),
                  empty: Icon(Icons.star_border,
                      color: Theme.of(context).primaryColor),
                ),
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                onRatingUpdate: (value) {
                  rating = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Confirmar"),
              onPressed: () async {
                BotToast.showLoading(
                  clickClose: false,
                  allowClick: false,
                  crossPage: false,
                  backButtonBehavior: BackButtonBehavior.none,
                  animationDuration: Duration(milliseconds: 200),
                  animationReverseDuration: Duration(milliseconds: 200),
                  backgroundColor: Color(0x42000000),
                );

                CollectionReference ratings = firestore.collection('ratings');

                await ratings.add({
                  'book_id': livro.id,
                  'order_id': _pedido.ID,
                  'user_id': FirebaseAuth.instance.currentUser.uid,
                  'rating': rating,
                }).then((value) {
                  print("Rating Added");

                  BotToast.closeAllLoading();

                  BotToast.showNotification(
                    leading: (cancel) => SizedBox.fromSize(
                        size: const Size(40, 40),
                        child: IconButton(
                          icon: Icon(Icons.assignment_turned_in,
                              color: Colors.green),
                          onPressed: cancel,
                        )),
                    title: (_) => Text('Livro avaliado com sucesso!'),
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
                }).catchError((error) => print("Failed to order user: $error"));

                if (!mounted) return;

                setState(() {
                  _streamController.sink;
                });

                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
