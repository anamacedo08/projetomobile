import 'package:flutter/material.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/auth_service.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final OrderService _orderService = OrderService();
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _refreshOrders();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = DatabaseService.obterInstancia().database.then(
        (db) => db.query('pedidos', orderBy: 'data_criacao DESC')
      );
    });
  }

  void _iniciarProducao(String id) async {
    final user = AuthService().usuarioLogado;
    if (user == null) return;
    try {
      await _orderService.iniciarFabricacaoManual(id, user);
      _refreshOrders();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  void _registrarEnvio(String id) async {
    final user = AuthService().usuarioLogado;
    if (user == null) return;
    
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Envio'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(labelText: 'Código de Rastreio'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              try {
                await _orderService.registrarEnvioLogistico(id, codeController.text, user);
                if (mounted) Navigator.pop(context);
                _refreshOrders();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Pedidos')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                child: ListTile(
                  title: Text('Pedido ${order['id']}'),
                  subtitle: Text('Status: ${order['status']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (order['status'] == 'AGUARDANDO_INICIO')
                        IconButton(icon: const Icon(Icons.play_arrow), onPressed: () => _iniciarProducao(order['id'])),
                      if (order['status'] == 'EM_FABRICACAO')
                        IconButton(icon: const Icon(Icons.local_shipping), onPressed: () => _registrarEnvio(order['id'])),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
