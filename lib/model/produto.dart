abstract class Produto {
  
  
  
  final int? id;
  final String nome;
  final String descricao;
  final double preco;

  Produto({
    this.id, 
    required this.nome,
    required this.descricao,
    required this.preco,
  });
}