import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_selector_formfield/image_selector_formfield.dart';
import 'package:livraria_uece/classes/livro/autor.dart';
import 'package:livraria_uece/classes/livro/categoria.dart';
import 'package:livraria_uece/classes/livro/editora.dart';
import 'package:livraria_uece/classes/services/request.dart';
import 'package:livraria_uece/extra/textformfield.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class CadastrarLivroPage extends StatefulWidget {
  Map<int, Autor> autores;
  Map<int, Categoria> categorias;
  Map<int, Editora> editoras;

  CadastrarLivroPage({Key key, this.autores, this.categorias, this.editoras});

  @override
  _CadastrarLivroPageState createState() => _CadastrarLivroPageState();
}

class _CadastrarLivroPageState extends State<CadastrarLivroPage> {
  final _formKey = GlobalKey<FormState>();

  final _tNome = TextEditingController();

  final _tPreco = TextEditingController();

  final _tCapa = TextEditingController();

  final request = new Request();

  bool _cadastroVerified = true;

  FirebaseAuth auth = FirebaseAuth.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  _body() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastrar Livro"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.only(top: 20, left: 40, right: 40),
          child: ListView(
            children: <Widget>[
              ImageSelectorFormField(
                backgroundColor: Colors.blueGrey,
                borderRadius: 0,
                onChanged: (img) async {
                  /*try {
                    await firebase_storage.FirebaseStorage.instance
                        .ref()
                        .child('covers')
                        .child('test.jpg')
                        .putFile(img)
                        .then((value) => print("Cover Added"))
                        .catchError(
                            (error) => print("Failed to add cover: $error"));
                  } on firebase_storage.FirebaseException catch (e) {
                    // e.g, e.code == 'canceled'
                  }*/
                },
              ),
              SizedBox(height: 15),
              textformfield(
                "Nome",
                "Digite o nome",
                false,
                controller: _tNome,
                validator: _validateNome,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 15),
              textformfield(
                "Preço",
                "Digite o preço",
                false,
                controller: _tPreco,
                validator: _validatePreco,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              SizedBox(height: 15),
              MultiSelectChipField(
                searchable: true,
                title: Text(
                  'Autores',
                  style: TextStyle(color: Colors.white),
                ),
                searchIcon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                closeSearchIcon: Icon(Icons.close, color: Colors.white),
                searchHintStyle: TextStyle(color: Colors.white),
                searchTextStyle: TextStyle(color: Colors.white),
                searchHint: "Pesquisar autor...",
                items: widget.autores.values
                    .map((e) => MultiSelectItem(e, e.autor))
                    .toList(),
                onTap: (values) {
                  values.forEach((element) {
                    Autor aux = element;
                    print(aux.autor);
                  });
                },
              ),
              SizedBox(height: 15),
              MultiSelectChipField(
                searchable: true,
                title: Text(
                  'Categorias',
                  style: TextStyle(color: Colors.white),
                ),
                searchIcon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                closeSearchIcon: Icon(Icons.close, color: Colors.white),
                searchHintStyle: TextStyle(color: Colors.white),
                searchTextStyle: TextStyle(color: Colors.white),
                searchHint: "Pesquisar categoria...",
                items: widget.categorias.values
                    .where((element) => element.categoria != "Todas")
                    .map((e) => MultiSelectItem(e, e.categoria))
                    .toList(),
                onTap: (value) {
                  setState(() {});
                },
              ),
              SizedBox(height: 15),
              MultiSelectChipField(
                searchable: true,
                title: Text(
                  'Editora',
                  style: TextStyle(color: Colors.white),
                ),
                searchIcon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                closeSearchIcon: Icon(Icons.close, color: Colors.white),
                searchHintStyle: TextStyle(color: Colors.white),
                searchTextStyle: TextStyle(color: Colors.white),
                searchHint: "Pesquisar editora...",
                items: widget.editoras.values
                    .map((e) => MultiSelectItem(e, e.editora))
                    .toList(),
                onTap: (values) {
                  values.forEach((element) {
                    Editora aux = element;
                    print(aux.editora);
                  });
                },
              ),
              SizedBox(height: 15),
              Container(
                child: Visibility(
                  visible: _cadastroVerified,
                  child: Container(
                    child: FlatButton(
                      color: Colors.pink,
                      child: Text(
                        "Cadastrar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      onPressed: () {
                        _onButtonClick(context);
                      },
                    ),
                  ),
                  replacement: Center(child: CircularProgressIndicator()),
                ),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  String _validateNome(String text) {
    if (text.isEmpty) {
      return "O nome deve ser preenchido";
    }
    return null;
  }

  String _validatePreco(String text) {
    if (text.isEmpty) {
      return "O preço deve ser preenchido";
    }
    return null;
  }

  String _validateCapa(String text) {
    if (text.isEmpty) {
      return "A url da capa deve ser preenchida";
    }
    return null;
  }

  void _onButtonClick(BuildContext context) async {
    FocusScope.of(context).unfocus();
    bool formOk = _formKey.currentState.validate();
    if (!formOk) {
      return;
    }

    String nome = _tNome.text;

    setState(() {
      _cadastroVerified = false;
    });

    try {
      if (auth.currentUser == null) {
        return;
      }

      CollectionReference users = firestore.collection('users');

      DocumentSnapshot data = await users.doc(auth.currentUser.uid).get();

      if (data.data()['nivel'] != 1) {
        return;
      }

      CollectionReference autors = firestore.collection('categories');

      await autors
          .add({
            'nome': nome,
          })
          .then((value) => print("Categoria Added"))
          .catchError((error) => print("Failed to add categoria: $error"));

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      _cadastroVerified = true;
    });
  }
}
