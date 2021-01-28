import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/carrinhodecompra/carrinhodecompra.dart';
import 'package:livraria_uece/classes/carrinhodecompra/itemdecarrinho.dart';

class ShoppingCartPage extends StatefulWidget {
  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCartPage> {
  final _formKey = GlobalKey<FormState>();

  CarrinhoDeCompra carrinho = new CarrinhoDeCompra();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Carrinho"),
        centerTitle: true,
      ),
      body: _body(context),
      bottomNavigationBar: _bottomNavigationBar(context),
    );
  }

  final _streamController = new StreamController();

  _body(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.all(10.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  //TODO
                }
            ),
          ),
        )
      ],
    );
  }

  _bottomNavigationBar(BuildContext context) {
    return InkWell(
        child: Container(
          height: 50,
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: Container(
            alignment: Alignment.center,
            color: Colors.deepOrange,
            child: Text(
                "Finalizar compra",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                )
            ),
          ),
        ),
        highlightColor: Colors.orange,
        onTap: () {

        }
    );
  }
}
