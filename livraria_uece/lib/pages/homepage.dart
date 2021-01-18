import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livraria_uece/pages/loginPage.dart';

import 'cadastroPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String dropdownValue = 'Todas';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Página Inicial"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.account_box_rounded, size: 30.0),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.shopping_cart,
              size: 30.0,
            ),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
      ),
      drawer: DrawerTest(),
      body: _body(context),
      //drawer: DrawerListAluno(/*user: user*/),
    );
  }

  final _streamController = StreamController();

  _test() async {
    var response1 =
        await http.post("https://ddc.community/michael/listarContas.php");
    var response2 =
        await http.post("https://ddc.community/michael/listarCategorias.php");
    var response3 =
        await http.post("https://ddc.community/michael/listarAutores.php");

    // print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');

    if (response1.statusCode == 200) {
      Map mapResponse1 = json.decode(response1.body);
      List<dynamic> data = mapResponse1["result"];

      print('Contas:');

      data.forEach((element) {
        print(element);
      });

      print('\n');
    }

    if (response2.statusCode == 200) {
      Map mapResponse2 = json.decode(response2.body);
      List<dynamic> data = mapResponse2["result"];

      print('Categorias:');

      data.forEach((element) {
        print(element);
      });

      print('\n');
    }

    if (response3.statusCode == 200) {
      Map mapResponse3 = json.decode(response3.body);
      List<dynamic> data = mapResponse3["result"];

      print('Autores:');

      data.forEach((element) {
        print(element);
      });

      print('\n');
    }
  }

  _listarLivros() async {
    var response =
        await http.post("https://ddc.community/michael/listarLivros.php");

    if (response.statusCode == 200) {
      Map mapResponse = json.decode(response.body);
      List<dynamic> data = mapResponse["result"];

      _streamController.add(data);
    }
  }

  _body(BuildContext context) {
    _test();
    _listarLivros();
    List<List<String>> imagens = new List();

    imagens.insert(imagens.length, [
      "O PODER DO HÁBITO",
      "CHARLES DUHIGG",
      "https://livrariacultura.vteximg.com.br/arquivos/ids/16712085/30351365.jpg"
    ]);
    imagens.insert(imagens.length, [
      "RÁPIDO E DEVAGAR",
      "DANIEL KAHNEMAN",
      "https://livrariacultura.vteximg.com.br/arquivos/ids/16950643/5174253.jpg"
    ]);
    imagens.insert(imagens.length, [
      "SEJA FODA!",
      "CAIO CARNEIRO",
      "https://livrariacultura.vteximg.com.br/arquivos/ids/16977158/40126366.jpg"
    ]);
    imagens.insert(imagens.length, [
      "O PODER DA AÇÃO",
      "PAULO VIEIRA",
      "https://livrariacultura.vteximg.com.br/arquivos/ids/16374113/42892126.jpg"
    ]);
    imagens.insert(imagens.length, [
      "QUEM PENSA ENRIQUECE",
      "NAPOLEON HILL",
      "https://livrariacultura.vteximg.com.br/arquivos/ids/19659897/2112273997.jpg"
    ]);
    // imagens.insert(imagens.length, ["", "", ""]);

    return Container(
      color: Theme.of(context).backgroundColor,
      child: StreamBuilder(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Erro ao acessar os dados."));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List<dynamic> livros = snapshot.data;
          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                automaticallyImplyLeading: false,
                centerTitle: true,
                floating: false,
                pinned: true,
                title: Text(
                  "Livros",
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
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 10, right: 10),
                      color: Colors.pinkAccent,
                      child: Row(
                        children: [
                          Text(
                            "Categoria: ",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          DropdownButton<String>(
                            value: dropdownValue,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            dropdownColor: Colors.pink[700],
                            iconEnabledColor: Colors.white,
                            style: TextStyle(color: Colors.white),
                            underline: Container(
                              height: 0,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                dropdownValue = newValue;
                              });
                            },
                            items: <String>['Todas', 'Two', 'Free', 'Four']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      )),
                ]),
              ),
              SliverPadding(
                padding: EdgeInsets.all(10.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 186.0,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                    childAspectRatio: 0.55,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 1.0, color: Colors.black),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 5, right: 5, left: 5, bottom: 10),
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  child: FractionallySizedBox(
                                    alignment: Alignment.topCenter,
                                    widthFactor: 1,
                                    heightFactor: 1,
                                    child: Image.network(
                                      livros[index]["url_capa"],
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              Container(
                                height: 40,
                                child: Text(
                                  livros[index]["nome"],
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Container(
                                height: 27,
                                child: Text(
                                  livros[index]["nome"],
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 12,
                                    letterSpacing: 0,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: livros.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DrawerTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
          child: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
            color: Theme.of(context).primaryColor,
            child: Row(
              children: [
                Icon(
                  Icons.account_circle_rounded,
                  size: 100,
                  color: Colors.white,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      color: Colors.white10,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                        child: Column(
                          children: [
                            Row(
                              children: <Widget>[
                                Text(
                                  "Login",
                                  style: TextStyle(color: Colors.white),
                                ),
                                VerticalDivider(),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      padding: EdgeInsets.all(5),
                      color: Colors.white10,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CadastroPage()),
                          );
                        },
                        child: Column(
                          children: [
                            Row(
                              children: <Widget>[
                                Text(
                                  "Cadastre-se",
                                  style: TextStyle(color: Colors.white),
                                ),
                                VerticalDivider(),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          /*UserAccountsDrawerHeader(
            accountName: Text(user.nome),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage("assets/images/avatar_icon.png"),
            ),
          ),*/
          ListTile(
            leading: Icon(Icons.apps),
            title: Text("Editar dados pessoais"),
            subtitle: Text("Mais Informações..."),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {},
          ),
        ],
      )),
    );
  }
}
