import 'package:flutter_test/flutter_test.dart';
import 'package:projetomobile/app/config/env_config.dart';
import 'package:projetomobile/core/database/database_service.dart';
import 'package:projetomobile/features/catalogo/domain/usecases/get_products_usecase.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  late GetProductsUseCase getProductsUseCase;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dotenv.testLoad(fileInput: 'DB_NAME=test_db.db\nDB_VERSION=1');
    await EnvConfig.initialize(isTest: true);
  });

  setUp(() async {
    await DatabaseService.instance.inicializarBanco(testPath: inMemoryDatabasePath);
    getProductsUseCase = GetProductsUseCase();
  });

  test('CT17 - Carregamento de Catálogo', () async {
    final products = await getProductsUseCase.executar();
    
    expect(products.length, 3);
    expect(products.any((p) => p.nome == "Vaso de Cerâmica"), isTrue);
    expect(products.any((p) => p.nome == "Cesto de Mimosa"), isTrue);
    expect(products.any((p) => p.nome == "Tapete de Tear"), isTrue);
  });
}
