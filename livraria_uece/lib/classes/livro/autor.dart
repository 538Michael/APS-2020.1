class Autor {
  int _id;
  String _autor;

  Autor(this._id, this._autor);

  String get autor => _autor;

  set autor(String value) {
    _autor = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  String toString(){
    return "Autor "+_id.toString()+' '+_autor.toString();
  }
}