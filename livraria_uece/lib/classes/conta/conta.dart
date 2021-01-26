class Conta {
  int _cpf;
  String _nome;
  int idade;
  String _senha;
  String _email;
  String _endereco;
  int _nivel = 0;

  void imprimir(){
    print("CPF: ${cpf}");
    print("Nome: ${nome}");
    print("Idade: ${idade}");
    print("Senha: ${senha}");
    print("Email: ${email}");
    print("Nivel: ${nivel}");
  }

  String get endereco => _endereco;

  set endereco(String value) {
    _endereco = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  int get cpf => _cpf;

  set cpf(int value) {
    _cpf = value;
  }

  int get nivel => _nivel;

  set nivel(int value) {
    _nivel = value;
  }
}