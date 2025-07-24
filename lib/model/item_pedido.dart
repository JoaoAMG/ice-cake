import 'package:doceria_app/model/produto.dart';

class ItemPedido {
  final int? id;
  final int pedido_id;
  final int produto_id;
  final int quantidade;
  final double preco_unitario;
  
  
  final Produto? produto;

  ItemPedido({
    this.id,
    required this.pedido_id,
    required this.produto_id,
    required this.quantidade,
    required this.preco_unitario,
    this.produto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pedido_id': pedido_id,
      'produto_id': produto_id,
      'quantidade': quantidade,
      'preco_unitario': preco_unitario,
    };
  }

  
  
  factory ItemPedido.fromMap(Map<String, dynamic> map, [Produto? produto]) {
    return ItemPedido(
      id: map['id'],
      pedido_id: map['pedido_id'],
      produto_id: map['produto_id'],
      quantidade: map['quantidade'],
      preco_unitario: map['preco_unitario'],
      produto: produto,
    );
  }
}