import 'package:doceria_app/database/db_helper.dart';
import 'package:doceria_app/model/usuario.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';


class UsuarioDAO {
  
  Future<Usuario> saveUser(Usuario usuario) async {
    final db = await DatabaseHelper().database;
    debugPrint("--- DAO: Tentando salvar usuário tipo: ${usuario.tipo}, email: ${usuario.email} ---");

    Map<String, dynamic> dataMap;
    if (usuario is UsuarioCliente) {
      dataMap = usuario.toMap();
    } else if (usuario is UsuarioAdministrador) {
      dataMap = usuario.toMap();
    } else {
      throw Exception('Tipo de usuário desconhecido para salvar');
    }

    final newId = await db.insert(
      'usuarios',
      dataMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint("--- DAO: Usuário salvo com sucesso! ID gerado: $newId ---");

    if (usuario is UsuarioCliente) {
      return UsuarioCliente(id: newId, nome: usuario.nome, email: usuario.email, cpf: usuario.cpf, telefone: usuario.telefone, senha: usuario.senha);
    } else {
      return UsuarioAdministrador(id: newId, nome: usuario.nome, email: usuario.email, cpf: usuario.cpf, telefone: usuario.telefone, senha: usuario.senha);
    }
  }

  
  Future<Usuario?> getUserByEmail(String email) async {
    debugPrint("--- DAO: Buscando usuário pelo email: $email ---");
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      debugPrint("--- DAO: Usuário encontrado: $map ---");
      if (map['tipo_usuario'] == 'ADMINISTRADOR') {
        return UsuarioAdministrador.fromMap(map);
      } else {
        return UsuarioCliente.fromMap(map);
      }
    }
    
    debugPrint("--- DAO: Nenhum usuário encontrado com o email: $email ---");
    return null;
  }

  
  Future<int> updateUser(Usuario usuario) async {
    debugPrint("--- DAO: Tentando atualizar usuário ID: ${usuario.id} ---");
    final db = await DatabaseHelper().database;
    
    Map<String, dynamic> dataMap;
    if (usuario is UsuarioCliente) {
      dataMap = usuario.toMap();
    } else if (usuario is UsuarioAdministrador) {
      dataMap = usuario.toMap();
    } else {
      throw Exception('Tipo de usuário desconhecido para atualizar');
    }

    final rowsAffected = await db.update(
      'usuarios',
      dataMap,
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
    debugPrint("--- DAO: Atualização concluída. $rowsAffected linha(s) afetada(s). ---");
    return rowsAffected;
  } 
  
  Future<int> deleteUser(int id) async {
    debugPrint("--- DAO: Tentando deletar usuário ID: $id ---");
    final db = await DatabaseHelper().database;
    final rowsAffected = await db.delete(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
    debugPrint("--- DAO: Deleção concluída. $rowsAffected linha(s) afetada(s). ---");
    return rowsAffected;
  }
}