import 'dart:async';

import 'package:livraria_uece/classes/services/request.dart';

void main(){
  auhe();
}

auhe() async {
  print("comecou");
  var request = new Request();
  await request.isReady;
  print("deu certo eu acho");
}

class classe{
  int _a;
  int b;
  classe(a,b){
    this._a = a;
    this.b = b;
  }
  void show(){
    print(_a);
    print(b);
  }
  set aa(k){b = k;}

  Future<int> get f {
    return Future.any([
      Future.delayed(Duration(seconds: 1),(){
        print('asda');
        return 123;
      }),
      Future.value(1234)
    ]);
  }

  int ff({a,b,c,d}){
    int soma = 0;
    print(a);
    print(b);
    print(c);
    print(d);
    return 0;
  }

}