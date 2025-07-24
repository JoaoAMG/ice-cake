import 'package:doceria_app/database/db_helper.dart';
import 'package:doceria_app/model/bolo.dart';
import 'package:doceria_app/model/produto.dart';
import 'package:doceria_app/model/sorvete.dart';
import 'package:doceria_app/model/torta.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class ProdutoDAO {
  Future<int> saveProduto(Produto produto) async {
    debugPrint("--- DAO: Salvando produto: ${produto.nome} ---");
    final db = await DatabaseHelper().database;
    Map<String, dynamic> data;

    if (produto is Bolo) {
      data = produto.toMap();
    } else if (produto is Torta) {
      data = produto.toMap();
    } else if (produto is Sorvete) {
      data = produto.toMap();
    } else {
      throw Exception('Tipo de produto desconhecido');
    }

    final newId = await db.insert(
      'produtos',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint("--- DAO: Produto salvo com ID: $newId ---");
    return newId;
  }

  Future<List<Produto>> getAllProdutos() async {
    debugPrint("--- DAO: Buscando todos os produtos ---");
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('produtos');

    List<Produto> produtos = [];
    for (var map in maps) {
      String tipo = map['tipo_produto'];
      if (tipo == 'BOLO') {
        produtos.add(Bolo.fromMap(map));
      } else if (tipo == 'TORTA') {
        produtos.add(Torta.fromMap(map));
      } else if (tipo == 'SORVETE') {
        produtos.add(Sorvete.fromMap(map));
      }
    }
    debugPrint("--- DAO: ${produtos.length} produtos encontrados. ---");
    return produtos;
  }

  Future<Produto?> getProdutoById(int id) async {
    debugPrint("--- DAO: Buscando produto pelo ID: $id ---");
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'produtos',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      String tipo = map['tipo_produto'];
      debugPrint("--- DAO: Produto encontrado: $map ---");
      if (tipo == 'BOLO') {
        return Bolo.fromMap(map);
      } else if (tipo == 'TORTA') {
        return Torta.fromMap(map);
      } else if (tipo == 'SORVETE') {
        return Sorvete.fromMap(map);
      }
    }
    debugPrint("--- DAO: Nenhum produto encontrado com o ID: $id ---");
    return null;
  }

  Future<int> deleteProduto(int id) async {
    debugPrint("--- DAO: Deletando produto com ID: $id ---");
    final db = await DatabaseHelper().database;
    final rowsAffected = await db.delete(
      'produtos',
      where: 'id = ?',
      whereArgs: [id],
    );
    debugPrint("--- DAO: Deleção concluída. $rowsAffected linha(s) afetada(s). ---");
    return rowsAffected;
  }
}