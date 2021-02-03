import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/livro/livro.dart';
import 'package:livraria_uece/classes/services/request.dart';

class RemoverLivroPage extends StatefulWidget {
  Map<String, Livro> livros;

  RemoverLivroPage({Key key, @required this.livros}) : super(key: key);

  @override
  _RemoverLivroPageState createState() => _RemoverLivroPageState();
}

class _RemoverLivroPageState extends State<RemoverLivroPage> {
  final _formKey = GlobalKey<FormState>();

  final request = new Request();

  final _streamController = new StreamController();

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

  Livro _selectedItem;

  void _loadData() async {
    await request.isReady;

    _streamController.add(request.livros.values.toList());
  }

  _body() {
    _loadData();
    return Scaffold(
      appBar: AppBar(
        title: Text("Remover Livro"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Erro ao acessar os dados."));
          }
          if (!snapshot.hasData && auth.currentUser != null) {
            return Center(child: CircularProgressIndicator());
          }

          List<Livro> livros = snapshot.data;

          return Container(
            margin: EdgeInsets.all(10),
            child: DropdownSearch<Livro>(
              label: "Escolha um livro",
              mode: Mode.DIALOG,
              items: livros,
              itemAsString: (Livro u) => u.titulo,
              onChanged: (Livro data) {
                setState(() {
                  _selectedItem = data;
                });
              },
              showSearchBox: true,
              showClearButton: true,
            ),
          );
        },
      ),
    );
  }

  void _onButtonClick(BuildContext context) async {
    FocusScope.of(context).unfocus();
    bool formOk = _formKey.currentState.validate();
    if (!formOk) {
      return;
    }

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

      /*CollectionReference books = firestore.collection('books');
      CollectionReference book_autor = firestore.collection('book_autor');
      CollectionReference book_category = firestore.collection('book_category');

      String book_id = books.doc().id;
      String cover_url;

      try {
        if (capa != null) {
          await firebase_storage.FirebaseStorage.instance
              .ref()
              .child('covers')
              .child(book_id)
              .putFile(capa)
              .then((value) async {
            print("Cover Added");
            cover_url = await value.ref.getDownloadURL();
          }).catchError((error) => print("Failed to add cover: $error"));
        }
      } on firebase_storage.FirebaseException catch (e) {
        // e.g, e.code == 'canceled'
      }

      await books
          .doc(book_id)
          .set({
        'name': nome,
        'price': preco,
        'publisher': editora.id,
        'cover_url': cover_url
      })
          .then((value) => print("Livro Added"))
          .catchError((error) => print("Failed to add livro: $error"));

      autores.forEach((element) async {
        await book_autor
            .add({'book_id': book_id, 'autor_id': element.id})
            .then((value) => print("Book_Autor Added"))
            .catchError((error) => print("Failed to add Book_Autor: $error"));
      });

      categorias.forEach((element) async {
        await book_category
            .add({'book_id': book_id, 'category_id': element.id})
            .then((value) => print("Book_Category Added"))
            .catchError(
                (error) => print("Failed to add Book_Category: $error"));
      });*/

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
