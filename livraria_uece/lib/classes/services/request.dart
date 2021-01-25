import "dart:convert";

import "package:livraria_uece/classes/livro/autor.dart";
import "package:livraria_uece/classes/livro/categoria.dart";
import "package:livraria_uece/classes/livro/editora.dart";
import "package:livraria_uece/classes/livro/livro.dart";

import "package:http/http.dart" as http;

class Request{

  Future<bool> isReady;
  
  Map<int,Autor> autores;
  Map<int,Categoria> categorias;
  Map<int,Editora> editoras;
  Map<int,Livro> livros;

  Request() {
    isReady = init();
  }

  Future<bool> init() async {
    List<Future<http.Response>> futures = [
      http.post("https://ddc.community/michael/getAutores.php"),
      http.post("https://ddc.community/michael/getCategorias.php"),
      http.post("https://ddc.community/michael/getEditoras.php"),
      http.post("https://ddc.community/michael/getLivros.php"),
      http.post("https://ddc.community/michael/getLivroAutores.php"),
      http.post("https://ddc.community/michael/getLivroCategorias.php"),
      http.post("https://ddc.community/michael/getAvaliacoes.php"),
    ];
    List responses = await Future.wait(futures);

    // AUTORES
    List data = json.decode(responses[0].body)["result"];
    autores = new Map();
    data.forEach((e) { autores[int.parse(e["id"])] = new Autor(int.parse(e['id']), e['nome']); });
    
    // CATEGORIAS
    data = json.decode(responses[1].body)["result"];
    categorias = new Map();
    data.forEach((e) { categorias[int.parse(e["id"])] = new Categoria(int.parse(e["id"]), e["nome"]); });

    // EDITORAS
    data = json.decode(responses[3].body)["result"];
    editoras = new Map();
    data.forEach((e) { editoras[int.parse(e["id"])] = new Editora(int.parse(e['id']), e["nome"]); });

    // LIVROS
    data = json.decode(responses[3].body)["result"];
    livros = new Map();
    data.forEach((e) {
      livros[int.parse(e["id"])] = new Livro(
        id: int.parse(e['id']),
        url_capa: e['url_capa'],
        titulo: e['nome'],
        preco: double.parse(e['preco']),
        autores: new List(),
        categorias: new List(),
        avaliacao: new List(),
      );
    });

    // LIVROAUTORES
    data = json.decode(responses[4].body)["result"];
    data.forEach((e) {
      livros[int.parse( e["livro_id"] )].autores.add( autores[int.parse(e["autor_id"])] );
    });

    // LIVROCATEGORIAS
    data = json.decode(responses[5].body)["result"];
    data.forEach((e) {
      livros[int.parse( e["livro_id"] )].categorias.add( categorias[int.parse(e["categoria_id"])] );
    });

    // AVALIACOES
    data = json.decode(responses[6].body)["result"];
    if(data != null) data.forEach((e) {
      livros[int.parse( e["livro_id"] )].addAvaliacao( int.parse(e["avaliacao"]) );
      // TODO avaliacao na conta
    });

    return true;
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

}