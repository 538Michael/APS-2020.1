import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    if(carrinho.carrinho.isEmpty) {
      return Text("Carrinho vazio");
    }
    return Container(
      color: Theme.of(context).backgroundColor,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  margin: EdgeInsets.all(5.0),
                  color: Colors.white,
                  padding: const EdgeInsets.only(
                      top: 5, right: 5, left: 5, bottom: 10
                  ),
                  height: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Image.network(
                        carrinho.carrinho[index].livro.url_capa,
                        fit: BoxFit.fitHeight,
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only( top: 5.0, left: 10.0, right: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                carrinho.carrinho[index].livro.titulo,
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
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(top: 5.0),
                                  color: Colors.yellow,
                                  child: Text(
                                    "R\$ " + carrinho.carrinho[index].livro.preco.toStringAsFixed(2),
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
                                  )
                                ),
                              ),
                              Container(
                                height: 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 3,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(7)
                                        )
                                      ),
                                      child: Row(
                                        children: [
                                          Material(
                                            child: InkWell(
                                              splashColor: Colors.deepOrange,
                                              child: SizedBox(
                                                  width: 40,
                                                  height: 40,
                                                  child: Icon(Icons.remove)
                                              ),
                                              onTap: (){
                                                setState(() {
                                                  carrinho.removeLivroUnidade(carrinho.carrinho[index].livro);
                                                });
                                              },
                                            ),
                                          ),
                                          Container(
                                            width: 60,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                left: BorderSide(
                                                  color: Colors.black,
                                                  width: 2,
                                                ),
                                                right: BorderSide(
                                                  color: Colors.black,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              carrinho.carrinho[index].quantidade.toString(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 20,
                                                letterSpacing: 0,
                                                fontWeight: FontWeight.bold,
                                              )
                                            ),
                                          ),
                                          Material(
                                            child: InkWell(
                                              splashColor: Colors.deepOrange,
                                              child: SizedBox(
                                                  width: 40,
                                                  height: 40,
                                                  child: Icon(Icons.add)
                                              ),
                                              onTap: (){
                                                setState(() {
                                                  carrinho.addLivro(carrinho.carrinho[index].livro);
                                                });
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    ClipOval(
                                      child: Material(
                                        color: Colors.red,
                                        child: InkWell(
                                          splashColor: Colors.deepOrange,
                                          child: SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: Icon(Icons.remove_shopping_cart)
                                          ),
                                          onTap: (){
                                            //Todo
                                            setState(() {
                                              carrinho.removeLivro(carrinho.carrinho[index].livro);
                                            });
                                          },
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
              childCount: carrinho.carrinho.length,
            ),
          ),
        ]
      ),
    );

  }

  _bottomNavigationBar(BuildContext context) {
    return InkWell(
        splashColor: Colors.blue,
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
        onTap: () {
          print(carrinho.carrinho.first.livro.titulo);
        }
    );
  }
}
