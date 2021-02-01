import 'dart:async';

import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/carrinhodecompra/carrinhodecompra.dart';
import 'package:livraria_uece/classes/livro/livro.dart';
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

  set livro(Livro value) {
    _livro = value;
  }

  _LivroDetalheState({Livro livro}) {
    _livro = livro;
  }

  CarrinhoDeCompra carrinho = new CarrinhoDeCompra();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes do Livro"),
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
      body: _body(context),
      bottomNavigationBar: _bottomNavigationBar(context),
    );
  }

  _body(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child:  CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                margin: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 350,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 1.0, color: Colors.black),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Image.network(
                          livro.url_capa ?? 'https://livrariacultura.vteximg.com.br/arquivos/ids/19870049/2112276853.png',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          SliverAppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            floating: false,
            pinned: false,
            title: Text(
              "Preço",
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
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1.0, color: Colors.black),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      "R\$ "+ livro.preco.toStringAsFixed(2),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),

              ),
            ]),
          ),
          SliverAppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            floating: false,
            pinned: false,
            title: Text(
              "Título",
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
                child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 1.0, color: Colors.black),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          livro.titulo,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),

              ),
            ]),
          ),
          livro.autores.length != 0 ? SliverAppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            floating: false,
            pinned: false,
            title: Text(
              "Autores",
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
          ) : SliverPadding(padding: EdgeInsets.all(0)),
          SliverPadding(
            padding: EdgeInsets.all(5),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return Container(
                    child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 1.0, color: Colors.black),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              livro.autores[index].autor,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                    ),
                  );
                },
                childCount: livro.autores.length,
              ),
            ),
          ),
          SliverAppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            floating: false,
            pinned: false,
            title: Text(
              "Editora",
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
          SliverPadding(
            padding: EdgeInsets.all(5),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 1.0, color: Colors.black),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              livro.editora.editora,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                  )
                ]
              ),
            ),
          ),
        ],
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
            child: Text(
              "Adicionar ao Carrinho",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
              )
            ),
          ),
          onTap: () {
            carrinho.addLivro(livro);
          }
        )
      ),
    );
      
  }
}
