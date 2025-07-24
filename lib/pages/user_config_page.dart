import 'package:doceria_app/database/dao/dao_usuario.dart';
import 'package:doceria_app/model/usuario.dart';
import 'package:doceria_app/providers/user_provider.dart';
import 'package:doceria_app/widgets/profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserConfigPage extends StatelessWidget {
  const UserConfigPage({super.key});

  String _getFirstLetter(String name) {
    if (name.isEmpty) return '';
    return name[0].toUpperCase();
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final usuario = userProvider.currentUser;
    final usuarioDAO = UsuarioDAO();

    if (usuario == null || usuario.id == null) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Você tem certeza de que deseja excluir sua conta permanentemente? Esta ação não pode ser desfeita.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
              onPressed: () async {
                await usuarioDAO.deleteUser(usuario.id!);
                userProvider.clearUser();
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                  GoRouter.of(context).go('/autenticacao');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final usuario = userProvider.currentUser;

    if (usuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  onPressed: () => GoRouter.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              ClipPath(
                clipper: MyCustomClipper(),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  color: const Color.fromRGBO(210, 41, 193, 1),
                ),
              ),
              Positioned(
                bottom: -30,
                child: CircleAvatar(
                  radius: 90,
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    _getFirstLetter(usuario.nome),
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 80),
          Text(usuario.nome, style: const TextStyle(fontSize: 50)),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ProfileMenuItem(
                  icon: Icons.person,
                  text: 'Meus dados',
                  onTap: () => GoRouter.of(context).push('/user_config/meus_dados'),
                ),
                
                
                
                
                if (usuario is UsuarioCliente)
                  ProfileMenuItem(
                    icon: Icons.location_on,
                    text: 'Meu endereço',
                    onTap: () => GoRouter.of(context).push('/user_config/meus_enderecos'),
                  ),
                
                
                if (usuario is UsuarioCliente)
                  ProfileMenuItem(
                    icon: Icons.history,
                    text: 'Minhas compras',
                    onTap: () => GoRouter.of(context).push('/user_config/minhas_compras'),
                  ),
                
                ProfileMenuItem(
                  icon: Icons.login_outlined,
                  text: 'Sair',
                  onTap: () {
                    userProvider.clearUser();
                    GoRouter.of(context).go('/autenticacao');
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.delete_forever,
                  text: 'Excluir Conta',
                  onTap: () {
                    _showDeleteConfirmationDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width / 2,
      size.height * 0.6,
      size.width,
      size.height * 0.8,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}