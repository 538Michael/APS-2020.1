import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import "package:livraria_uece/classes/livro/autor.dart";
import "package:livraria_uece/classes/livro/categoria.dart";
import "package:livraria_uece/classes/livro/editora.dart";
import "package:livraria_uece/classes/livro/livro.dart";

class Request {
  final ValueNotifier<bool> isReady = ValueNotifier<bool>(false);

  Map<String, Autor> autores = new Map();
  Map<String, Categoria> categorias = new Map();
  Map<String, Editora> editoras = new Map();
  Map<String, Livro> livros = new Map();
  Map<String, Livro> allLivros = new Map();

  Categoria filterCategory;
  String filterName;

  CollectionReference autors = FirebaseFirestore.instance.collection('autors');
  CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');
  CollectionReference publishers =
      FirebaseFirestore.instance.collection('publishers');
  CollectionReference books = FirebaseFirestore.instance.collection('books');

  Request(
      {bool loadBooks,
      bool loadAutors,
      bool loadCategories,
      bool loadPublishers}) {
    init(
        loadBooks: loadBooks,
        loadAutors: loadAutors,
        loadCategories: loadCategories,
        loadPublishers: loadPublishers);
  }

  List<QueryDocumentSnapshot> booksDocs = [];

  void init(
      {bool loadBooks,
      bool loadAutors,
      bool loadCategories,
      bool loadPublishers}) async {
    loadBooks ??= false;
    loadAutors ??= false;
    loadCategories ??= false;
    loadPublishers ??= false;

    List<Future<QuerySnapshot>> futures = new List();
    Map<String, int> futuresIndex = new Map();

    if (loadAutors) {
      futuresIndex['Autors'] = futures.length;
      futures.add(autors.get());
    }
    if (loadCategories) {
      futuresIndex['Categories'] = futures.length;
      futures.add(categories.get());
    }
    if (loadPublishers) {
      futuresIndex['Publishers'] = futures.length;
      futures.add(publishers.get());
    }

    List<QuerySnapshot> responses = await Future.wait(futures);

    // AUTORES
    if (loadAutors) {
      List<QueryDocumentSnapshot> data = responses[futuresIndex['Autors']].docs;
      autores = new Map();
      data.forEach((e) {
        autores[e.id] = new Autor(e.id, e.data()['nome']);
      });
    }

    // CATEGORIAS
    if (loadCategories) {
      List<QueryDocumentSnapshot> data =
          responses[futuresIndex['Categories']].docs;
      categorias = new Map();
      categorias["Todas"] = new Categoria('Todas', 'Todas');
      data.forEach((e) {
        categorias[e.id] = new Categoria(e.id, e.data()["nome"]);
      });
    }

    // EDITORAS
    if (loadPublishers) {
      List<QueryDocumentSnapshot> data =
          responses[futuresIndex['Publishers']].docs;
      editoras = new Map();
      data.forEach((e) {
        editoras[e.id] = new Editora(e.id, e.data()["nome"]);
      });
    }

    if (loadBooks) {
      books.snapshots().listen((snapshot) {
        booksDocs = snapshot.docs;
        updateData();
      });
    } else {
      isReady.value = true;
    }
  }

  void updateData() async {
    isReady.value = false;
    await getLivros3(booksDocs);

    await categories.get().then((value) {
      categorias = new Map();
      categorias["Todas"] = new Categoria('Todas', 'Todas');
      value.docs.forEach((e) {
        categorias[e.id] = new Categoria(e.id, e.data()["nome"]);
      });
    });

    getLivrosFiltered();

    isReady.value = false;

    if (livros != null &&
        (livros.isNotEmpty || filterCategory != null) &&
        categorias != null &&
        categorias.isNotEmpty) {
      isReady.value = true;
    }
  }

  void getLivrosFiltered() {
    isReady.value = false;
    livros = new Map();
    print("Nome:" + filterName.toString());
    print(filterCategory.toString());
    if (allLivros != null) {
      allLivros.forEach((key, value) {
        if ((filterName == null ||
                value.titulo.toLowerCase().contains(filterName.toLowerCase()) ||
                value.editora.editora
                    .toLowerCase()
                    .contains(filterName.toLowerCase()) ||
                value.autores.firstWhere(
                        (element) => element.autor
                            .toLowerCase()
                            .contains(filterName.toLowerCase()),
                        orElse: () => null) !=
                    null) &&
            (filterCategory == null ||
                filterCategory.categoria == "Todas" ||
                value.categorias.firstWhere(
                        (element) => element.id == filterCategory.id,
                        orElse: () => null) !=
                    null)) {
          livros[value.id] = value;
        }
      });
    }
    isReady.value = true;
  }

  Autor getAutor(int id) {
    return autores[id];
  }

  Categoria getCategoria(int id) {
    return categorias[id];
  }

  List<Livro> getLivros() {
    return livros.values;
  }

  Livro getLivro(int id) {
    return livros[id];
  }

  /// [startAfter] é o nome do ultimo livro da pagina anterior.
  /// [limit] é a quantidade de resultados nesse consulta.
  ///
  /// Exemplo:
  ///
  /// `var livros = await request.getLivros(startAfter:'Jonas The Great', limit: 2);`
  ///
  /// `print(livros);`
  Future<List<Livro>> getLivros2({String startAfter = '', int limit}) async {
    //print('começou');
    Stopwatch stopwatch = new Stopwatch()..start();
    List<Future> futures = new List();
    List<Livro> res = new List();
    var docs = limit != null
        ? (await books
                .orderBy('name')
                .startAfter([startAfter])
                .limit(limit)
                .get())
            .docs
        : (await books.orderBy('name').startAfter([startAfter]).get()).docs;
    for (int i = 0; i < docs.length; i++) {
      var doc = docs[i];
      var l = doc.data();
      String id = doc.id;
      double preco = l['price'];
      String titulo = l['name'];
      String urlCapa = l['cover_url'];
      List<Autor> autores = new List();
      List<Categoria> categorias = new List();
      List<int> avaliacao = new List<int>();
      res.add(new Livro(
        id: id,
        preco: preco,
        titulo: titulo,
        url_capa: urlCapa,
        autores: autores,
        categorias: categorias,
        // editora: editora,
        avaliacao: avaliacao,
      ));
      for (String autorId in l['autor_id']) {
        futures.add(autors.doc(autorId).get().then((a) {
          if (a.data() == null) return;
          res[i].newAutor(new Autor(a.id, a.data()['nome']));
        }));
      }
      for (String categoryId in l['category_id']) {
        futures.add(categories.doc(categoryId).get().then((c) {
          if (c.data() == null) return;
          res[i].newCategoria(new Categoria(c.id, c.data()['nome']));
        }));
      }
      futures.add(publishers.doc(l['publisher']).get().then((p) {
        if (p.data() == null) return;
        res[i].editora = new Editora(p.id, p.data()['nome']);
      }));
    }
    await Future.wait(futures);
    //print('getLivros2() executed in ${stopwatch.elapsed.inMilliseconds}ms');
    return res;
  }

  void getLivros3(List<QueryDocumentSnapshot> docs) async {
    print('começou');
    Stopwatch stopwatch = new Stopwatch()..start();
    List<Future> futures = new List();
    allLivros = new Map();
    for (int i = 0; i < docs.length; i++) {
      var doc = docs[i];
      var l = doc.data();

      String id = doc.id;
      double preco = l['price'];
      String titulo = l['name'];
      String urlCapa = l['cover_url'];
      List<Autor> autores = new List();
      List<Categoria> categorias = new List();
      List<int> avaliacao = new List<int>();
      allLivros[doc.id] = new Livro(
        id: id,
        preco: preco,
        titulo: titulo,
        url_capa: urlCapa,
        autores: autores,
        categorias: categorias,
        avaliacao: avaliacao,
      );
      for (String autorId in l['autor_id']) {
        futures.add(autors.doc(autorId).get().then((a) {
          if (a.data() == null) return;
          allLivros[doc.id].newAutor(new Autor(a.id, a.data()['nome']));
        }));
      }
      for (String categoryId in l['category_id']) {
        futures.add(categories.doc(categoryId).get().then((c) {
          if (c.data() == null) return;
          allLivros[doc.id].newCategoria(new Categoria(c.id, c.data()['nome']));
        }));
      }
      futures.add(publishers.doc(l['publisher']).get().then((p) {
        if (p.data() == null) return;
        allLivros[doc.id].editora = new Editora(p.id, p.data()['nome']);
      }));
    }
    await Future.wait(futures);
    print('getLivros3() executed in ${stopwatch.elapsed.inMilliseconds}ms');
  }

  String toString() {
    return '# ' +
        autores.values.toString() +
        '\n# ' +
        categorias.values.toString() +
        '\n# ' +
        editoras.values.toString() +
        '\n# ' +
        livros.values.toString();
  }
}
