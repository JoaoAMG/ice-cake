import 'package:doceria_app/database/dao/dao_endereco.dart';
import 'package:doceria_app/database/dao/dao_pedido.dart';
import 'package:doceria_app/model/item_carrinho.dart';
import 'package:doceria_app/model/item_pedido.dart';
import 'package:doceria_app/model/pedido.dart';
import 'package:doceria_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CarrinhoPage extends StatefulWidget {
  final List<ItemCarrinho> carrinho;
  const CarrinhoPage({super.key, required this.carrinho});

  @override
  State<CarrinhoPage> createState() => _CarrinhoState();
}

class _CarrinhoState extends State<CarrinhoPage> {
  
  final PedidoDAO pedidoDAO = PedidoDAO();
  final EnderecoDAO enderecoDAO = EnderecoDAO();

  String _formaPagamento = 'Cartão de Crédito';
  double total = 0;

  @override
  void initState() {
    super.initState();
    _calcularTotal();
  }

  void _calcularTotal() {
    total = widget.carrinho.fold(
        0, (sum, item) => sum + (item.produto.preco * item.quantidade));
  }

  void _removerItem(int index) {
    setState(() {
      widget.carrinho.removeAt(index);
      _calcularTotal();
    });
  }

  
  Future<void> _finalizarPedido() async {
    final usuario = context.read<UserProvider>().currentUser;

    if (usuario == null || usuario.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Sessão inválida. Faça login novamente."),
      ));
      GoRouter.of(context).go('/autenticacao');
      return;
    }

    final enderecoSalvo = await enderecoDAO.getEnderecoByUsuarioId(usuario.id!);

    if (!mounted) return;

    if (enderecoSalvo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.orange,
        content: Text("Cadastre um endereço antes de finalizar o pedido."),
      ));
      
      context.push('/user_config/meus_enderecos');
      return;
    }

    if (widget.carrinho.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Seu carrinho está vazio."),
      ));
      return;
    }

    final itensPedido = widget.carrinho.map((itemCarrinho) {
      return ItemPedido(
        pedido_id: 0,
        produto_id: itemCarrinho.produto.id!,
        quantidade: itemCarrinho.quantidade,
        preco_unitario: itemCarrinho.produto.preco,
      );
    }).toList();

    final pedido = Pedido(
      usuario_id: usuario.id!,
      data_pedido: DateTime.now(),
      valor_total: total,
      itens: itensPedido,
    );

    await pedidoDAO.savePedido(pedido);

    setState(() {
      widget.carrinho.clear();
      _calcularTotal();
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.green,
      content: Text("Pedido finalizado com sucesso!"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
        backgroundColor: const Color(0xFFFAD6FA),
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: widget.carrinho.isEmpty
                ? const Center(
                    child: Text(
                    "Seu carrinho está vazio!",
                    style: TextStyle(fontSize: 30),
                  ))
                : ListView.builder(
                    itemCount: widget.carrinho.length,
                    itemBuilder: (context, index) {
                      final item = widget.carrinho[index];
                      return ListTile(
                        
                        title: Text(
                          item.produto.nome,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${item.quantidade}x R\$ ${item.produto.preco.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _removerItem(index),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButton<String>(
                  value: _formaPagamento,
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      _formaPagamento = newValue!;
                    });
                  },
                  items: <String>[
                    'Cartão de Crédito',
                    'Cartão de Débito',
                    'Pix',
                    'Dinheiro'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 25)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Total: R\$ ${total.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 35, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _finalizarPedido,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB100A5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Finalizar Pedido'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}