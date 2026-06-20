import 'package:flutter/material.dart';
import 'app/config/env_config.dart';
import 'core/database/database_service.dart';
import 'features/catalogo/presentation/screens/vitrine_produtos_screen.dart';
import 'features/orders/presentation/screens/create_order_screen.dart';
import 'features/orders/presentation/screens/manage_orders_screen.dart';
import 'features/admin/presentation/screens/manage_products_screen.dart';
import 'features/admin/presentation/screens/manage_attendants_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa configurações de ambiente
  await EnvConfig.initialize();
  
  // Inicializa o banco de dados
  await DatabaseService.instance.inicializarBanco();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artesanal App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const VitrineProdutosScreen(),
        '/create_order': (context) => const CreateOrderScreen(),
        '/manage_orders': (context) => const ManageOrdersScreen(),
        '/manage_products': (context) => const ManageProductsScreen(),
        '/manage_attendants': (context) => const ManageAttendantsScreen(),
      },
    );
  }
}
