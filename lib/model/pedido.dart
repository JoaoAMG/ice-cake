import 'package:doceria_app/model/item_pedido.dart';



class Pedido {
  final int? id; 
  final int usuario_id; 
  final DateTime data_pedido;
  final double valor_total;

  
  
  
  final List<ItemPedido> itens;

  Pedido({
    this.id,
    required this.usuario_id,
    required this.data_pedido,
    required this.valor_total,
    required this.itens,
  });

  
  
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuario_id,
      
      'data_pedido': data_pedido.toIso8601String(),
      'valor_total': valor_total,
    };
  }

  
  
  
  factory Pedido.fromMap(Map<String, dynamic> map, List<ItemPedido> itens) {
    return Pedido(
      id: map['id'],
      usuario_id: map['usuario_id'],
      
      data_pedido: DateTime.parse(map['data_pedido']),
      valor_total: map['valor_total'],
      itens: itens,
    );
  }
}