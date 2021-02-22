import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:livraria_uece/classes/livro/autor.dart';
import 'package:livraria_uece/classes/livro/categoria.dart';
import 'package:livraria_uece/classes/livro/editora.dart';
import 'package:livraria_uece/classes/livro/livro.dart';
import 'package:livraria_uece/classes/services/request.dart';
import 'package:livraria_uece/extra/textformfield.dart';
import 'package:path_provider/path_provider.dart';

class EditarLivroPage extends StatefulWidget {
  Livro livro;

  EditarLivroPage({Livro livro}) {
    this.livro = new Livro(
        id: livro.id,
        titulo: livro.titulo,
        preco: livro.preco,
        editora: livro.editora,
        autores: livro.autores,
        categorias: livro.categorias,
        url_capa: livro.url_capa);
  }

  @override
  _EditarLivroPageState createState() => _EditarLivroPageState(livro: livro);
}

class _EditarLivroPageState extends State<EditarLivroPage> {
  final _formKey = GlobalKey<FormState>();

  final _tNome = TextEditingController();

  final _tPreco = TextEditingController();

  Livro livro;

  _EditarLivroPageState({Livro livro}) {
    this.livro = livro;
  }

  final request =
      new Request(loadPublishers: true, loadCategories: true, loadAutors: true);

  FirebaseAuth auth = FirebaseAuth.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  List<Autor> autores = new List();
  List<Categoria> categorias = new List();
  List<Editora> editoras = new List();

  File capa;

  @override
  void initState() {
    setState(() {
      images.add("Add Image");
      images.add("Add Image");
      images.add("Add Image");
    });

    request.isReady.addListener(() {
      updateLivro();
    });

    loadCovers();

    _tNome..text = livro.titulo;
    _tPreco..text = livro.preco.toString();

    super.initState();
  }

  void loadCovers() async {
    List<Future<File>> futures = new List(3);

    futures[0] = _fileFromImageUrl(livro.url_capa[0], 1);
    futures[1] = _fileFromImageUrl(livro.url_capa[1], 2);
    futures[2] = _fileFromImageUrl(livro.url_capa[2], 3);

    List<File> responses = await Future.wait(futures);

    for (var i = 0; i < responses.length; i++) {
      if (responses[i] == null) continue;
      setState(() {
        ImageUploadModel imageUpload = new ImageUploadModel();
        imageUpload.isUploaded = false;
        imageUpload.uploading = false;
        imageUpload.imageFile = responses[i];
        imageUpload.imageUrl = livro.url_capa[i];
        images.replaceRange(i, i + 1, [imageUpload]);
      });
    }

    imagesLoaded = true;
  }

  bool imagesLoaded = false;

  void updateLivro() {
    livro.autores = request.autores.values
        .where((element) => livro.autores
            .where((element2) => element2.id == element.id)
            .isNotEmpty)
        .toList();
    livro.categorias = request.categorias.values
        .where((element) => livro.categorias
            .where((element2) => element2.id == element.id)
            .isNotEmpty)
        .toList();
    livro.editora = request.editoras.values
        .firstWhere((element) => element.id == livro.editora.id);
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
    if (_imageFile == null) return;
    _imageFile.then((file) async {
      if (file == null) return;
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

  Future<File> _fileFromImageUrl(url, index) async {
    if (url == null) return null;
    final response = await http.get(url);

    final documentDirectory = await getApplicationDocumentsDirectory();

    final file = File('${documentDirectory.path}/${livro.id}-${index}.png');

    file.writeAsBytesSync(response.bodyBytes);

    return file;
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
                if (imagesLoaded) {
                  _onAddImageClick(index);
                }
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
        title: Text("Editar Livro"),
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
                      initialValue: livro.autores,
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
                        livro.autores = List<Autor>.from(values);
                      }),
                  SizedBox(height: 15),
                  MultiSelect(
                      titleText: 'Categorias',
                      hintText: 'Nenhum autor selecionado',
                      dataSource: request.categorias.values
                          .where((element) => element.categoria != "Todas")
                          .map((e) => {'display': e.categoria, 'value': e})
                          .toList(),
                      initialValue: livro.categorias,
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
                        livro.categorias = List<Categoria>.from(values);
                      }),
                  SizedBox(height: 15),
                  MultiSelect(
                      titleText: 'Editora',
                      hintText: 'Nenhuma editora selecionado',
                      dataSource: request.editoras.values
                          .map((e) => {'display': e.editora, 'value': e})
                          .toList(),
                      initialValue: [livro.editora],
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
                          livro.editora = values.first;
                        } else {
                          livro.editora = null;
                        }
                      }),
                  SizedBox(height: 15),
                  Container(
                    child: Container(
                      child: FlatButton(
                        color: Colors.pink,
                        child: Text(
                          "Salvar",
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

  void _onButtonClick(BuildContext context) async {
    FocusScope.of(context).unfocus();

    bool formOk = _formKey.currentState.validate();
    if (!formOk) {
      return;
    }

    String nome = _tNome.text;
    double preco = double.parse(_tPreco.text);

    String errorMsg = '';

    if (!imagesLoaded) {
      errorMsg = "As imagens das capas ainda estão carregando.";
    } else if (!(images[0] is ImageUploadModel) &&
        !(images[1] is ImageUploadModel) &&
        !(images[2] is ImageUploadModel)) {
      errorMsg = "Você deve colocar pelo menos uma capa.";
    } else if (livro.autores.length == 0) {
      errorMsg = "Nenhum autor foi selecionado.";
    } else if (livro.categorias.length == 0) {
      errorMsg = "Nenhuma categoria foi selecionada.";
    } else if (livro.editora == null) {
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

      if (images[0] is ImageUploadModel)
        capa1 = images[0];
      else
        livro.url_capa[0] = null;
      if (images[1] is ImageUploadModel)
        capa2 = images[1];
      else
        livro.url_capa[1] = null;
      if (images[2] is ImageUploadModel)
        capa3 = images[2];
      else
        livro.url_capa[2] = null;

      try {
        List<Future<QuerySnapshot>> futures = new List();
        if (capa1 != null && capa1.imageUrl == '') {
          futures.add(firebase_storage.FirebaseStorage.instance
              .ref()
              .child('covers')
              .child('${book_id}-1')
              .putFile(capa1.imageFile)
              .then((value) async {
            print("Cover 1 Added");
            livro.url_capa[0] = await value.ref.getDownloadURL();
          }).catchError((error) => print("Failed to add cover1: $error")));
        }
        if (capa2 != null && capa2.imageUrl == '') {
          futures.add(firebase_storage.FirebaseStorage.instance
              .ref()
              .child('covers')
              .child('${book_id}-2')
              .putFile(capa2.imageFile)
              .then((value) async {
            print("Cover 2 Added");
            livro.url_capa[1] = await value.ref.getDownloadURL();
          }).catchError((error) => print("Failed to add cover2: $error")));
        }
        if (capa3 != null && capa3.imageUrl == '') {
          futures.add(firebase_storage.FirebaseStorage.instance
              .ref()
              .child('covers')
              .child('${book_id}-3')
              .putFile(capa3.imageFile)
              .then((value) async {
            print("Cover 3 Added");
            livro.url_capa[2] = await value.ref.getDownloadURL();
          }).catchError((error) => print("Failed to add cover3: $error")));
        }
        await Future.wait(futures);
      } on firebase_storage.FirebaseException catch (e) {
        // e.g, e.code == 'canceled'
      }

      livro.url_capa.forEach((element) {
        print(element);
      });

      await books.doc(livro.id).update({
        'name': nome,
        'price': preco,
        'publisher': livro.editora.id,
        'cover_url': livro.url_capa,
        'autor_id': livro.autores.map((e) => e.id).toList(),
        'category_id': livro.categorias.map((e) => e.id).toList()
      }).then((value) {
        print("Livro Edited");

        BotToast.closeAllLoading();

        BotToast.showNotification(
          leading: (cancel) => SizedBox.fromSize(
              size: const Size(40, 40),
              child: IconButton(
                icon: Icon(Icons.assignment_turned_in, color: Colors.green),
                onPressed: cancel,
              )),
          title: (_) => Text('Livro editado com sucesso!'),
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

        Navigator.of(context).popUntil((route) => route.isFirst);
      }).catchError((error) {
        print("Failed to edit livro: $error");

        BotToast.closeAllLoading();

        BotToast.showNotification(
          leading: (cancel) => SizedBox.fromSize(
              size: const Size(40, 40),
              child: IconButton(
                icon: Icon(Icons.warning_rounded, color: Colors.red),
                onPressed: cancel,
              )),
          title: (_) => Text('Ocorreu um erro ao editar o livro!'),
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
      });
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
