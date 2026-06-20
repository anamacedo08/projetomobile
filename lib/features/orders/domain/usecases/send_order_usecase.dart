import 'package:uuid/uuid.dart';
import '../../../../core/database/database_service.dart';

class SendOrderUseCase {
  final DatabaseService dbService;

  SendOrderUseCase() : dbService = DatabaseService.obterInstancia();

  Future<String> executar(String clienteId, String customizacoes, String enderecoDestino, double totalReal) async {
    if (customizacoes.isEmpty || enderecoDestino.isEmpty || totalReal <= 0) {
      throw Exception("Dados de parametrização da encomenda ou destino inválidos.");
    }

    final novoPedidoId = const Uuid().v4();
    final dataRegistro = DateTime.now().toIso8601String();

    final db = await dbService.database;
    await db.insert("pedidos", {
      "id": novoPedidoId,
      "cliente_id": clienteId,
      "detalhes": customizacoes,
      "status": 'AGUARDANDO_PAGAMENTO',
      "endereco": enderecoDestino,
      "codigo_rastreio": null,
      "valor": totalReal,
      "data_criacao": dataRegistro,
    });

    return novoPedidoId;
  }
}
