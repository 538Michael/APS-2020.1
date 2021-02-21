import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/services/request.dart';

class GerenciarContasPage extends StatefulWidget {
  @override
  _GerenciarContasPageState createState() => _GerenciarContasPageState();
}

class _GerenciarContasPageState extends State<GerenciarContasPage> {
  final request = new Request();

  final _streamController = new StreamController();

  bool _cadastroVerified = true;

  FirebaseAuth auth = FirebaseAuth.instance;

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  void _loadData() async {
    if (auth.currentUser != null) {
      QuerySnapshot usuarios = await users.get();

      usuarios.docs.forEach((element) {
        isSwitched[element.id] = element.data()['nivel'] == 1;
      });

      _streamController.add(usuarios);
    }
  }

  Map<String, bool> isSwitched = new Map();

  _body() {
    _loadData();
    return Scaffold(
      appBar: AppBar(
        title: Text("Gerênciar Contas"),
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

          List<QueryDocumentSnapshot> data = snapshot.data.docs;

          return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return SwitchListTile(
                  title: Text(
                    data[index].data()['nome'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  value: isSwitched[data[index].id],
                  onChanged: (value) {
                    if (auth.currentUser != null) {
                      users
                          .doc(data[index].id)
                          .update({'nivel': value ? 1 : 0});
                      setState(() {
                        isSwitched[data[index].id] = value;
                      });
                    }
                  },
                  subtitle:
                      Text((isSwitched[data[index].id]) ? "Admin" : "Usuário"),
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                );
              });
        },
      ),
    );
  }
}
