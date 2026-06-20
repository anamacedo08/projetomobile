import 'package:flutter/material.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/models/usuario.dart';

class ManageAttendantsScreen extends StatefulWidget {
  const ManageAttendantsScreen({super.key});

  @override
  State<ManageAttendantsScreen> createState() => _ManageAttendantsScreenState();
}

class _ManageAttendantsScreenState extends State<ManageAttendantsScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  late Future<List<Usuario>> _attendantsFuture;

  @override
  void initState() {
    super.initState();
    _refreshAttendants();
  }

  void _refreshAttendants() {
    setState(() {
      _attendantsFuture = _userService.getAttendants();
    });
  }

  void _deleteAttendant(String id) async {
    await _userService.deleteUser(id);
    _refreshAttendants();
  }

  void _showAttendantForm([Usuario? attendant]) {
    final nomeController = TextEditingController(text: attendant?.nome);
    final emailController = TextEditingController(text: attendant?.email);
    final senhaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(attendant == null ? 'Novo Atendente' : 'Editar Atendente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            if (attendant == null)
              TextField(controller: senhaController, decoration: const InputDecoration(labelText: 'Senha'), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              try {
                if (attendant == null) {
                  await _authService.cadastrarAtendente(
                    nomeController.text,
                    emailController.text,
                    senhaController.text,
                  );
                } else {
                  final updated = Usuario(
                    id: attendant.id,
                    nome: nomeController.text,
                    email: emailController.text,
                    senhaHash: attendant.senhaHash,
                    perfil: 'ATENDENTE',
                  );
                  await _userService.updateAttendant(updated);
                }
                if (mounted) Navigator.pop(context);
                _refreshAttendants();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
              }
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
      appBar: AppBar(title: const Text('Gerenciar Atendentes')),
      body: FutureBuilder<List<Usuario>>(
        future: _attendantsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final attendants = snapshot.data!;
          return ListView.builder(
            itemCount: attendants.length,
            itemBuilder: (context, index) {
              final attendant = attendants[index];
              return ListTile(
                title: Text(attendant.nome),
                subtitle: Text(attendant.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _showAttendantForm(attendant)),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteAttendant(attendant.id)),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAttendantForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
