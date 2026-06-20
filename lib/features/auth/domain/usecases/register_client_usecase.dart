import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_service.dart';

class RegisterClientUseCase {
  final DatabaseService dbService;

  RegisterClientUseCase() : dbService = DatabaseService.obterInstancia();

  Future<void> executar(String nome, String email, String senhaPura, String enderecoPadrao) async {
    if (nome.isEmpty || email.isEmpty || senhaPura.isEmpty) {
      throw Exception("Todos os campos obrigatórios devem ser preenchidos.");
    }

    final db = await dbService.database;
    final emailsCadastrados = await db.query(
      "usuarios",
      where: "email = ?",
      whereArgs: [email],
    );

    if (emailsCadastrados.isNotEmpty) {
      throw Exception("O e-mail informado já está em uso por outro usuário.");
    }

    final novoClienteId = const Uuid().v4();
    final bytes = utf8.encode(senhaPura);
    final hashSenha = sha256.convert(bytes).toString();

    await db.insert("usuarios", {
      "id": novoClienteId,
      "nome": nome,
      "email": email,
      "senha_hash": hashSenha,
      "perfil": "CLIENTE"
    });
  }
}
