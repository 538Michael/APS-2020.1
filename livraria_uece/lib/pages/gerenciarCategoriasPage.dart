import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/livro/categoria.dart';
import 'package:livraria_uece/classes/services/request.dart';
import 'package:livraria_uece/extra/showAlertDialog.dart';
import 'package:livraria_uece/pages/cadastrarCategoriaPage.dart';

class GerenciarCategoriasPage extends StatefulWidget {
  @override
  _GerenciarCategoriasPageState createState() => _GerenciarCategoriasPageState();
}

class _GerenciarCategoriasPageState extends State<GerenciarCategoriasPage> {
  final request = new Request(loadCategoriesIRL: true);

  FirebaseAuth auth = FirebaseAuth.instance;

  CollectionReference books = FirebaseFirestore.instance.collection('books');

  CollectionReference categories = FirebaseFirestore.instance.collection('categories');

  Categoria categoriaAtual;

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  void deletarCategoria() async {
    BotToast.showLoading(
      clickClose: false,
      allowClick: false,
      crossPage: false,
      backButtonBehavior: BackButtonBehavior.none,
      animationDuration: Duration(milliseconds: 200),
      animationReverseDuration: Duration(milliseconds: 200),
      backgroundColor: Color(0x42000000),
    );

    List<Future> futures = new List();

    await books
        .where('category_id', arrayContains: categoriaAtual.id)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        futures.add(books.doc(element.id).update({
          'category_id': FieldValue.arrayRemove([categoriaAtual.id])
        }));
      });
    });

    await Future.wait(futures);

    BotToast.closeAllLoading();

    await categories.doc(categoriaAtual.id).delete().then((value) {
      print("Categoria Deleted");

      BotToast.closeAllLoading();

      BotToast.showNotification(
        leading: (cancel) => SizedBox.fromSize(
            size: const Size(40, 40),
            child: IconButton(
              icon: Icon(Icons.assignment_turned_in, color: Colors.green),
              onPressed: cancel,
            )),
        title: (_) => Text('Categoria deletada com sucesso!'),
        trailing: (cancel) => IconButton(
          icon: Icon(Icons.cancel),
          onPressed: cancel,
        ),
        enableSlideOff: true,
        backButtonBehavior: BackButtonBehavior.none,
        crossPage: true,
        contentPadding: EdgeInsets.all(2),
        onlyOne: true,
        animationDuration: Duration(milliseconds: 200),
        animationReverseDuration: Duration(milliseconds: 200),
        duration: Duration(seconds: 3),
      );
    }).catchError(
          (error) {
        print("Failed to delete category: $error");

        BotToast.closeAllLoading();

        BotToast.showNotification(
          leading: (cancel) => SizedBox.fromSize(
              size: const Size(40, 40),
              child: IconButton(
                icon: Icon(Icons.warning_rounded, color: Colors.red),
                onPressed: cancel,
              )),
          title: (_) => Text('Ocorreu um erro ao deletar a categoria!'),
          subtitle: (_) => Text('$error'),
          trailing: (cancel) => IconButton(
            icon: Icon(Icons.cancel),
            onPressed: cancel,
          ),
          enableSlideOff: true,
          backButtonBehavior: BackButtonBehavior.none,
          crossPage: true,
          contentPadding: EdgeInsets.all(2),
          onlyOne: true,
          animationDuration: Duration(milliseconds: 200),
          animationReverseDuration: Duration(milliseconds: 200),
          duration: Duration(seconds: 3),
        );
      },
    );
    categoriaAtual = null;
  }

  void _showDeleteDialog() {
    showAlertDialog(
      BackButtonBehavior.none,
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      title: 'Remover Categoria',
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Tem certeza que deseja remover essa categoria?'),
          ],
        ),
      ),
      confirm: deletarCategoria,
    );
  }

  void _showEditDialog() {
    showDialog(
        context: context,
        builder: (context) {
          TextEditingController nome = new TextEditingController();
          return AlertDialog(
            title: Text('Renomear Categoria'),
            content: SingleChildScrollView(
              child: ListBody(children: <Widget>[
                TextField(
                  controller: nome..text = categoriaAtual.categoria,
                  decoration: InputDecoration(hintText: 'Nome'),
                ),
              ]),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('Cancelar'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('Confirmar'),
                onPressed: () async {
                  if (nome.text == categoriaAtual.categoria) {
                    categoriaAtual = null;
                    Navigator.pop(context);
                    return;
                  }
                  if (nome.text.isEmpty) {
                    BotToast.showNotification(
                      leading: (cancel) => SizedBox.fromSize(
                          size: const Size(40, 40),
                          child: IconButton(
                            icon:
                            Icon(Icons.warning_rounded, color: Colors.red),
                            onPressed: cancel,
                          )),
                      title: (_) =>
                          Text('O campo do nome precisa ser preenchido!'),
                      trailing: (cancel) => IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: cancel,
                      ),
                      enableSlideOff: true,
                      backButtonBehavior: BackButtonBehavior.none,
                      crossPage: true,
                      contentPadding: EdgeInsets.all(2),
                      onlyOne: true,
                      animationDuration: Duration(milliseconds: 200),
                      animationReverseDuration: Duration(milliseconds: 200),
                      duration: Duration(seconds: 3),
                    );
                    return;
                  }

                  BotToast.showLoading(
                    clickClose: false,
                    allowClick: false,
                    crossPage: false,
                    backButtonBehavior: BackButtonBehavior.none,
                    animationDuration: Duration(milliseconds: 200),
                    animationReverseDuration: Duration(milliseconds: 200),
                    backgroundColor: Color(0x42000000),
                  );

                  await categories
                      .doc(categoriaAtual.id)
                      .update({'nome': nome.text}).then((value) {
                    print("Category Renamed");

                    BotToast.closeAllLoading();

                    BotToast.showNotification(
                      leading: (cancel) => SizedBox.fromSize(
                          size: const Size(40, 40),
                          child: IconButton(
                            icon: Icon(Icons.assignment_turned_in,
                                color: Colors.green),
                            onPressed: cancel,
                          )),
                      title: (_) => Text('Categoria renomeada com sucesso!'),
                      trailing: (cancel) => IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: cancel,
                      ),
                      enableSlideOff: true,
                      backButtonBehavior: BackButtonBehavior.none,
                      crossPage: true,
                      contentPadding: EdgeInsets.all(2),
                      onlyOne: true,
                      animationDuration: Duration(milliseconds: 200),
                      animationReverseDuration: Duration(milliseconds: 200),
                      duration: Duration(seconds: 3),
                    );
                  }).catchError(
                        (error) {
                      print("Failed to delete category: $error");

                      BotToast.closeAllLoading();

                      BotToast.showNotification(
                        leading: (cancel) => SizedBox.fromSize(
                            size: const Size(40, 40),
                            child: IconButton(
                              icon: Icon(Icons.warning_rounded,
                                  color: Colors.red),
                              onPressed: cancel,
                            )),
                        title: (_) =>
                            Text('Ocorreu um erro ao renomear a categoria!'),
                        subtitle: (_) => Text('$error'),
                        trailing: (cancel) => IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: cancel,
                        ),
                        enableSlideOff: true,
                        backButtonBehavior: BackButtonBehavior.none,
                        crossPage: true,
                        contentPadding: EdgeInsets.all(2),
                        onlyOne: true,
                        animationDuration: Duration(milliseconds: 200),
                        animationReverseDuration: Duration(milliseconds: 200),
                        duration: Duration(seconds: 3),
                      );
                    },
                  );
                  categoriaAtual = null;
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  _body() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gerênciar Categorias"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CadastrarCategoriaPage(),
                ),
              );
            },
          )
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: request.updatingCategories,
        builder: (context, snapshot, widget) {
          if (!request.isReady.value) {
            return Center(child: CircularProgressIndicator());
          }

          List<Categoria> listaCategorias = request.categorias.values.where((element) => element.id != 'Todas').toList();

          return ListView.builder(
              itemCount: listaCategorias.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    listaCategorias[index].categoria,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        padding: EdgeInsets.zero,
                        splashRadius: 20,
                        icon: Icon(
                          Icons.edit,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          categoriaAtual = listaCategorias[index];
                          _showEditDialog();
                        },
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        splashRadius: 20,
                        icon: Icon(
                          Icons.delete_forever_rounded,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          categoriaAtual = listaCategorias[index];
                          _showDeleteDialog();
                        },
                      )
                    ],
                  ),
                );
              });
        },
      ),
    );
  }
}
