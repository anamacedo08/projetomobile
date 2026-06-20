import 'package:flutter_test/flutter_test.dart';
import 'package:projetomobile/app/config/env_config.dart';
import 'package:projetomobile/core/database/database_service.dart';
import 'package:projetomobile/features/auth/domain/usecases/register_client_usecase.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  late RegisterClientUseCase registerUseCase;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dotenv.testLoad(fileInput: 'DB_NAME=test_db.db\nDB_VERSION=1');
    await EnvConfig.initialize(isTest: true);
  });

  setUp(() async {
    await DatabaseService.instance.inicializarBanco(testPath: inMemoryDatabasePath);
    registerUseCase = RegisterClientUseCase();
  });

  test('CT14 - E-mail Duplicado', () async {
    await registerUseCase.executar('User 1', 'user@test.com', 'pass', 'addr');
    
    expect(
      () => registerUseCase.executar('User 2', 'user@test.com', 'pass', 'addr'),
      throwsException
    );
  });

  test('CT15 - Validação de Campos', () async {
    expect(
      () => registerUseCase.executar('', 'user@test.com', 'pass', 'addr'),
      throwsException
    );
  });
}
