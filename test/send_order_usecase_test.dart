import 'package:flutter_test/flutter_test.dart';
import 'package:projetomobile/app/config/env_config.dart';
import 'package:projetomobile/core/database/database_service.dart';
import 'package:projetomobile/features/orders/domain/usecases/send_order_usecase.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  late SendOrderUseCase sendOrderUseCase;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dotenv.testLoad(fileInput: 'DB_NAME=test_db.db\nDB_VERSION=1');
    await EnvConfig.initialize(isTest: true);
  });

  setUp(() async {
    await DatabaseService.instance.inicializarBanco(testPath: inMemoryDatabasePath);
    sendOrderUseCase = SendOrderUseCase();
  });

  test('Deve criar um pedido com sucesso', () async {
    final orderId = await sendOrderUseCase.executar('CLIENTE_1', 'Customização X', 'Rua A, 123', 150.0);
    expect(orderId, isNotEmpty);

    final db = await DatabaseService.instance.database;
    final order = await db.query('pedidos', where: 'id = ?', whereArgs: [orderId]);
    expect(order.length, 1);
    expect(order.first['status'], 'AGUARDANDO_PAGAMENTO');
  });

  test('Deve falhar se dados forem inválidos', () async {
    expect(
      () => sendOrderUseCase.executar('CLIENTE_1', '', 'Rua A, 123', 150.0),
      throwsException
    );
  });
}
