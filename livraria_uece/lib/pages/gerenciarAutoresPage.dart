import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/livro/autor.dart';
import 'package:livraria_uece/classes/services/request.dart';
import 'package:livraria_uece/extra/showAlertDialog.dart';
import 'package:livraria_uece/pages/cadastrarAutorPage.dart';

class GerenciarAutoresPage extends StatefulWidget {
  @override
  _GerenciarAutoresPageState createState() => _GerenciarAutoresPageState();
}

class _GerenciarAutoresPageState extends State<GerenciarAutoresPage> {
  final request = new Request(loadAutorsIRT: true);

  FirebaseAuth auth = FirebaseAuth.instance;

  CollectionReference books = FirebaseFirestore.instance.collection('books');

  CollectionReference autors = FirebaseFirestore.instance.collection('autors');

  Autor autorAtual;

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  void deletarAutor() async {
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
        .where('autor_id', arrayContains: autorAtual.id)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        futures.add(books.doc(element.id).update({
          'autor_id': FieldValue.arrayRemove([autorAtual.id])
        }));
      });
    });

    await Future.wait(futures);

    BotToast.closeAllLoading();

    await autors.doc(autorAtual.id).delete().then((value) {
      print("Autor Deleted");

      BotToast.closeAllLoading();

      BotToast.showNotification(
        leading: (cancel) => SizedBox.fromSize(
            size: const Size(40, 40),
            child: IconButton(
              icon: Icon(Icons.assignment_turned_in, color: Colors.green),
              onPressed: cancel,
            )),
        title: (_) => Text('Autor deletado com sucesso!'),
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
        print("Failed to delete autor: $error");

        BotToast.closeAllLoading();

        BotToast.showNotification(
          leading: (cancel) => SizedBox.fromSize(
              size: const Size(40, 40),
              child: IconButton(
                icon: Icon(Icons.warning_rounded, color: Colors.red),
                onPressed: cancel,
              )),
          title: (_) => Text('Ocorreu um erro ao deletar o autor!'),
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
    autorAtual = null;
  }

  void _showDeleteDialog() {
    showAlertDialog(
      BackButtonBehavior.none,
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      title: 'Remover Autor',
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Tem certeza que deseja remover esse autor?'),
          ],
        ),
      ),
      confirm: deletarAutor,
    );
  }

  void _showEditDialog() {
    showDialog(
        context: context,
        builder: (context) {
          TextEditingController nome = new TextEditingController();
          return AlertDialog(
            title: Text('Renomear Autor'),
            content: SingleChildScrollView(
              child: ListBody(children: <Widget>[
                TextField(
                  controller: nome..text = autorAtual.autor,
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
                  if (nome.text == autorAtual.autor) {
                    autorAtual = null;
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

                  await autors
                      .doc(autorAtual.id)
                      .update({'nome': nome.text}).then((value) {
                    print("Autor Renamed");

                    BotToast.closeAllLoading();

                    BotToast.showNotification(
                      leading: (cancel) => SizedBox.fromSize(
                          size: const Size(40, 40),
                          child: IconButton(
                            icon: Icon(Icons.assignment_turned_in,
                                color: Colors.green),
                            onPressed: cancel,
                          )),
                      title: (_) => Text('Autor renomeado com sucesso!'),
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
                      print("Failed to delete autor: $error");

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
                            Text('Ocorreu um erro ao renomear o autor!'),
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
                  autorAtual = null;
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
        title: Text("Gerênciar Autores"),
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
                  builder: (context) => CadastrarAutorPage(),
                ),
              );
            },
          )
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: request.updatingAutors,
        builder: (context, snapshot, widget) {
          if (!request.isReady.value) {
            return Center(child: CircularProgressIndicator());
          }

          List<Autor> listaAutores = request.autores.values.toList();

          return ListView.builder(
              itemCount: listaAutores.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    listaAutores[index].autor,
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
                          autorAtual = listaAutores[index];
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
                          autorAtual = listaAutores[index];
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
