import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../database/database_service.dart';
import '../models/usuario.dart';

class AuthService {
  final DatabaseService dbService;
  Usuario? usuarioLogado;

  AuthService() : dbService = DatabaseService.obterInstancia();

  Future<bool> autenticar(String email, String senhaPura) async {
    final bytes = utf8.encode(senhaPura);
    final hashVerificacao = sha256.convert(bytes).toString();
    
    final db = await dbService.database;
    final resultadoQuery = await db.query(
      "usuarios",
      where: "email = ? AND senha_hash = ?",
      whereArgs: [email, hashVerificacao],
    );
    
    if (resultadoQuery.isNotEmpty) {
      usuarioLogado = Usuario.mapearDeObjeto(resultadoQuery.first);
      return true;
    }
    return false;
  }

  Future<void> cadastrarAtendente(String nome, String email, String senhaPura) async {
    if (usuarioLogado == null || usuarioLogado!.perfil != "ADMINISTRADOR") {
      throw Exception("Acesso negado: Operação exclusiva para administradores.");
    }

    final db = await dbService.database;
    final verificarEmail = await db.query(
      "usuarios",
      where: "email = ?",
      whereArgs: [email],
    );

    if (verificarEmail.isNotEmpty) {
      throw Exception("Este e-mail já possui cadastro associado.");
    }

    final novoId = const Uuid().v4();
    final bytes = utf8.encode(senhaPura);
    final hashSenha = sha256.convert(bytes).toString();

    await db.insert("usuarios", {
      "id": novoId,
      "nome": nome,
      "email": email,
      "senha_hash": hashSenha,
      "perfil": "ATENDENTE"
    });
  }
}
