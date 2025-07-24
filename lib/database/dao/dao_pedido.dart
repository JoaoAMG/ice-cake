import 'package:doceria_app/database/db_helper.dart';
import 'package:doceria_app/database/dao/dao_item_pedido.dart';
import 'package:doceria_app/model/item_pedido.dart';
import 'package:doceria_app/model/pedido.dart';
import 'package:flutter/foundation.dart';

class PedidoDAO {
  final ItemPedidoDAO itemPedidoDAO = ItemPedidoDAO();

  Future<void> savePedido(Pedido pedido) async {
    debugPrint("--- DAO: Salvando pedido para usuário ID: ${pedido.usuario_id} ---");
    final db = await DatabaseHelper().database;
    final pedidoId = await db.insert('pedidos', pedido.toMap());
    debugPrint("--- DAO: Cabeçalho do pedido salvo com ID: $pedidoId. Salvando ${pedido.itens.length} itens. ---");

    for (ItemPedido item in pedido.itens) {
      final itemComPedidoId = ItemPedido(
        pedido_id: pedidoId,
        produto_id: item.produto_id,
        quantidade: item.quantidade,
        preco_unitario: item.preco_unitario,
      );
      await itemPedidoDAO.saveItemPedido(itemComPedidoId);
    }
    debugPrint("--- DAO: Todos os itens do pedido ID: $pedidoId salvos com sucesso. ---");
  }

  Future<List<Pedido>> getPedidosByUsuarioId(int usuarioId) async {
    debugPrint("--- DAO: Buscando pedidos para o usuário ID: $usuarioId ---");
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pedidos',
      where: 'usuario_id = ?',
      orderBy: 'data_pedido DESC',
      whereArgs: [usuarioId],
    );

    List<Pedido> pedidos = [];
    for (var map in maps) {
      final pedidoId = map['id'];
      final itens = await itemPedidoDAO.getItensByPedidoId(pedidoId);
      pedidos.add(Pedido.fromMap(map, itens));
    }
    
    debugPrint("--- DAO: ${pedidos.length} pedidos encontrados para o usuário ID: $usuarioId. ---");
    return pedidos;
  }

  Future<List<Pedido>> getAllPedidos() async {
    debugPrint("--- DAO: Buscando TODOS os pedidos ---");
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pedidos',
      orderBy: 'data_pedido DESC',
    );

    List<Pedido> pedidos = [];
    for (var map in maps) {
      final pedidoId = map['id'];
      final itens = await itemPedidoDAO.getItensByPedidoId(pedidoId);
      pedidos.add(Pedido.fromMap(map, itens));
    }
    
    debugPrint("--- DAO: ${pedidos.length} pedidos encontrados no total. ---");
    return pedidos;
  }
}