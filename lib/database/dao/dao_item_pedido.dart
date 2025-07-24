import 'package:doceria_app/database/dao/dao_produto.dart';
import 'package:doceria_app/database/db_helper.dart';
import 'package:doceria_app/model/item_pedido.dart';
import 'package:doceria_app/model/produto.dart';
import 'package:flutter/foundation.dart';

class ItemPedidoDAO {
  final ProdutoDAO produtoDAO = ProdutoDAO();

  Future<void> saveItemPedido(ItemPedido item) async {
    debugPrint("--- DAO: Salvando item para o pedido ID: ${item.pedido_id}, produto ID: ${item.produto_id} ---");
    final db = await DatabaseHelper().database;
    await db.insert('itens_pedido', item.toMap());
  }

  Future<List<ItemPedido>> getItensByPedidoId(int pedidoId) async {
    debugPrint("--- DAO: Buscando itens para o pedido ID: $pedidoId ---");
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'itens_pedido',
      where: 'pedido_id = ?',
      whereArgs: [pedidoId],
    );

    final itens = await Future.wait(maps.map((map) async {
      final Produto? produto = await produtoDAO.getProdutoById(map['produto_id']);
      return ItemPedido.fromMap(map, produto);
    }));
    
    debugPrint("--- DAO: ${itens.length} itens encontrados para o pedido ID: $pedidoId. ---");
    return itens;
  }
}