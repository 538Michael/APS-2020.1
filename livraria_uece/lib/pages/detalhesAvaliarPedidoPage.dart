import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/carrinhodecompra/itemdeavaliacao.dart';
import 'package:livraria_uece/classes/livro/livro.dart';
import 'package:livraria_uece/classes/pedido/pedido.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class DetalhesAvaliarPedidoPage extends StatefulWidget {
  Pedido _pedido;
  DetalhesAvaliarPedidoPage(this._pedido);

  @override
  _DetalhesAvaliarPedidoState createState() => _DetalhesAvaliarPedidoState(_pedido);
}

class _DetalhesAvaliarPedidoState extends State<DetalhesAvaliarPedidoPage>  {

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
    Map<String,double> avaliacoes = new Map();
    QuerySnapshot ratingQuery = await FirebaseFirestore.instance.collection('ratings')
        .where('order_id', isEqualTo: _pedido.ID)
        .get()
        .then((querySnapshot) {
            querySnapshot.docs.forEach((element) => avaliacoes[element.data()['book_id']] = element.data()['rating']);
            return;
        });


    List<ItemDeAvaliacao> livros = new List();
    QuerySnapshot bookQuery = await FirebaseFirestore.instance.collection('books')
        .where(FieldPath.documentId, whereIn: _pedido.items.keys.toList())
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        livros.add( ItemDeAvaliacao(
          Livro(
            id: element.id,
            titulo: element.data()['name'],
            url_capa: element.data()['cover_url'],
            preco: _pedido.items[ element.id ][1],
          ),
          _pedido.items[ element.id ][0],
          avaliacao: avaliacoes.containsKey(element.id) ? avaliacoes[element.id] : null,
        ));
      });
      return;});
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
            color: Theme
                .of(context)
                .backgroundColor,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
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
                                    livros[index].livro.url_capa,
                                    fit: BoxFit.fitHeight,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 15.0, right: 10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                          "Quantidade: " + livros[index].quantidade.toString(),
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
                                                "R\$ " + livros[index].livro.preco
                                                    .toStringAsFixed(2) ,
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: 'Raleway',
                                                  fontSize: 20,
                                                  letterSpacing: 0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme
                                                      .of(context)
                                                      .primaryColor,
                                                ),
                                              )
                                          ),
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
                                    visible: livros[index].avaliacao == null, //TODO se não tiver avaliado ainda
                                    child: InkWell(
                                        splashColor: Colors.blueGrey,
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                              "Avalie seu pedido",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20
                                              )
                                          ),
                                        ),
                                        onTap: () {
                                          _AlertDialog(context, livros[index].livro);
                                        }
                                    ),
                                    replacement: Container(
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                              "Sua avaliação: " ,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20
                                              )
                                          ),
                                          SmoothStarRating(
                                            borderColor: Colors.black,
                                            color: Colors.black,
                                            rating: livros[index].avaliacao ?? 0.0,
                                            allowHalfRating: false,
                                            isReadOnly: true,
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
      height: 90,
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
        ],
      ),
    );
  }

  _AlertDialog(BuildContext context, Livro livro) {
    double rating;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SmoothStarRating(
                allowHalfRating: false,
                starCount: 5,
                size: 40,
                onRated: (value) => rating = value,
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
                CollectionReference ratings = firestore.collection('ratings');

                await ratings
                    .add({
                  'book_id': livro.id,
                  'order_id': _pedido.ID,
                  'user_id': FirebaseAuth.instance.currentUser.uid,
                  'rating': rating,
                })
                .then((value) => print("Rating Added") )
                .catchError((error) => print("Failed to order user: $error") );

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