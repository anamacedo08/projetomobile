import 'package:flutter/material.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../../../core/models/produto.dart';
import '../../../navigation/presentation/widgets/app_menu_drawer.dart';

class VitrineProdutosScreen extends StatefulWidget {
  const VitrineProdutosScreen({super.key});

  @override
  State<VitrineProdutosScreen> createState() => _VitrineProdutosScreenState();
}

class _VitrineProdutosScreenState extends State<VitrineProdutosScreen> {
  late Future<List<Produto>> _produtosFuture;
  final GetProductsUseCase _getProductsUseCase = GetProductsUseCase();

  @override
  void initState() {
    super.initState();
    _produtosFuture = _getProductsUseCase.executar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vitrine de Produtos Artesanais'),
        actions: [
          if (AuthService().usuarioLogado?.perfil == 'CLIENTE')
            IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              tooltip: 'Iniciar Pedido',
              onPressed: () {
                Navigator.pushNamed(context, '/create_order');
              },
            ),
        ],
      ),
      drawer: const AppMenuDrawer(),
      body: FutureBuilder<List<Produto>>(
        future: _produtosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar produtos: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum produto cadastrado.'));
          }

          final produtos = snapshot.data!;
          return ListView.builder(
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final produto = produtos[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Image.network(
                    produto.imagemUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                  ),
                  title: Text(produto.nome),
                  subtitle: Text(produto.descricao),
                  trailing: Text('R\$ ${produto.preco.toStringAsFixed(2)}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
