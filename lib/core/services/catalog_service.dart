import 'package:uuid/uuid.dart';
import '../database/database_service.dart';
import '../models/produto.dart';

class CatalogService {
  final DatabaseService dbService;

  CatalogService() : dbService = DatabaseService.obterInstancia();

  Future<List<Produto>> getProducts() async {
    final db = await dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('produtos');
    return List.generate(maps.length, (i) => Produto.fromMap(maps[i]));
  }

  Future<void> addProduct(Produto produto) async {
    final db = await dbService.database;
    await db.insert('produtos', {
      'id': const Uuid().v4(),
      'nome': produto.nome,
      'descricao': produto.descricao,
      'imagem_url': produto.imagemUrl,
      'preco': produto.preco,
    });
  }

  Future<void> updateProduct(Produto produto) async {
    final db = await dbService.database;
    await db.update(
      'produtos',
      produto.toMap(),
      where: 'id = ?',
      whereArgs: [produto.id],
    );
  }

  Future<void> deleteProduct(String id) async {
    final db = await dbService.database;
    await db.delete(
      'produtos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
