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

  Future<Database> _initDatabase({String? testPath}) async {
    String path;
    if (testPath != null) {
      path = testPath;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      path = join(directory.path, EnvConfig.dbName);
    }
    
    return await openDatabase(
      path,
      version: EnvConfig.dbVersion,
      onCreate: _executarEsquemaInicial,
      onUpgrade: _executarMigracoes,
    );
  }

  // For compatibility with pseudocode call "inicializarBanco"
  Future<void> inicializarBanco({String? testPath}) async {
    if (_database != null) await _database!.close();
    _database = await _initDatabase(testPath: testPath);
    await _garantirProdutosIniciais(_database!);
  }

  Future<void> _executarEsquemaInicial(Database db, int version) async {
    await db.execute("CREATE TABLE usuarios (id TEXT PRIMARY KEY, nome TEXT, email TEXT, senha_hash TEXT, perfil TEXT, push_token TEXT)");
    await db.execute("CREATE TABLE pedidos (id TEXT PRIMARY KEY, cliente_id TEXT, detalhes TEXT, status TEXT, endereco TEXT, codigo_rastreio TEXT, valor REAL, data_criacao TEXT)");
    await db.execute("CREATE TABLE produtos (id TEXT PRIMARY KEY, nome TEXT, descricao TEXT, imagem_url TEXT, preco REAL)");
    
    // Injeção estrita e determinística do Administrador Inicial
    final idAdmin = const Uuid().v4();
    final bytes = utf8.encode("1234");
    final senhaHashAdmin = sha256.convert(bytes).toString();
    
    await db.insert("usuarios", {
      "id": idAdmin,
      "nome": "Administrador Inicial",
      "email": "admin@artesanal.com",
      "senha_hash": senhaHashAdmin,
      "perfil": "ADMINISTRADOR"
    });
  }

  Future<void> _garantirProdutosIniciais(Database db) async {
    // Garante que a tabela existe mesmo que venha de uma versão anterior sem ela
    await db.execute("CREATE TABLE IF NOT EXISTS produtos (id TEXT PRIMARY KEY, nome TEXT, descricao TEXT, imagem_url TEXT, preco REAL)");

    final List<Map<String, dynamic>> products = await db.query('produtos');
    if (products.isEmpty) {
      final uuid = const Uuid();
      await db.insert("produtos", {
        "id": uuid.v4(),
        "nome": "Vaso de Cerâmica",
        "descricao": "Vaso artesanal feito à mão",
        "imagem_url": "https://picsum.photos/200",
        "preco": 45.0
      });
      await db.insert("produtos", {
        "id": uuid.v4(),
        "nome": "Cesto de Mimosa",
        "descricao": "Cesto trançado com fibras naturais",
        "imagem_url": "https://picsum.photos/201",
        "preco": 30.0
      });
      await db.insert("produtos", {
        "id": uuid.v4(),
        "nome": "Tapete de Tear",
        "descricao": "Tapete de algodão tecido em tear manual",
        "imagem_url": "https://picsum.photos/202",
        "preco": 120.0
      });
    }
  }

  Future<void> _executarMigracoes(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("CREATE TABLE IF NOT EXISTS produtos (id TEXT PRIMARY KEY, nome TEXT, descricao TEXT, imagem_url TEXT, preco REAL)");
    }
  }
}
