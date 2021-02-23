import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livraria_uece/classes/livro/autor.dart';
import 'package:livraria_uece/classes/livro/categoria.dart';
import 'package:livraria_uece/classes/livro/editora.dart';
import 'package:livraria_uece/classes/services/request.dart';
import 'package:livraria_uece/extra/flutter_multiselect.dart';
import 'package:livraria_uece/extra/textformfield.dart';

class CadastrarLivroPage extends StatefulWidget {
  @override
  _CadastrarLivroPageState createState() => _CadastrarLivroPageState();
}

class _CadastrarLivroPageState extends State<CadastrarLivroPage> {
  final _formKey = GlobalKey<FormState>();

  final _tNome = TextEditingController();

  final _tPreco = TextEditingController();

  final request =
      new Request(loadPublishers: true, loadCategories: true, loadAutors: true);

  bool _cadastroVerified = true;

  FirebaseAuth auth = FirebaseAuth.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  List<Autor> autores = new List();
  List<Categoria> categorias = new List();
  Editora editora = null;

  File capa;

  @override
  void initState() {
    setState(() {
      images.add("Add Image");
      images.add("Add Image");
      images.add("Add Image");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  List<Object> images = List<Object>();
  Future<PickedFile> _imageFile;

  Future _onAddImageClick(int index) async {
    setState(() {
      _imageFile = ImagePicker().getImage(source: ImageSource.gallery);
      getFileImage(index);
    });
  }

  void getFileImage(int index) async {
    _imageFile.then((file) async {
      setState(() {
        ImageUploadModel imageUpload = new ImageUploadModel();
        imageUpload.isUploaded = false;
        imageUpload.uploading = false;
        imageUpload.imageFile = File(file.path);
        imageUpload.imageUrl = '';
        images.replaceRange(index, index + 1, [imageUpload]);
      });
    });
  }

  Widget buildGridView() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1,
      children: List.generate(images.length, (index) {
        if (images[index] is ImageUploadModel) {
          ImageUploadModel uploadModel = images[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: <Widget>[
                Image.file(
                  uploadModel.imageFile,
                  width: 300,
                  height: 300,
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: InkWell(
                    child: Icon(
                      Icons.remove_circle,
                      size: 20,
                      color: Colors.red,
                    ),
                    onTap: () {
                      setState(() {
                        images.replaceRange(index, index + 1, ['Add Image']);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return Card(
            color: Theme.of(context).backgroundColor,
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _onAddImageClick(index);
              },
            ),
          );
        }
      }),
    );
  }

  _body() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastrar Livro"),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: request.isReady,
        builder: (context, snapshot, widget) {
          if (!request.isReady.value) {
            return Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.only(top: 20, left: 40, right: 40),
              child: ListView(
                children: <Widget>[
                  buildGridView(),
                  /*ImageSelectorFormField(
                    backgroundColor: Colors.blueGrey,
                    borderRadius: 0,
                    onChanged: (img) async {
                      capa = img;
                    },
                  ),*/
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
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                  SizedBox(height: 15),
                  MultiSelect(
                      titleText: 'Autores',
                      hintText: 'Nenhum autor selecionado',
                      dataSource: request.autores.values
                          .map((e) => {'display': e.autor, 'value': e})
                          .toList(),
                      textField: 'display',
                      valueField: 'value',
                      filterable: true,
                      clearButtonTextColor: Colors.white,
                      saveButtonText: 'Salvar',
                      cancelButtonText: 'Cancelar',
                      clearButtonText: 'Limpar Tudo',
                      required: true,
                      value: null,
                      onSaved: (values) {
                        autores = List<Autor>.from(values);
                      }),
                  SizedBox(height: 15),
                  MultiSelect(
                      titleText: 'Categorias',
                      hintText: 'Nenhum autor selecionado',
                      dataSource: request.categorias.values
                          .where((element) => element.categoria != "Todas")
                          .map((e) => {'display': e.categoria, 'value': e})
                          .toList(),
                      textField: 'display',
                      valueField: 'value',
                      filterable: true,
                      clearButtonTextColor: Colors.white,
                      saveButtonText: 'Salvar',
                      cancelButtonText: 'Cancelar',
                      clearButtonText: 'Limpar Tudo',
                      required: true,
                      value: null,
                      onSaved: (values) {
                        categorias = List<Categoria>.from(values);
                      }),
                  SizedBox(height: 15),
                  MultiSelect(
                      titleText: 'Editora',
                      hintText: 'Nenhuma editora selecionado',
                      dataSource: request.editoras.values
                          .map((e) => {'display': e.editora, 'value': e})
                          .toList(),
                      maxLength: 1,
                      maxLengthText: '(max 1)',
                      textField: 'display',
                      valueField: 'value',
                      filterable: true,
                      clearButtonTextColor: Colors.white,
                      saveButtonText: 'Salvar',
                      cancelButtonText: 'Cancelar',
                      clearButtonText: 'Limpar Tudo',
                      required: true,
                      value: null,
                      onSaved: (values) {
                        if (values.isNotEmpty) {
                          editora = values.first;
                        } else {
                          editora = null;
                        }
                      }),
                  SizedBox(height: 15),
                  Container(
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
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
          );
        },
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
    double preco = double.parse(_tPreco.text);

    String errorMsg = '';

    if (!(images[0] is ImageUploadModel) &&
        !(images[1] is ImageUploadModel) &&
        !(images[2] is ImageUploadModel)) {
      errorMsg = "Você deve colocar pelo menos uma capa.";
    } else if (autores.length == 0) {
      errorMsg = "Nenhum autor foi selecionado.";
    } else if (categorias.length == 0) {
      errorMsg = "Nenhuma categoria foi selecionada.";
    } else if (editora == null) {
      errorMsg = "Nenhuma editora foi selecionada.";
    }

    if (errorMsg != null && errorMsg.isNotEmpty) {
      BotToast.showNotification(
        leading: (cancel) => SizedBox.fromSize(
            size: const Size(40, 40),
            child: IconButton(
              icon: Icon(Icons.warning_rounded, color: Colors.red),
              onPressed: cancel,
            )),
        title: (_) => Text('Ocorreu um erro ao cadastrar livro!'),
        subtitle: (_) => Text(errorMsg),
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

    setState(() {
      _cadastroVerified = false;
    });

    BotToast.showLoading(
      clickClose: false,
      allowClick: false,
      crossPage: false,
      backButtonBehavior: BackButtonBehavior.none,
      animationDuration: Duration(milliseconds: 200),
      animationReverseDuration: Duration(milliseconds: 200),
      backgroundColor: Color(0x42000000),
    );

    try {
      if (auth.currentUser == null) {
        return;
      }

      CollectionReference users = firestore.collection('users');

      DocumentSnapshot data = await users.doc(auth.currentUser.uid).get();

      if (data.data()['nivel'] != 1) {
        return;
      }

      CollectionReference books = firestore.collection('books');

      String book_id = books.doc().id;
      List<String> cover_url = new List(3);

      ImageUploadModel capa1, capa2, capa3;

      if (images[0] is ImageUploadModel) capa1 = images[0];
      if (images[1] is ImageUploadModel) capa2 = images[1];
      if (images[2] is ImageUploadModel) capa3 = images[2];

      try {
        List<Future<QuerySnapshot>> futures = new List();
        if (capa1 != null) {
          futures.add(firebase_storage.FirebaseStorage.instance
              .ref()
              .child('covers')
              .child('${book_id}-1')
              .putFile(capa1.imageFile)
              .then((value) async {
            print("Cover 1 Added");
            cover_url[0] = await value.ref.getDownloadURL();
          }).catchError((error) => print("Failed to add cover1: $error")));
        }
        if (capa2 != null) {
          futures.add(firebase_storage.FirebaseStorage.instance
              .ref()
              .child('covers')
              .child('${book_id}-2')
              .putFile(capa2.imageFile)
              .then((value) async {
            print("Cover 2 Added");
            cover_url[1] = await value.ref.getDownloadURL();
          }).catchError((error) => print("Failed to add cover2: $error")));
        }
        if (capa3 != null) {
          futures.add(firebase_storage.FirebaseStorage.instance
              .ref()
              .child('covers')
              .child('${book_id}-3')
              .putFile(capa3.imageFile)
              .then((value) async {
            print("Cover 3 Added");
            cover_url[2] = await value.ref.getDownloadURL();
          }).catchError((error) => print("Failed to add cover3: $error")));
        }
        await Future.wait(futures);
      } on firebase_storage.FirebaseException catch (e) {
        // e.g, e.code == 'canceled'
      }

      cover_url.forEach((element) {
        print(element);
      });

      await books.doc(book_id).set({
        'name': nome,
        'price': preco,
        'publisher': editora.id,
        'cover_url': cover_url,
        'deleted': false,
        'autor_id': autores.map((e) => e.id).toList(),
        'category_id': categorias.map((e) => e.id).toList()
      }).then((value) {
        print("Livro Added");

        BotToast.closeAllLoading();

        BotToast.showNotification(
          leading: (cancel) => SizedBox.fromSize(
              size: const Size(40, 40),
              child: IconButton(
                icon: Icon(Icons.assignment_turned_in, color: Colors.green),
                onPressed: cancel,
              )),
          title: (_) => Text('Livro cadastrado com sucesso!'),
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

        if (!mounted) return;

        Navigator.of(context).pop();

        setState(() {
          _cadastroVerified = true;
        });
      }).catchError((error) {
        print("Failed to add livro: $error");

        BotToast.closeAllLoading();

        BotToast.showNotification(
          leading: (cancel) => SizedBox.fromSize(
              size: const Size(40, 40),
              child: IconButton(
                icon: Icon(Icons.warning_rounded, color: Colors.red),
                onPressed: cancel,
              )),
          title: (_) => Text('Ocorreu um erro ao cadastrar livro!'),
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

        if (!mounted) return;

        setState(() {
          _cadastroVerified = true;
        });
      });

      /*autores.forEach((element) async {
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

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }
}

class ImageUploadModel {
  bool isUploaded;
  bool uploading;
  File imageFile;
  String imageUrl;

  ImageUploadModel({
    this.isUploaded,
    this.uploading,
    this.imageFile,
    this.imageUrl,
  });
}
