import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livraria_uece/classes/carrinhodecompra/carrinhodecompra.dart';
import 'package:livraria_uece/classes/livro/categoria.dart';
import 'package:livraria_uece/classes/livro/editora.dart';
import 'package:livraria_uece/classes/livro/autor.dart';
import 'package:livraria_uece/classes/livro/livro.dart';
import 'package:livraria_uece/pages/loginPage.dart';
import 'package:livraria_uece/pages/shoppingcartPage.dart';
import 'package:livraria_uece/pages/livrodetalhePage.dart';

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ShoppingCartPage()),
              );
            },
          ),
        ],
        centerTitle: true,
      ),
      drawer: DrawerTest(),
      body: _body(context),
      //drawer: DrawerListAluno(/*user: user*/),
    );
  }

  final _streamController = new StreamController(); //TODO Dá pra transformar em StreamController.broadcast() pra passar pra outras paginas;


  _test() async {
    var response1 =
        await http.post("https://ddc.community/michael/getContas.php");
    var response2 =
        await http.post("https://ddc.community/michael/getCategorias.php");
    var response3 =
        await http.post("https://ddc.community/michael/getutores.php");

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

  _getEditoras() async {    
    var response = await http.post("https://ddc.community/michael/getEditoras.php");

    if (response.statusCode == 200) {
      Map mapResponse = json.decode(response.body);
      List<dynamic> data = mapResponse["result"];
      List<Editora> editoras = new List();

      data.forEach((element) {
        editoras.add(
            Editora(int.parse(element["id"]), element["nome"])
        );
      });
      return editoras;
    }
  }  
  
  _getCategorias() async {
    var response = await http.post("https://ddc.community/michael/getCategorias.php");

    if (response.statusCode == 200) {
      Map mapResponse = json.decode(response.body);
      List<dynamic> data = mapResponse["result"];
      List<Categoria> categorias = new List();

      data.forEach((element) {
        categorias.add(
            Categoria(int.parse(element["id"]),element["nome"])
        );
      });
      return categorias;
    }
  }

  _getAutores() async {
    var response = await http.post("https://ddc.community/michael/getAutores.php");

    if (response.statusCode == 200) {
      Map mapResponse = json.decode(response.body);
      List<dynamic> data = mapResponse["result"];
      List<Autor> autores = new List();

      data.forEach((element) {
        autores.add(
            Autor(int.parse(element["id"]),element["nome"])
        );
      });
      return autores;
    }
  }

  _getLivros(List< List<dynamic> > recursos) async {
    var responseLivros =
        await http.post("https://ddc.community/michael/getLivros.php");

    var responseCategorias =
        await http.post("https://ddc.community/michael/getLivroCategoria.php");

    var responseAutores =
        await http.post("https://ddc.community/michael/getLivroAutores.php");

    var responseAvaliacoes =
        await http.post("https://ddc.community/michael/getAvaliacoes.php");

    if (responseLivros.statusCode == 200) {
      Map mapResponseLivros = json.decode(responseLivros.body);
      List<dynamic> dataLivros = mapResponseLivros["result"];
      List<Livro> livros = new List();

      // Map mapResponseCategorias = json.decode(responseCategorias.body);
      // List<dynamic> dataCategorias = mapResponseCategorias["result"];
      //
      // Map mapResponseAutores = json.decode(responseAutores.body);
      // List<dynamic> dataAutores = mapResponseAutores["result"];
      //
      // Map mapResponseAvalicoes = json.decode(responseAvaliacoes.body);
      // List<dynamic> dataAvaliacoes = mapResponseAvalicoes["result"];
      
      dataLivros.forEach((element) {
        //Gera recursos para o livro

        // //Cria lista de categorias do livro
        // List<int> filtroCategoria = dataCategorias.where((elementCategoria) => elementCategoria["livro_id"] == element["id"])
        //     .map((e) => int.parse(e["categoria_id"]));
        //
        // List<Categoria> categorias = recursos[0].where((elementCategoria) {
        //   if(filtroCategoria.firstWhere((elementId) => elementId == elementCategoria.id) != null) return true;
        //   return false;
        // });
        //
        // //Cria lista de autores do livro
        // List<int> filtroAutor = dataAutores.where((elementAutor) => elementAutor["livro_id"] == element["id"])
        //     .map((e) => int.parse(e["autor_id"]));
        //
        // List<Autor> autores = recursos[1].where((elementAutor) {
        //   if(filtroAutor.firstWhere((elementId) => elementId == elementAutor.id) != null) return true;
        //   return false;
        // });

        //Cria editora do livro
        Editora editora = recursos[2].firstWhere((elementEditora) => elementEditora.id == int.parse(element["editora_id"]) );

        // //Cria lista de avaliações
        // List<int> avaliacao = dataAvaliacoes.where((elementAvaliacao) => elementAvaliacao["livro_id"] == element["id"])
        //     .map((e) => int.parse(e["avaliacao"]));

        //
        
        livros.add(
          Livro(
            id: int.parse(element["id"]),
            url_capa: element["url_capa"],
            titulo: element["nome"],
            preco: double.parse(element["preco"]),
            //avaliacao: avaliacao,
            editora:  editora,
            //autores: autores,
            //categorias: categorias,
            //TODO falta outras coisas do livro
          )
        );
      });
      print(livros.first.editora);
      return livros;
    }
  }

  _setStreamController() async {
    List< List<dynamic> > recursos = new List();
    recursos.add(await _getCategorias());
    recursos.add(await _getAutores());
    recursos.add(await _getEditoras());
    recursos.add(await _getLivros(recursos));
    _streamController.add(recursos);
  }

  _body(BuildContext context) {
    // _test();
    _setStreamController();
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

          List<Categoria> categorias = snapshot.data[0];
          List<Autor> autores = snapshot.data[1];
          List<Editora> editoras = snapshot.data[2];
          List<Livro> livros = snapshot.data[3];

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

                            items: categorias.map<DropdownMenuItem<String>>((Categoria value) {
                              return DropdownMenuItem<String>(
                                value: value.categoria,
                                child: Text(value.categoria),
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
                      return InkWell(
                        child: Container(
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
                                    livros[index].url_capa,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              Container(
                                height: 40,
                                child: Text(
                                  livros[index].titulo,
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
                                  ( livros[index].editora == null ? "" : livros[index].editora.editora )
                                  // (
                                  //     livros[index].autores == null ? "" :
                                  //     (livros[index].autores.length == 1) ? livros[index].autores.first.autor : "Varios Autores"
                                  // )
                                  ,
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
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LivroDetalhePage(livro: livros[index])),
                          );
                        }
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
