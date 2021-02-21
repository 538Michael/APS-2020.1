import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificacoesPage extends StatelessWidget {
  final _streamController = new StreamController();

  FirebaseAuth auth = FirebaseAuth.instance;

  CollectionReference notifications =
      FirebaseFirestore.instance.collection('notifications');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notificações")),
      body: _body(context),
    );
  }

  _getNotifications() async {
    List<String> notificacoes = new List();
    await notifications
        .where('user_id', isEqualTo: auth.currentUser.uid)
        .orderBy('created_at', descending: true)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        notificacoes.add(element.data()['message']);
      });
    });
    _streamController.add(notificacoes);
  }

  _body(BuildContext context) {
    _getNotifications();
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

            List<String> notificacoes = snapshot.data;

            return Visibility(
              visible: notificacoes.length > 0,
              replacement: Container(
                color: Theme.of(context).backgroundColor,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Você ainda não possui nenhuma notificação",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
              child: ListView.builder(
                  itemCount: notificacoes.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.all(5.0),
                      color: Colors.white,
                      padding: const EdgeInsets.all(0.0),
                      child: ListTile(
                        title: Text(
                          notificacoes[index],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }),
            );
          }),
    );
  }
}
