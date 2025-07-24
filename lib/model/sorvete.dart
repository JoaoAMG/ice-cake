import 'package:doceria_app/model/produto.dart';

class Sorvete extends Produto {
  final String sabor;
  final String mlTamanho;

  Sorvete({
    super.id, 
    required super.nome,
    required super.descricao,
    required super.preco,
    required this.sabor,
    required this.mlTamanho,
  });

  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'tipo_produto': 'SORVETE', 
      'sabor_sorvete': sabor,
      'ml_tamanho_sorvete': mlTamanho,
    };
  }

  
  factory Sorvete.fromMap(Map<String, dynamic> map) {
    return Sorvete(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      preco: map['preco'],
      sabor: map['sabor_sorvete'],
      mlTamanho: map['ml_tamanho_sorvete'],
    );
  }
}