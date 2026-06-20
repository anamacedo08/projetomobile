import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projetomobile/app/config/env_config.dart';
import 'package:projetomobile/core/database/database_service.dart';
import 'package:projetomobile/features/catalogo/presentation/screens/vitrine_produtos_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dotenv.testLoad(fileInput: 'DB_NAME=test_db.db\nDB_VERSION=1');
    await EnvConfig.initialize(isTest: true);
  });

  testWidgets('CT18 - Exibição na UI (Widget Test)', (WidgetTester tester) async {
    // Initialize DB with seed data
    await DatabaseService.instance.inicializarBanco(testPath: inMemoryDatabasePath);

    await tester.pumpWidget(const MaterialApp(home: VitrineProdutosScreen()));
    
    // Wait for FutureBuilder
    await tester.pumpAndSettle();

    expect(find.text('Vitrine de Produtos Artesanais'), findsOneWidget);
    expect(find.text('Vaso de Cerâmica'), findsOneWidget);
    expect(find.text('Cesto de Mimosa'), findsOneWidget);
    expect(find.text('Tapete de Tear'), findsOneWidget);
    expect(find.text('R\$ 45.00'), findsOneWidget);
    expect(find.text('R\$ 120.00'), findsOneWidget);
  });
}
