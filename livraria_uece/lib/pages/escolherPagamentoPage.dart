
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/carrinhodecompra/carrinhodecompra.dart';

class EscolherPagamentoPage extends StatefulWidget {

  @override
  _EscolherPagamentoState createState() => _EscolherPagamentoState();
}

class _EscolherPagamentoState extends State<EscolherPagamentoPage> {

  CarrinhoDeCompra carrinho = new CarrinhoDeCompra();

  Pagamento _pagamento = Pagamento.boleto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Escolher Forma de Pagamento"),
      ),
      body: _body(context),
      bottomNavigationBar: _bottomNavigationBar(context),
    );
  }

  _body(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          ListTile(
            title: Text("Boleto Bancário"),
            leading: Radio(
              value: Pagamento.boleto,
              groupValue: _pagamento,
              onChanged: (Pagamento value) {
                setState(() {
                  _pagamento = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text("Cartão de Crédito"),
            leading: Radio(
              value: Pagamento.cartao,
              groupValue: _pagamento,
              onChanged: (Pagamento value) {
                setState(() {
                  _pagamento = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
  _bottomNavigationBar(BuildContext context) {
    return Container(
      height: 190,
      child: Column(
        children: <Widget>[
          Container(
            height: 40,
            margin: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Subtotal:",
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    )
                ),
                Text(
                    "R\$ " + carrinho.preco.toStringAsFixed(2),
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    )
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            margin: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Desconto:",
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    )
                ),
                Text(
                    (_pagamento == Pagamento.boleto) ?
                    "10% (R\$ " + carrinho.desconto.toStringAsFixed(2) + ")"
                    : "0%",
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    )
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
                Text(
                    "Total:",
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    )
                ),
                Text(
                    "R\$ " + (
                        carrinho.preco - ((_pagamento == Pagamento.boleto) ? carrinho.desconto : 0)
                    ).toStringAsFixed(2),
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    )
                ),
              ],
            ),
          ),

          Expanded(
              child: Material(
                  color: Colors.orangeAccent,
                  child: InkWell(
                      splashColor: Colors.blueGrey,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                            "Confirmar Compra",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20
                            )
                        ),
                      ),
                      onTap: () {
                        //TODO
                      }
                  )
              )
          )
        ],
      ),
    );
  }

}

enum Pagamento {boleto,cartao}