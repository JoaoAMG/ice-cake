import 'package:doceria_app/model/endereco.dart';

abstract class Usuario {
  final int? id;
  final String nome;
  final String email;
  final String cpf;
  final String telefone;
  final String senha;
  final EnderecoModel? endereco;
  
  String get tipo;

  Usuario({ this.id, required this.nome, required this.email, required this.cpf, required this.telefone, required this.senha, this.endereco });
}

class UsuarioCliente extends Usuario {
  @override
  final String tipo = 'CLIENTE'; 

  UsuarioCliente({ super.id, required super.nome, required super.email, required super.cpf, required super.telefone, required super.senha, super.endereco });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'senha': senha,
      'tipo_usuario': tipo, 
    };
  }

  factory UsuarioCliente.fromMap(Map<String, dynamic> map) {
    return UsuarioCliente(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      cpf: map['cpf'],
      telefone: map['telefone'],
      senha: map['senha'],
    );
  }
}

class UsuarioAdministrador extends Usuario {
  @override
  final String tipo = 'ADMINISTRADOR'; 

  UsuarioAdministrador({ super.id, required super.nome, required super.email, required super.cpf, required super.telefone, required super.senha, super.endereco });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'senha': senha,
      'tipo_usuario': tipo, 
    };
  }

  factory UsuarioAdministrador.fromMap(Map<String, dynamic> map) {
    return UsuarioAdministrador(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      cpf: map['cpf'],
      telefone: map['telefone'],
      senha: map['senha'],
    );
  }
}