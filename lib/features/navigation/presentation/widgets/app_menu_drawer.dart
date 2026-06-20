import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/screens/register_screen.dart';

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.usuarioLogado;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.deepPurple),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Encomendas Artesanais',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                if (user != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Olá, ${user.nome}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Vitrine'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          if (user?.perfil == 'CLIENTE')
            ListTile(
              leading: const Icon(Icons.add_shopping_cart),
              title: const Text('Iniciar Pedido'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/create_order');
              },
            ),
          if (user?.perfil == 'ATENDENTE')
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Gerenciar Pedidos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/manage_orders');
              },
            ),
          if (user?.perfil == 'ADMINISTRADOR') ...[
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Gerenciar Produtos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/manage_products');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Gerenciar Atendentes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/manage_attendants');
              },
            ),
          ],
          if (user == null) ...[
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Entrar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Criar Conta'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                // Implement Perfil if needed
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () {
                authService.logout();
                Navigator.pop(context);
                // Trigger rebuild of the screen that holds the drawer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logout realizado com sucesso')),
                );
                // We might need a better way to refresh, but for now:
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ],
      ),
    );
  }
}
