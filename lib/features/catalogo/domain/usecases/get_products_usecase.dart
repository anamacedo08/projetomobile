import '../../../../core/database/database_service.dart';
import '../../../../core/models/produto.dart';

class GetProductsUseCase {
  final DatabaseService dbService;

  GetProductsUseCase() : dbService = DatabaseService.obterInstancia();

  Future<List<Produto>> executar() async {
    final db = await dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('produtos');
    
    return List.generate(maps.length, (i) {
      return Produto.fromMap(maps[i]);
    });
  }
}
