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
    // Overriding the path for testing to use in-memory or a specific test file
    // Actually, sqflite_ffi uses the path provided. 
    // We'll just let it run.
    
    await dbService.inicializarBanco(testPath: inMemoryDatabasePath);
    final db = await dbService.database;

    // CT04 - Check tables
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    final tableNames = tables.map((row) => row['name'] as String).toList();
    
    expect(tableNames, contains('usuarios'));
    expect(tableNames, contains('pedidos'));

    // CT05 - Check Admin
    final admin = await db.query('usuarios', where: 'perfil = ?', whereArgs: ['ADMINISTRADOR']);
    expect(admin.length, 1);
    expect(admin.first['email'], 'admin@artesanal.com');
  });
}
