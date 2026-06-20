import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../app/config/env_config.dart';

class DatabaseService {
  static DatabaseService? _instance;
  Database? _database;

  DatabaseService._internal();

  static DatabaseService get instance {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  // Alias for pseudocode "obterInstancia"
  static DatabaseService obterInstancia() => instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Getter for the connection as referred in pseudocode
  Database get conexaoBanco => _database!;

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, EnvConfig.dbName);
    
    return await openDatabase(
      path,
      version: EnvConfig.dbVersion,
      onCreate: _executarEsquemaInicial,
      onUpgrade: _executarMigracoes,
    );
  }

  // For compatibility with pseudocode call "inicializarBanco"
  Future<void> inicializarBanco() async {
    await database;
  }

  Future<void> _executarEsquemaInicial(Database db, int version) async {
    await db.execute("CREATE TABLE usuarios (id TEXT PRIMARY KEY, nome TEXT, email TEXT, senha_hash TEXT, perfil TEXT, push_token TEXT)");
    await db.execute("CREATE TABLE pedidos (id TEXT PRIMARY KEY, cliente_id TEXT, detalhes TEXT, status TEXT, endereco TEXT, codigo_rastreio TEXT, valor REAL, data_criacao TEXT)");
    
    // Injeção estrita e determinística do Administrador Inicial
    final idAdmin = const Uuid().v4();
    final bytes = utf8.encode("AdminArtesanal2026!");
    final senhaHashAdmin = sha256.convert(bytes).toString();
    
    await db.insert("usuarios", {
      "id": idAdmin,
      "nome": "Administrador Inicial",
      "email": "admin@artesanal.com",
      "senha_hash": senhaHashAdmin,
      "perfil": "ADMINISTRADOR"
    });
  }

  Future<void> _executarMigracoes(Database db, int oldVersion, int newVersion) async {
    // Bloco condicional para atualizações granulares de tabelas conforme evolução do esquema
  }
}
