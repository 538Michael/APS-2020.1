import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/carrinhodecompra/itemdecarrinho.dart';
import 'package:livraria_uece/classes/conta/conta.dart';
import 'package:livraria_uece/classes/livro/livro.dart';
import 'package:livraria_uece/classes/pedido/pedido.dart';

class DetalhesPedidoPage extends StatelessWidget {

  Pedido _pedido;
  final _streamController = new StreamController();

  DetalhesPedidoPage(this._pedido);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalhes do Pedido")),
      body: _body(context),
      bottomNavigationBar: _bottomNavigationBar(context),
    );
  }

  _getLivros() async {
    List<ItemDeCarrinho> livros = new List();
    await FirebaseFirestore.instance.collection('books')
        .where(FieldPath.documentId, whereIn: _pedido.items.keys.toList())
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        livros.add( ItemDeCarrinho(
            Livro(
              id: element.id,
              titulo: element.data()['name'],
              url_capa: element.data()['cover_url'],
              preco: _pedido.items[ element.id ][1],
            ),
            _pedido.items[ element.id ][0]
        ));
      });
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

          List<ItemDeCarrinho> livros = snapshot.data;
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
}