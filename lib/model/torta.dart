import 'package:doceria_app/model/produto.dart';

class Torta extends Produto {
  final String categoria;
  final double peso;

  Torta({
    super.id, 
    required super.nome,
    required super.descricao,
    required super.preco,
    required this.categoria,
    required this.peso,
  });

  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'tipo_produto': 'TORTA', 
      'categoria_torta': categoria,
      'peso_torta': peso,
    };
  }

  
  factory Torta.fromMap(Map<String, dynamic> map) {
    return Torta(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      preco: map['preco'],
      categoria: map['categoria_torta'],
      peso: map['peso_torta'],
    );
  }
}