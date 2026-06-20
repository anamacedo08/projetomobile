import 'package:flutter_test/flutter_test.dart';
import 'package:projetomobile/app/config/env_config.dart';
import 'package:projetomobile/core/database/database_service.dart';
import 'package:projetomobile/core/services/auth_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  late AuthService authService;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dotenv.testLoad(fileInput: 'DB_NAME=test_db.db\nDB_VERSION=1');
    await EnvConfig.initialize(isTest: true);
  });

  setUp(() async {
    await DatabaseService.instance.inicializarBanco(testPath: inMemoryDatabasePath);
    authService = AuthService();
  });

  test('CT06 - Login Válido e CT07 - Login Inválido', () async {
    // Admin is injected by default
    final success = await authService.autenticar('admin@artesanal.com', '1234');
    expect(success, isTrue);
    expect(authService.usuarioLogado, isNotNull);
    expect(authService.usuarioLogado!.perfil, 'ADMINISTRADOR');

    final failure = await authService.autenticar('admin@artesanal.com', 'wrong_password');
    expect(failure, isFalse);
  });

  test('CT08 - Permissão de Administrador', () async {
    // Login as admin first
    await authService.autenticar('admin@artesanal.com', 'AdminArtesanal2026!');
    
    // Register an atendente
    await authService.cadastrarAtendente('Atendente 1', 'atendente@test.com', 'password123');
    
    // Verify it was created
    final db = await DatabaseService.instance.database;
    final users = await db.query('usuarios', where: 'email = ?', whereArgs: ['atendente@test.com']);
    expect(users.length, 1);
    expect(users.first['perfil'], 'ATENDENTE');
    
    // Login as the new atendente
    await authService.autenticar('atendente@test.com', 'password123');
    
    // Try to register another atendente (should fail)
    expect(
      () => authService.cadastrarAtendente('Another', 'another@test.com', 'pass'),
      throwsException
    );
  });

  test('CT20 - Logout', () async {
    await authService.autenticar('admin@artesanal.com', 'AdminArtesanal2026!');
    expect(authService.usuarioLogado, isNotNull);

    authService.logout();
    expect(authService.usuarioLogado, isNull);
  });
}
