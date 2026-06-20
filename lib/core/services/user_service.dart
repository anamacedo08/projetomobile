import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../database/database_service.dart';
import '../models/usuario.dart';

class UserService {
  final DatabaseService dbService;

  UserService() : dbService = DatabaseService.obterInstancia();

  Future<List<Usuario>> getAttendants() async {
    final db = await dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'perfil = ?',
      whereArgs: ['ATENDENTE'],
    );
    return List.generate(maps.length, (i) => Usuario.fromMap(maps[i]));
  }

  Future<void> updateAttendant(Usuario usuario) async {
    final db = await dbService.database;
    await db.update(
      'usuarios',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  Future<void> deleteUser(String id) async {
    final db = await dbService.database;
    await db.delete(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
