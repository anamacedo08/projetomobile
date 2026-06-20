import 'package:flutter/material.dart';
import '../../../../core/services/catalog_service.dart';
import '../../../../core/models/produto.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final CatalogService _catalogService = CatalogService();
  late Future<List<Produto>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = _catalogService.getProducts();
    });
  }

  void _deleteProduct(String id) async {
    await _catalogService.deleteProduct(id);
    _refreshProducts();
  }

  void _showProductForm([Produto? produto]) {
    final nomeController = TextEditingController(text: produto?.nome);
    final descController = TextEditingController(text: produto?.descricao);
    final imgController = TextEditingController(text: produto?.imagemUrl);
    final precoController = TextEditingController(text: produto?.preco.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(produto == null ? 'Novo Produto' : 'Editar Produto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome')),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Descrição')),
              TextField(controller: imgController, decoration: const InputDecoration(labelText: 'URL Imagem')),
              TextField(controller: precoController, decoration: const InputDecoration(labelText: 'Preço'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final newProd = Produto(
                id: produto?.id ?? '',
                nome: nomeController.text,
                descricao: descController.text,
                imagemUrl: imgController.text,
                preco: double.tryParse(precoController.text) ?? 0.0,
              );
              if (produto == null) {
                await _catalogService.addProduct(newProd);
              } else {
                await _catalogService.updateProduct(newProd);
              }
              if (mounted) Navigator.pop(context);
              _refreshProducts();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Produtos')),
      body: FutureBuilder<List<Produto>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product.nome),
                subtitle: Text('R\$ ${product.preco}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _showProductForm(product)),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteProduct(product.id)),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
