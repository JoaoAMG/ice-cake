import 'package:doceria_app/database/db_helper.dart';
import 'package:doceria_app/model/endereco.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class EnderecoDAO {
  Future<int> saveEndereco(EnderecoModel endereco) async {
    debugPrint("--- DAO: Salvando endereço para usuário ID: ${endereco.usuario_id} ---");
    final db = await DatabaseHelper().database;
    final id = await db.insert(
      'enderecos',
      endereco.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint("--- DAO: Endereço salvo com ID: $id ---");
    return id;
  }

  Future<EnderecoModel?> getEnderecoByUsuarioId(int usuarioId) async {
    debugPrint("--- DAO: Buscando endereço para o usuário ID: $usuarioId ---");
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'enderecos',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );

    if (maps.isNotEmpty) {
      debugPrint("--- DAO: Endereço encontrado: ${maps.first} ---");
      return EnderecoModel.fromMap(maps.first);
    }
    debugPrint("--- DAO: Nenhum endereço encontrado para o usuário ID: $usuarioId ---");
    return null;
  }

  Future<int> deleteEndereco(int id) async {
    debugPrint("--- DAO: Deletando endereço com ID: $id ---");
    final db = await DatabaseHelper().database;
    final rowsAffected = await db.delete(
      'enderecos',
      where: 'id = ?',
      whereArgs: [id],
    );
    debugPrint("--- DAO: Deleção de endereço concluída. $rowsAffected linha(s) afetada(s). ---");
    return rowsAffected;
  }
}