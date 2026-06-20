import 'package:flutter_test/flutter_test.dart';
import 'package:projetomobile/app/config/env_config.dart';
import 'package:projetomobile/core/database/database_service.dart';
import 'package:projetomobile/core/services/order_service.dart';
import 'package:projetomobile/core/models/usuario.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  late OrderService orderService;
  late Usuario admin;
  late Usuario atendente;
  late Usuario cliente;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dotenv.testLoad(fileInput: 'DB_NAME=test_db.db\nDB_VERSION=1');
    await EnvConfig.initialize(isTest: true);
  });

  setUp(() async {
    await DatabaseService.instance.inicializarBanco(testPath: inMemoryDatabasePath);
    orderService = OrderService();
    
    admin = Usuario(id: '1', nome: 'Admin', email: 'a@a.com', senhaHash: 'h', perfil: 'ADMINISTRADOR');
    atendente = Usuario(id: '2', nome: 'Atendente', email: 'at@at.com', senhaHash: 'h', perfil: 'ATENDENTE');
    cliente = Usuario(id: '3', nome: 'Cliente', email: 'c@c.com', senhaHash: 'h', perfil: 'CLIENTE');

    final db = await DatabaseService.instance.database;
    await db.insert('pedidos', {
      'id': 'ORD1',
      'cliente_id': '3',
      'detalhes': 'Test',
      'status': 'AGUARDANDO_INICIO',
      'valor': 100.0
    });
  });

  test('CT09 - Fluxo de Fabricação', () async {
    await orderService.iniciarFabricacaoManual('ORD1', atendente);
    
    final db = await DatabaseService.instance.database;
    final order = await db.query('pedidos', where: 'id = ?', whereArgs: ['ORD1']);
    expect(order.first['status'], 'EM_FABRICACAO');
  });

  test('CT10 - Registro de Envio', () async {
    final db = await DatabaseService.instance.database;
    await db.update('pedidos', {'status': 'EM_FABRICACAO'}, where: 'id = ?', whereArgs: ['ORD1']);
    
    await orderService.registrarEnvioLogistico('ORD1', 'TRACK123', atendente);
    
    final order = await db.query('pedidos', where: 'id = ?', whereArgs: ['ORD1']);
    expect(order.first['status'], 'ENVIADO');
    expect(order.first['codigo_rastreio'], 'TRACK123');
  });

  test('CT11 - Restrição de Perfil', () async {
    expect(
      () => orderService.iniciarFabricacaoManual('ORD1', cliente),
      throwsException
    );
  });
}
