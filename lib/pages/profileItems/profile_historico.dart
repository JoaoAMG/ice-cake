import 'package:doceria_app/database/dao/dao_pedido.dart';
import 'package:doceria_app/model/pedido.dart';
import 'package:doceria_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfileHistoricoPage extends StatefulWidget {
  
  const ProfileHistoricoPage({super.key});

  @override
  State<ProfileHistoricoPage> createState() => _ProfileHistoricoPageState();
}

class _ProfileHistoricoPageState extends State<ProfileHistoricoPage> {
  final PedidoDAO pedidoDAO = PedidoDAO();
  late Future<List<Pedido>> _pedidosFuture;

  @override
  void initState() {
    super.initState();
    _loadPedidos();
  }

  void _loadPedidos() {
    
    final usuario = context.read<UserProvider>().currentUser;
    if (usuario != null && usuario.id != null) {
      
      _pedidosFuture = pedidoDAO.getPedidosByUsuarioId(usuario.id!);
    } else {
      
      _pedidosFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
        backgroundColor: const Color(0xFFFAD6FA),
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Pedido>>(
        future: _pedidosFuture,
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar o histórico: ${snapshot.error}'));
          }

          
          if (snapshot.hasData) {
            final pedidos = snapshot.data!;

            if (pedidos.isEmpty) {
              return const Center(
                child: Text(
                  'Nenhum pedido feito ainda.',
                  style: TextStyle(fontSize: 30),
                ),
              );
            }

            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pedidos.length,
              itemBuilder: (context, index) {
                final pedido = pedidos[index];
                final dataFormatada = DateFormat('dd/MM/yyyy – HH:mm').format(pedido.data_pedido);

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pedido em $dataFormatada',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 20),
                        
                        ...pedido.itens.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text(
                              '${item.quantidade}x ${item.produto?.nome ?? "Produto indisponível"}',
                              style: const TextStyle(fontSize: 25),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        
                        
                        Text(
                          'Total: R\$ ${pedido.valor_total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB100A5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          
          return const Center(child: Text('Nenhum histórico para exibir.'));
        },
      ),
    );
  }
}