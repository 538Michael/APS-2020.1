import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/carrinhodecompra/carrinhodecompra.dart';
import 'package:livraria_uece/classes/carrinhodecompra/itemdecarrinho.dart';
import "package:livraria_uece/classes/livro/autor.dart";
import "package:livraria_uece/classes/livro/categoria.dart";
import "package:livraria_uece/classes/livro/editora.dart";
import "package:livraria_uece/classes/livro/livro.dart";

class Request {
  final ValueNotifier<bool> isReady = ValueNotifier<bool>(false);
  final ValueNotifier<bool> updating = ValueNotifier<bool>(false);
  final ValueNotifier<bool> updatingAutors = ValueNotifier<bool>(false);
  final ValueNotifier<bool> updatingCategories = ValueNotifier<bool>(false);
  final ValueNotifier<bool> updatingPublishers = ValueNotifier<bool>(false);

  CarrinhoDeCompra carrinho = new CarrinhoDeCompra();
  Map<String, Autor> autores = new Map();
  Map<String, Categoria> categorias = new Map();
  Map<String, Editora> editoras = new Map();
  Map<String, Livro> livros = new Map();
  Map<String, Livro> allLivros = new Map();

  Categoria filterCategory;
  String filterName;

  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference autors = FirebaseFirestore.instance.collection('autors');
  CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');
  CollectionReference publishers =
      FirebaseFirestore.instance.collection('publishers');
  CollectionReference books = FirebaseFirestore.instance.collection('books');
  CollectionReference shoppingCart =
      FirebaseFirestore.instance.collection('shopping_cart');

  List<QueryDocumentSnapshot> booksDocs = [];

  bool loadBooks;
  bool loadAutors;
  bool loadAutorsIRT;
  bool loadCategories;
  bool loadCategoriesIRL;
  bool loadPublishers;
  bool loadPublishersIRL;
  bool loadShoppingCart;

  Request(
      {Key key,
      this.loadBooks = false,
      this.loadAutors = false,
      this.loadAutorsIRT = false,
      this.loadCategories = false,
      this.loadCategoriesIRL = false,
      this.loadPublishers = false,
      this.loadPublishersIRL = false,
      this.loadShoppingCart = false}) {
    init();
  }

  void init() async {
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
    } else if (loadAutorsIRT) {
      autors.snapshots().listen((snapshot) {
        updateAutors(snapshot.docs);
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
    } else if (loadCategoriesIRL) {
      categories.snapshots().listen((snapshot) {
        updateCategories(snapshot.docs);
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
    } else if (loadPublishersIRL) {
      publishers.snapshots().listen((snapshot) {
        updatePublishers(snapshot.docs);
      });
    }

    if (loadBooks) {
      autors.snapshots().listen((snapshot) {
        updateBooks(booksDocs);
      });
      categories.snapshots().listen((snapshot) {
        updateBooks(booksDocs);
      });
      publishers.snapshots().listen((snapshot) {
        updateBooks(booksDocs);
      });
      books.snapshots().listen((snapshot) {
        booksDocs = snapshot.docs;
        updateBooks(booksDocs);
      });
    } else {
      isReady.value = true;
    }

    if (loadShoppingCart) {
      _loadShoppingCart();
    }
  }

  void reloadShoppingCart() async {
    updating.value = true;
    if (auth.currentUser != null) {
      carrinho.carrinhoClear();
      await shoppingCart
          .where('user_id', isEqualTo: auth.currentUser.uid)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.single.data()['items'].forEach((key, value) {
          carrinho.addLivro(allLivros[key], quantidade: value);
        });
      });
    }
    updating.value = false;
  }

  void _loadShoppingCart() async {
    updating.value = true;

    if (auth.currentUser != null) {
      CollectionReference shoppingCart =
          FirebaseFirestore.instance.collection('shopping_cart');
      if (carrinho.carrinho.isEmpty) {
        await shoppingCart.doc(auth.currentUser.uid).get().then(
            (documentSnapshot) => documentSnapshot.data()['items'].forEach(
                (key, value) =>
                    carrinho.addLivro(allLivros[key], quantidade: value)));
      }
    }

    updating.value = false;
  }

  void updateAutors(List<QueryDocumentSnapshot> data) {
    updatingAutors.value = true;
    autores = new Map();
    data.forEach((e) {
      autores[e.id] = new Autor(e.id, e.data()['nome']);
    });
    updatingAutors.value = false;
    print('Autores atualizado');
  }

  void updateCategories(List<QueryDocumentSnapshot> data) {
    updatingCategories.value = true;
    categorias = new Map();
    categorias["Todas"] = new Categoria('Todas', 'Todas');
    data.forEach((e) {
      categorias[e.id] = new Categoria(e.id, e.data()["nome"]);
    });
    updatingCategories.value = false;
    print('Categorias atualizado');
  }

  void updatePublishers(List<QueryDocumentSnapshot> data) {
    updatingPublishers.value = true;
    editoras = new Map();
    data.forEach((e) {
      editoras[e.id] = new Editora(e.id, e.data()["nome"]);
    });
    updatingPublishers.value = false;
    print('Editoras atualizado');
  }

  void updateBooks(List<QueryDocumentSnapshot> data) async {
    print('atualizando');
    isReady.value = false;
    await getLivros3(data);

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

  void addShoppingCart(Livro livro, {int quantidade = 1}) async {
    if (auth.currentUser != null) {
      await shoppingCart
          .doc(auth.currentUser.uid)
          .update({
            'items.' + livro.id.toString(): FieldValue.increment(quantidade)
          })
          .then((value) => print('Book Added'))
          .catchError((error) => print("Failed to add book: $error"));
    }
    carrinho.addLivro(livro, quantidade: quantidade);
  }

  void updateShoppingCartOnLogin() async {
    if (auth.currentUser != null) {
      await shoppingCart.doc(auth.currentUser.uid).update({
        'items': Map<String, int>.fromIterable(carrinho.carrinho,
            key: (item) => item.livro.id, value: (item) => item.quantidade)
      });
    }
  }

  void removeShoppingCart(Livro livro, {bool removeCompleto = false}) async {
    if (carrinho.searchBook(livro) == false) return;

    if (auth.currentUser != null) {
      CollectionReference shoppingCart =
          FirebaseFirestore.instance.collection('shopping_cart');
      DocumentSnapshot query =
          await shoppingCart.doc(auth.currentUser.uid).get();

      int quantidade = query.data()['items'][livro.id] - 1;
      if (quantidade <= 0 || removeCompleto) {
        shoppingCart
            .doc(auth.currentUser.uid)
            .update({'items.' + livro.id.toString(): FieldValue.delete()});
      } else {
        shoppingCart
            .doc(auth.currentUser.uid)
            .update({'items.' + livro.id.toString(): quantidade})
            .then((value) => print('Book Removed'))
            .catchError((error) => print("Failed to remove book: $error"));
      }
    }
    if (removeCompleto) {
      carrinho.removeLivro(livro);
    } else {
      carrinho.removeLivroUnidade(livro);
    }
  }

  void clearShoppingCart() async {
    if (auth.currentUser != null) {
      CollectionReference shoppingCart =
          FirebaseFirestore.instance.collection('shopping_cart');
      shoppingCart.doc(auth.currentUser.uid).update({
        'items': new Map<String, int>(),
      });
    }
  }

  List<T> cutList<T>(List<T> oldList, int newLength) {
    return new List.generate(newLength, (index) {
      if (index < oldList.length) return oldList[index];
      else return null;
    });
  }

  void getLivros3(List<QueryDocumentSnapshot> docs) async {
    List<Future> futures = new List();
    allLivros = new Map();
    for (int i = 0; i < docs.length; i++) {
      var doc = docs[i];
      var l = doc.data();

      String id = doc.id;
      double preco = l['price'];
      String titulo = l['name'];
      List<String> urlCapa = cutList(List<String>.from(l['cover_url']), 3);
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
      if(l['publisher'] != null && l['publisher'] != ''){
        futures.add(publishers.doc(l['publisher']).get().then((p) {
          if (p.data() == null) return;
          allLivros[doc.id].editora = new Editora(p.id, p.data()['nome']);
        }));
      }
    }
    await Future.wait(futures);
  }

  Future<List<ItemDeCarrinho>> getStats(DateTimeRange dateRange) async {
    var orders = await FirebaseFirestore.instance
        .collection('orders')
        .where('created_at',
            isGreaterThanOrEqualTo: dateRange.start.millisecondsSinceEpoch)
        .where('created_at',
            isLessThanOrEqualTo: dateRange.end.millisecondsSinceEpoch)
        .get()
        .then((snapshot) => snapshot.docs.map((e) => e.data()).toList());
    Map<String, int> freq = new Map();
    for (var order in orders) {
      order['items'].forEach((String id, detail) {
        if (freq.containsKey(id) == false) freq[id] = 0;
        freq[id] += detail[0];
      });
    }
    List<ItemDeCarrinho> items = new List();
    List<Future> futures = new List();
    freq.forEach((id, qtde) {
      futures.add(books
          .doc(id)
          .get()
          .then((snapshot) => snapshot.data())
          .then((a) => new Livro(
                id: id,
                titulo: a['name'],
                preco: a['price'] * (a['payment_method'] == 0 ? 1 : 0.9),
                url_capa: List<String>.from(a['cover_url']),
              ))
          .then((livro) {
        items.add(new ItemDeCarrinho(livro, qtde));
      }));
    });
    await Future.wait(futures);
    return items;
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
