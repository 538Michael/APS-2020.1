import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/carrinhodecompra/itemdecarrinho.dart';
import 'package:livraria_uece/classes/services/request.dart';

class RelatorioVendasPage extends StatefulWidget {
  @override
  _RelatorioVendasState createState() => _RelatorioVendasState();
}

class _RelatorioVendasState extends State<RelatorioVendasPage> {
  final _streamController = new StreamController();

  final request = new Request();

  CollectionReference books = FirebaseFirestore.instance.collection('books');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Relatório de Vendas")),
      body: _body(context),
      bottomNavigationBar: _bottomNavigationBar(context),
    );
  }

  _getPedidos() async {
    setState(() {
      items = new List();
    });
    items = await request.getStats(dateRange);
    if (items == null || items.length == 0) items = null;
    setState(() {
      total = 0;
      if (items != null) {
        items.forEach((element) {
          total += element.livro.preco * element.quantidade;
        });
      }
    });
  }

  dateTimeRangePicker(BuildContext context) async {
    DateTimeRange picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) {
      print(picked);
      print((picked.start.millisecondsSinceEpoch / 1000).truncate().toString() +
          " " +
          (picked.end.millisecondsSinceEpoch / 1000).truncate().toString());
    }
    return picked;
  }

  DateTimeRange dateRange;
  List<ItemDeCarrinho> items = new List();
  double total = 0;

  _body(BuildContext context) {
    //_getPedidos();
    return Container(
      color: Theme.of(context).backgroundColor,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(10),
              child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      style: new TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                            text: "Intervalo: ",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: (dateRange != null)
                                ? "${dateRange.start.day.toString().padLeft(2, '0')}/${dateRange.start.month.toString().padLeft(2, '0')}/${dateRange.start.year.toString().padLeft(4, '0')} - ${dateRange.end.day.toString().padLeft(2, '0')}/${dateRange.end.month.toString().padLeft(2, '0')}/${dateRange.end.year.toString().padLeft(4, '0')}"
                                : "Não selecionado.")
                      ])),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              child: RaisedButton(
                onPressed: () async {
                  DateTimeRange aux = await dateTimeRangePicker(context);
                  if (aux != null) {
                    setState(() {
                      dateRange = aux;
                    });
                    _getPedidos();
                  }
                },
                child: Text("Escolher Intervalo de Datas"),
              ),
            ),
          ),
          (dateRange == null)
              ? SliverFillRemaining(
                  child: Container(
                    color: Theme.of(context).backgroundColor,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Por favor, selecione um intervalo de datas",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                )
              : (items == null)
                  ? SliverFillRemaining(
                      child: Container(
                        color: Theme.of(context).backgroundColor,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Nenhum livro foi vendido nesse periodo",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                      ),
                    )
                  : (items.length == 0)
                      ? SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : SliverList(
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
                                      items[index].livro.url_capa,
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
                                            items[index].livro.titulo,
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
                                                items[index]
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
                                                margin:
                                                    EdgeInsets.only(top: 5.0),
                                                child: Text(
                                                  "R\$ " +
                                                      (items[index]
                                                                  .livro
                                                                  .preco *
                                                              items[index]
                                                                  .quantidade)
                                                          .toStringAsFixed(2),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                              );
                            },
                            childCount: items.length,
                          ),
                        )
        ],
      ),
    );
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
            color: Theme.of(context).backgroundColor,
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
                              margin: EdgeInsets.only(left: 15.0, right: 10.0),
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
                                    "Quantidade: " +
                                        livros[index].quantidade.toString(),
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
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        )),
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
      height: 45,
      color: Colors.pink,
      child: Column(
        children: <Widget>[
          Container(
            height: 40,
            margin: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total:",
                    maxLines: 1,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                Text("R\$ " + total.toStringAsFixed(2),
                    maxLines: 1,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
