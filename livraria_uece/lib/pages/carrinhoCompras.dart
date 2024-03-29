import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:livraria_uece/classes/carrinhodecompra/carrinhodecompra.dart';
import 'package:livraria_uece/classes/services/request.dart';
import 'package:livraria_uece/pages/escolherPagamentoPage.dart';

class CarrinhoComprasPage extends StatefulWidget {
  @override
  _CarrinhoComprasState createState() => _CarrinhoComprasState();
}

class _CarrinhoComprasState extends State<CarrinhoComprasPage> {
  final request = new Request(loadBooks: true, loadShoppingCart: true);

  CarrinhoDeCompra carrinho = new CarrinhoDeCompra();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

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

  bool _updating = false;

  _body(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: ValueListenableBuilder(
          valueListenable: request.updating,
          builder: (context, snapshot, widget) {
            if (request.updating.value ||
                request.carrinho == null ||
                request.carrinho.carrinho == null) {
              return Center(child: CircularProgressIndicator());
            }

            return Visibility(
              visible: (request.carrinho.carrinho.isNotEmpty),
              child: Container(
                child: CustomScrollView(slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        Iterable<String> coverUrl = request.carrinho.carrinho[index].livro.url_capa.where((element) => element != null);
                        String urlCapa = 'https://livrariacultura.vteximg.com.br/arquivos/ids/19870049/2112276853.png';
                        if(coverUrl.isNotEmpty) urlCapa = coverUrl.first;
                        return Container(
                          margin: EdgeInsets.all(5.0),
                          color: Colors.white,
                          padding: const EdgeInsets.only(
                              top: 5, right: 5, left: 5, bottom: 10),
                          height: 200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Image.network(
                                  urlCapa,
                                  fit: BoxFit.fill,
                                ),
                                height: 200,
                                width: 120,
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      top: 5.0, left: 10.0, right: 10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        request.carrinho.carrinho[index].livro
                                            .titulo,
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
                                            child: Text(
                                              "R\$ " +
                                                  request
                                                      .carrinho
                                                      .carrinho[index]
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
                                      Container(
                                        height: 50,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.black,
                                                    width: 3,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(7))),
                                              child: Row(
                                                children: [
                                                  Material(
                                                    child: InkWell(
                                                      splashColor:
                                                          Colors.deepOrange,
                                                      child: SizedBox(
                                                          width: 40,
                                                          height: 40,
                                                          child: Icon(
                                                              Icons.remove)),
                                                      onTap: () async {
                                                        if(_updating) return;
                                                        _updating = true;
                                                        await request
                                                            .removeShoppingCart(
                                                                request
                                                                    .carrinho
                                                                    .carrinho[
                                                                        index]
                                                                    .livro);
                                                        _updating = false;
                                                        setState(() {});
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
                                                        request
                                                            .carrinho
                                                            .carrinho[index]
                                                            .quantidade
                                                            .toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          letterSpacing: 0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                  ),
                                                  Material(
                                                    child: InkWell(
                                                      splashColor:
                                                          Colors.deepOrange,
                                                      child: SizedBox(
                                                          width: 40,
                                                          height: 40,
                                                          child:
                                                              Icon(Icons.add)),
                                                      onTap: () async {
                                                        if(_updating) return;
                                                        _updating = true;
                                                        await request
                                                            .addShoppingCart(
                                                                request
                                                                    .carrinho
                                                                    .carrinho[
                                                                        index]
                                                                    .livro);
                                                        _updating = false;
                                                        setState(() {});
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
                                                  splashColor:
                                                      Colors.deepOrange,
                                                  child: SizedBox(
                                                      width: 40,
                                                      height: 40,
                                                      child: Icon(Icons
                                                          .remove_shopping_cart)),
                                                  onTap: () async {
                                                    await request
                                                        .removeShoppingCart(
                                                            request
                                                                .carrinho
                                                                .carrinho[index]
                                                                .livro,
                                                            removeCompleto:
                                                                true);
                                                    setState(() {});
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
                      childCount: request.carrinho.carrinho.length,
                    ),
                  ),
                ]),
              ),
              replacement: Container(
                color: Theme.of(context).backgroundColor,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Seu carrinho está vazio",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        )),
                    Text("Adicione livros primeiro,",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        )),
                    Text(" e mostraremos os produtos aqui",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ))
                  ],
                ),
              ),
            );
          }),
    );
  }

  _bottomNavigationBar(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: request.updating,
      builder: (context, snapshot, widget) {
        double preco = 0;

        if (!request.updating.value &&
            request.carrinho != null &&
            request.carrinho.carrinho != null) {
          preco = request.carrinho.preco;
        }

        return Visibility(
          visible: request.carrinho.carrinho.isNotEmpty,
          child: Container(
            height: 110,
            child: Column(
              children: <Widget>[
                Container(
                  height: 40,
                  margin: EdgeInsets.only(
                      top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Subtotal:",
                          maxLines: 1,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Text("R\$ " + preco.toStringAsFixed(2),
                          maxLines: 1,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                Visibility(
                  visible: auth.currentUser != null,
                  child: Expanded(
                    child: Material(
                      color: Colors.orangeAccent,
                      child: InkWell(
                          splashColor: Colors.blueGrey,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text("Finalizar compra",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EscolherPagamentoPage()),
                            );
                          }),
                    ),
                  ),
                  replacement: Expanded(
                      child: Container(
                          color: Colors.orangeAccent,
                          alignment: Alignment.center,
                          child: Text("Login necessário para concluir",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)))),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
