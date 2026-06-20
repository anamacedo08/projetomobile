import 'package:flutter_test/flutter_test.dart';
import 'package:projetomobile/app/config/env_config.dart';
import 'package:projetomobile/core/database/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    
    dotenv.testLoad(fileInput: 'DB_NAME=test_db.db\nDB_VERSION=1');
    await EnvConfig.initialize(isTest: true);
  });

  test('CT04 - Criação de Tabelas e CT05 - Injeção de Admin', () async {
    final dbService = DatabaseService.instance;
    await dbService.inicializarBanco(testPath: inMemoryDatabasePath);
    final db = await dbService.database;

    // CT04 - Check tables
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    final tableNames = tables.map((row) => row['name'] as String).toList();
    
    expect(tableNames, contains('usuarios'));
    expect(tableNames, contains('pedidos'));
    expect(tableNames, contains('produtos'));

    // CT05 - Check Admin
    final admin = await db.query('usuarios', where: 'perfil = ?', whereArgs: ['ADMINISTRADOR']);
    expect(admin.length, 1);
    expect(admin.first['email'], 'admin@artesanal.com');

    // CT16 - Injeção de Produtos de Exemplo
    final products = await db.query('produtos');
    expect(products.length, 3);
  });

  test('CT19 - Migração e Seeding', () async {
    final dbService = DatabaseService.instance;
    final testPath = 'migration_test.db';
    
    // Simulate v1 database (without produtos table)
    final dbV1 = await openDatabase(testPath, version: 1, onCreate: (db, version) async {
      await db.execute("CREATE TABLE usuarios (id TEXT PRIMARY KEY, nome TEXT, email TEXT, senha_hash TEXT, perfil TEXT)");
    });
    await dbV1.close();

    // Now initialize with v2 (Enforced by EnvConfig in test setup)
    dotenv.testLoad(fileInput: 'DB_NAME=migration_test.db\nDB_VERSION=2');
    await EnvConfig.initialize(isTest: true);
    
    await dbService.inicializarBanco(testPath: testPath);
    final dbV2 = await dbService.database;

    final tables = await dbV2.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    expect(tables.map((row) => row['name']), contains('produtos'));

    final products = await dbV2.query('produtos');
    expect(products.length, 3);

    await dbV2.close();
    await deleteDatabase(testPath);
  });
}
