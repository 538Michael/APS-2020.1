import "dart:convert";

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:livraria_uece/classes/livro/autor.dart";
import "package:livraria_uece/classes/livro/categoria.dart";
import "package:livraria_uece/classes/livro/editora.dart";
import "package:livraria_uece/classes/livro/livro.dart";

import "package:http/http.dart" as http;

class Request{

  Future<bool> isReady;
  
  Map<String,Autor> autores;
  Map<String,Categoria> categorias;
  Map<String,Editora> editoras;
  Map<String,Livro> livros;

  CollectionReference autors = FirebaseFirestore.instance.collection('autors');
  CollectionReference categories = FirebaseFirestore.instance.collection('categories');
  CollectionReference publishers = FirebaseFirestore.instance.collection('publishers');
  CollectionReference books = FirebaseFirestore.instance.collection('books');
  CollectionReference book_autor = FirebaseFirestore.instance.collection('book_autor');
  CollectionReference book_category = FirebaseFirestore.instance.collection('book_category');
  CollectionReference book_rating = FirebaseFirestore.instance.collection('book_rating');

  Request() {
    isReady = init();
  }

  Future<bool> init() async {
    List<Future<QuerySnapshot>> futures = [
      autors.get(),
      categories.get(),
      publishers.get(),
      books.get(),
      // book_autor.get(),
      // book_category.get(),
      // book_rating.get(),
    ];
    List<QuerySnapshot> responses = await Future.wait(futures);

    // AUTORES
    List<QueryDocumentSnapshot> data = responses[0].docs;
    autores = new Map();
    data.forEach((e) { autores[e.id] = new Autor(e.id, e.data()['nome']); });

   /* print("Autores:");
    autores.forEach((key, value) {
      print(key + " " + value.autor);
    });*/
    
    // CATEGORIAS
    data = responses[1].docs;
    categorias = new Map();
    categorias["Todas"] = new Categoria('Todas', 'Todas');
    data.forEach((e) { categorias[e.id] = new Categoria(e.id, e.data()["nome"]); });

    /*print("Categorias:");
    categorias.forEach((key, value) {
      print(key + " " + value.categoria);
    });*/

    // EDITORAS
    data = responses[2].docs;
    editoras = new Map();
    data.forEach((e) { editoras[e.id] = new Editora(e.id, e.data()["nome"]); });

    /*print("Editoras:");
    editoras.forEach((key, value) {
      print(key + " " + value.editora);
    });*/

    // LIVROS
    data = responses[3].docs;
    livros = new Map();
    data.forEach((e) {
      livros[e.id] = new Livro(
        id: e.id,
        url_capa: e.data()['cover_url'],
        titulo: e.data()['name'],
        preco: double.parse(e.data()['price'].toString()),
        editora: (e.data()["publisher"].toString().isNotEmpty) ? editoras[e.data()["publisher"]] : null,
        autores: autores.values.where((Autor a){
          return e.data()['autor_id'].firstWhere((id){
            return id == a.id;
          }, orElse: ()=>null ) != null;
        }).toList(),
        categorias: categorias.values.where((Categoria c){
          return e.data()['category_id'].firstWhere((id){
            return id == c.id;
          }, orElse: ()=>null ) != null;
        }).toList(),
      );
    });

    /*print("Livros:");
    livros.forEach((key, value) {
      print(key + " " + value.titulo);
    });*/

    // LIVROAUTORES
    // data = responses[4].docs;
    // data.forEach((e) {
    //   livros[e.data()['book_id']].autores.add( autores[e.data()['autor_id']] );
    // });

    // LIVROCATEGORIAS
    // data = responses[5].docs;
    // data.forEach((e) {
    //   livros[e.data()['book_id']].categorias.add( categorias[e.data()['category_id']] );
    // });

    /*// AVALIACOES
    data = responses[6].docs;
    if(data != null) data.forEach((e) {
      livros[e.data()['book_id']].newAvaliacao( int.parse(e.data()['rating'].toString()) );
      // TODO avaliacao na conta
    });*/

    return true;
  }

  Map<String, Livro> getLivrosFiltered(String nome, Categoria categoria){
    Map<String, Livro> livrosFiltrados = new Map();
    if(livros != null){
      livros.forEach((key, value) {
        if (
          (
              nome == null
              || value.titulo.toLowerCase().contains(nome.toLowerCase())
              || value.editora.editora.toLowerCase().contains(nome.toLowerCase())
              || value.autores.firstWhere( (element) => element == categoria, orElse: () => null) != null
          )
          && (
              categoria == null
              || categoria.categoria == "Todas"
              || value.categorias.firstWhere( (element) => element == categoria, orElse: () => null) != null
          )
        ) {
          livrosFiltrados[value.id] = value;
        }
      });
    }
    return livrosFiltrados;
  }

  Map<String, Livro> getLivrosFilteredByNome(String nome){
    Map<String, Livro> livrosFiltrados = new Map();
    if(livros != null){
      livros.forEach((key, value) {
        if (nome == null || value.titulo.toLowerCase().contains(nome.toLowerCase())) {
          livrosFiltrados[value.id] = value;
        }
      });
    }
    return livrosFiltrados;
  }

  Map<String, Livro> getLivrosFilteredByCategoria(Categoria categoria){
    Map<String, Livro> livrosFiltrados = new Map();
    if(livros != null){
      livros.forEach((key, value) {
        if (value.categorias.firstWhere(
                (element) => element == categoria,
            orElse: () => null) !=
            null) {
          livrosFiltrados[value.id] = value;
        }
      });
    }
    return livrosFiltrados;
  }

  Autor getAutor(int id){
    return autores[id];
  }
  Categoria getCategoria(int id){
    return categorias[id];
  }
  List<Livro> getLivros(){
    return livros.values;
  }
  Livro getLivro(int id){
    return livros[id];
  }

  /// [startAfter] é o nome do ultimo livro da pagina anterior.
  /// [limit] é a quantidade de resultados nesse consulta.
  /// 
  /// Exemplo: 
  /// 
  /// var livros = await request.getLivros(startAfter:'Jonas The Great', limit: 2);
  /// 
  /// print(livros);
  Future<List<Livro>> getLivros2({String startAfter = '', int limit}) async {
    List<Livro> res = new List();
    var docs = limit != null ?
      (await books.orderBy('name').startAfter([startAfter]).limit(limit).get()).docs : 
      (await books.orderBy('name').startAfter([startAfter]).get()).docs;
    for(var doc in docs){
      var l = doc.data();
      String id = doc.id;
      double preco = l['price'];
      String titulo = l['name'];
      String urlCapa = l['cover_url'];
      List<Autor> autores = new List();
      for(String autorId in l['autor_id']){
        var a = await autors.doc(autorId).get();
        autores.add(new Autor(a.id, a.data()['nome']));
      }
      List<Categoria> categorias = new List();
      for(String categoryId in l['category_id']){
        var c = await categories.doc(categoryId).get();
        categorias.add(new Categoria(c.id, c.data()['nome']));
      }
      var p = await publishers.doc(l['publisher']).get();
      Editora editora = new Editora(p.id, p.data()['nome']);
      List<int> avaliacao = new List<int>();
      res.add(new Livro(
        id: id,
        preco: preco,
        titulo: titulo,
        url_capa: urlCapa,
        autores: autores,
        categorias: categorias,
        editora: editora,
        avaliacao: avaliacao,
      ));
    }
    return res;
  }

  /// o outro getLivros2 ta muito lento... esse aqui é pra ficar melhor
  Future<List<Livro>> _getLivros2({String startAfter, int limit}) async {
    List<Livro> res = new List();
    var futures = [autors.get(), categories.get(), publishers.get()];
    futures.add(limit != null ?
      books.orderBy('name').startAfter([startAfter]).limit(limit).get() : 
      books.orderBy('name').startAfter([startAfter]).get()
    );
    await Future.wait(futures).then((value) => null);
    return res;
  }

  String toString(){
    return '# '+autores.values.toString()+'\n# '+categorias.values.toString()+'\n# '+editoras.values.toString()+'\n# '+livros.values.toString();
  }

}