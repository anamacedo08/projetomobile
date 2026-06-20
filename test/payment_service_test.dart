import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:projetomobile/app/config/env_config.dart';
import 'package:projetomobile/core/database/database_service.dart';
import 'package:projetomobile/core/services/payment_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'payment_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late PaymentService paymentService;
  late MockClient mockClient;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dotenv.testLoad(fileInput: 'DB_NAME=test_db.db\nDB_VERSION=1\nPAYMENT_GATEWAY_KEY=test_key');
    await EnvConfig.initialize(isTest: true);
  });

  setUp(() async {
    await DatabaseService.instance.inicializarBanco(testPath: inMemoryDatabasePath);
    mockClient = MockClient();
    paymentService = PaymentService(client: mockClient);
  });

  test('CT12 - Sucesso no Pagamento', () async {
    final db = await DatabaseService.instance.database;
    await db.insert('pedidos', {
      'id': 'ORD_PAY',
      'valor': 50.0,
      'status': 'AGUARDANDO_PAGAMENTO'
    });

    when(mockClient.post(
      any,
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) async => http.Response(jsonEncode({'status': 'PAID'}), 200));

    final success = await paymentService.processarPagamentoApp('ORD_PAY', 'tok_123');
    expect(success, isTrue);

    final order = await db.query('pedidos', where: 'id = ?', whereArgs: ['ORD_PAY']);
    expect(order.first['status'], 'AGUARDANDO_INICIO');
  });

  test('CT13 - Falha no Gateway', () async {
    final db = await DatabaseService.instance.database;
    await db.insert('pedidos', {
      'id': 'ORD_FAIL',
      'valor': 50.0,
      'status': 'AGUARDANDO_PAGAMENTO'
    });

    when(mockClient.post(
      any,
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) async => http.Response(jsonEncode({'status': 'DECLINED'}), 400));

    final success = await paymentService.processarPagamentoApp('ORD_FAIL', 'tok_bad');
    expect(success, isFalse);

    final order = await db.query('pedidos', where: 'id = ?', whereArgs: ['ORD_FAIL']);
    expect(order.first['status'], 'AGUARDANDO_PAGAMENTO');
  });
}
