import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:projetomobile/app/config/env_config.dart';

void main() {
  test('CT01 - Inicialização com Sucesso', () async {
    // Setup mock .env content
    dotenv.testLoad(fileInput: '''
      APP_ENV=test
      DB_NAME=test.db
      DB_VERSION=2
    ''');

    await EnvConfig.initialize(isTest: true);

    expect(EnvConfig.appEnv, 'test');
    expect(EnvConfig.dbName, 'test.db');
    expect(EnvConfig.dbVersion, 2);
  });

  test('CT02 - Fallback de Valores', () async {
    dotenv.testLoad(fileInput: ''); // Empty .env

    await EnvConfig.initialize(isTest: true);

    expect(EnvConfig.appEnv, 'development');
    expect(EnvConfig.dbName, 'artesanal.db');
    expect(EnvConfig.dbVersion, 1);
  });
}
