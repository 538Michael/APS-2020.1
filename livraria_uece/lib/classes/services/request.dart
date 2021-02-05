import "dart:convert";

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:livraria_uece/classes/livro/autor.dart";
import "package:livraria_uece/classes/livro/categoria.dart";
import "package:livraria_uece/classes/livro/editora.dart";
import "package:livraria_uece/classes/livro/livro.dart";

import "package:http/http.dart" as http;
import 'package:livraria_uece/classes/pedido/pedido.dart';

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
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  CollectionReference book_autor = FirebaseFirestore.instance.collection('book_autor');
  CollectionReference book_category = FirebaseFirestore.instance.collection('book_category');
  CollectionReference book_rating = FirebaseFirestore.instance.collection('book_rating');

  Request() {
    // isReady = init();
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
  /// `var livros = await request.getLivros(startAfter:'Jonas The Great', limit: 2);`
  /// 
  /// `print(livros);`
  Future<List<Livro>> getLivros2({String editoraId, String autorId, String categoriaId, String startAfter = '', int limit = 20}) async {
    print('começou');
    Stopwatch stopwatch = new Stopwatch()..start();
    List<Future> futures = new List();
    List<Livro> res = new List();
    
    Query ref = books;
    if(editoraId != null)
      ref = ref.where('publisher', isEqualTo: editoraId);
    else if(autorId != null)
      ref = ref.where('autor_id', arrayContains: autorId);
    else if(categoriaId != null)
      ref = ref.where('category_id', arrayContains: categoriaId);
    ref = ref.orderBy('name').startAfter([startAfter]).limit(limit);

    var docs = (await ref.get()).docs;
    for(int i=0; i<docs.length; i++){
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

      for(String autorId in l['autor_id']){
        futures.add(autors.doc(autorId).get().then((a){
          if(a.data() == null) return;
          res[i].newAutor(new Autor(a.id, a.data()['nome']));
        }));
      }

      for(String categoryId in l['category_id']){
        futures.add(categories.doc(categoryId).get().then((c){
          if(c.data() == null) return;
          res[i].newCategoria(new Categoria(c.id, c.data()['nome']));
        }));
      }

      futures.add(publishers.doc(l['publisher']).get().then((p){
        if(p.data() == null) return;
        res[i].editora = new Editora(p.id, p.data()['nome']); 
      }));

    }
    await Future.wait(futures);
    print('getLivros2() executed in ${stopwatch.elapsed.inMilliseconds}ms');
    return res;
  }

  Future<Livro> getLivro2(String livroId) async {
    var res = await books.doc(livroId).get();
    Livro livro = new Livro(
      autores: new List(),
      avaliacao: new List(),
      categorias: new List(),
      // editora: ,
      id: res.id,
      preco: res.data()['price'],
      titulo: res.data()['name'],
      url_capa: res.data()['cover_url'],
    );
    List<Future> futures = new List();
    for(String autorId in res.data()['autor_id']){
      futures.add(autors.doc(autorId).get().then((value){
        var autor = value.data();
        livro.newAutor(new Autor(autorId, autor['nome']));
      }));
    }
    for(String categoriaId in res.data()['category_id']){
      futures.add(categories.doc(categoriaId).get().then((value){
        var categoria = value.data();
        livro.newCategoria(new Categoria(categoriaId, categoria['nome']));
      }));
    }
    futures.add(publishers.doc(res.data()['publisher']).get().then((value){
      var editora = value.data();
      livro.editora = new Editora(res.data()['publisher'], editora['nome']);
    }));
    await Future.wait(futures);
    return livro;
  }

  Future<List<Pedido>> getPedidos(String userId) async {
    List<Future> futures = new List();
    List<Pedido> res = new List();
    var pedidos = (await orders.where('user_id', isEqualTo: userId).get()).docs;
    for(int i=0; i<pedidos.length; i++){
      res.add( new Pedido(pedidos[i]) );
      for(String livroId in res[i].items.keys){
        futures.add(getLivro2(livroId).then((livro){
          res[i].items[livroId].add(livro);
        }));
      }
    }
    await Future.wait(futures);
    return res;
  }

  String toString(){
    return '# '+autores.values.toString()+'\n# '+categorias.values.toString()+'\n# '+editoras.values.toString()+'\n# '+livros.values.toString();
  }

}