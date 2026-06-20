import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database/database_service.dart';
import '../../app/config/env_config.dart';

class PaymentService {
  final DatabaseService dbService;

  PaymentService() : dbService = DatabaseService.obterInstancia();

  Future<bool> processarPagamentoApp(String pedidoId, String tokenCartao) async {
    final chaveGateway = EnvConfig.paymentGatewayKey;
    
    final db = await dbService.database;
    final dadosPedido = await db.query(
      "pedidos",
      columns: ["valor"],
      where: "id = ?",
      whereArgs: [pedidoId],
    );

    if (dadosPedido.isEmpty) {
      throw Exception("Pedido inexistente.");
    }

    final valorTransacao = dadosPedido.first["valor"];
    
    final response = await http.post(
      Uri.parse("https://api.gateway.com/v1/charge"),
      headers: {"Authorization": chaveGateway, "Content-Type": "application/json"},
      body: jsonEncode({
        "amount": valorTransacao,
        "card_token": tokenCartao,
        "reference_id": pedidoId
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body["status"] == "PAID") {
        await db.update(
          "pedidos",
          {"status": "AGUARDANDO_INICIO"},
          where: "id = ?",
          whereArgs: [pedidoId],
        );
        return true;
      }
    }

    return false;
  }
}
