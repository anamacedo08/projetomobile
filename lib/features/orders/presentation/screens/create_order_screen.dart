import 'package:flutter/material.dart';
import '../../domain/usecases/send_order_usecase.dart';
import '../../../../core/services/auth_service.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _customizacoesController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _valorController = TextEditingController();
  final _sendOrderUseCase = SendOrderUseCase();
  bool _isLoading = false;

  void _createOrder() async {
    final user = AuthService().usuarioLogado;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await _sendOrderUseCase.executar(
        user.id,
        _customizacoesController.text,
        _enderecoController.text,
        double.tryParse(_valorController.text) ?? 0.0,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido realizado com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar pedido: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Pedido')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _customizacoesController,
              decoration: const InputDecoration(labelText: 'Customizações/Detalhes'),
            ),
            TextField(
              controller: _enderecoController,
              decoration: const InputDecoration(labelText: 'Endereço de Entrega'),
            ),
            TextField(
              controller: _valorController,
              decoration: const InputDecoration(labelText: 'Valor Estimado'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createOrder,
                    child: const Text('Finalizar Pedido'),
                  ),
          ],
        ),
      ),
    );
  }
}
