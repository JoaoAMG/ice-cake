import 'package:doceria_app/model/produto.dart';

class Bolo extends Produto {
  final String categoria;
  final int pedacos;

  Bolo({
    super.id, 
    required super.nome,
    required super.descricao,
    required super.preco,
    required this.categoria,
    required this.pedacos,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'tipo_produto': 'BOLO', 
      'categoria_bolo': categoria,
      'pedacos_bolo': pedacos,
    };
  }

  factory Bolo.fromMap(Map<String, dynamic> map) {
    return Bolo(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      preco: map['preco'],
      categoria: map['categoria_bolo'],
      pedacos: map['pedacos_bolo'],
    );
  }
}