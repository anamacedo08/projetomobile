import '../database/database_service.dart';
import '../models/usuario.dart';

class OrderService {
  final DatabaseService dbService;

  OrderService() : dbService = DatabaseService.obterInstancia();

  Future<void> iniciarFabricacaoManual(String pedidoId, Usuario atendenteLogado) async {
    if (atendenteLogado.perfil != "ATENDENTE") {
      throw Exception("Operação restrita para perfis do tipo Atendente.");
    }

    final db = await dbService.database;
    final pedido = await db.query(
      "pedidos",
      columns: ["status"],
      where: "id = ?",
      whereArgs: [pedidoId],
    );

    if (pedido.isEmpty || pedido.first["status"] != "AGUARDANDO_INICIO") {
      throw Exception("O pedido deve estar sob o status AGUARDANDO_INICIO para iniciar a fabricação manual.");
    }

    await db.update(
      "pedidos",
      {"status": "EM_FABRICACAO"},
      where: "id = ?",
      whereArgs: [pedidoId],
    );
  }

  Future<void> registrarEnvioLogistico(String pedidoId, String dadosEnvio, Usuario atendenteLogado) async {
    if (atendenteLogado.perfil != "ATENDENTE") {
      throw Exception("Operação restrita para perfis do tipo Atendente.");
    }

    final db = await dbService.database;
    final pedido = await db.query(
      "pedidos",
      columns: ["status"],
      where: "id = ?",
      whereArgs: [pedidoId],
    );

    if (pedido.isEmpty || pedido.first["status"] != "EM_FABRICACAO") {
      throw Exception("Não é possível despachar um pedido que não esteja sob o status EM_FABRICACAO.");
    }

    await db.update(
      "pedidos",
      {"status": "ENVIADO", "codigo_rastreio": dadosEnvio},
      where: "id = ?",
      whereArgs: [pedidoId],
    );
  }
}
