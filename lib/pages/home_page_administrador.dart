import 'package:doceria_app/database/dao/dao_pedido.dart';
import 'package:doceria_app/database/dao/dao_produto.dart';
import 'package:doceria_app/model/bolo.dart';
import 'package:doceria_app/model/pedido.dart';
import 'package:doceria_app/model/produto.dart';
import 'package:doceria_app/model/sorvete.dart';
import 'package:doceria_app/model/torta.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePageAdministrador extends StatefulWidget {
  const HomePageAdministrador({super.key});

  @override
  State<HomePageAdministrador> createState() => _HomePageAdministradorState();
}

class _HomePageAdministradorState extends State<HomePageAdministrador> {
  final PedidoDAO _pedidoDAO = PedidoDAO();
  final ProdutoDAO _produtoDAO = ProdutoDAO();
  late Future<List<Pedido>> _pedidosFuture;
  late Future<List<Produto>> _produtosFuture;

  
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _pedacosController = TextEditingController();
  final _pesoController = TextEditingController();
  final _saborController = TextEditingController();
  final _mlTamanhoController = TextEditingController();

  String _tipoProdutoSelecionado = 'BOLO';
  bool _isFormVisible = false;
  int? _editingProductId;

  @override
  void initState() {
    super.initState();
    _reloadData();
  }

  void _reloadData() {
    setState(() {
      _pedidosFuture = _pedidoDAO.getAllPedidos();
      _produtosFuture = _produtoDAO.getAllProdutos();
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _categoriaController.dispose();
    _pedacosController.dispose();
    _pesoController.dispose();
    _saborController.dispose();
    _mlTamanhoController.dispose();
    super.dispose();
  }

  void _showForm({Produto? produto}) {
    _clearForm();
    if (produto != null) {
      
      _editingProductId = produto.id;
      _nomeController.text = produto.nome;
      _descricaoController.text = produto.descricao;
      _precoController.text = produto.preco.toString();

      if (produto is Bolo) {
        _tipoProdutoSelecionado = 'BOLO';
        _categoriaController.text = produto.categoria;
        _pedacosController.text = produto.pedacos.toString();
      } else if (produto is Torta) {
        _tipoProdutoSelecionado = 'TORTA';
        _categoriaController.text = produto.categoria;
        _pesoController.text = produto.peso.toString();
      } else if (produto is Sorvete) {
        _tipoProdutoSelecionado = 'SORVETE';
        _saborController.text = produto.sabor;
        _mlTamanhoController.text = produto.mlTamanho;
      }
    } else {
      
      _editingProductId = null;
      _tipoProdutoSelecionado = 'BOLO';
    }
    setState(() {
      _isFormVisible = true;
    });
  }

  void _hideForm() {
    setState(() {
      _isFormVisible = false;
    });
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nomeController.clear();
    _descricaoController.clear();
    _precoController.clear();
    _categoriaController.clear();
    _pedacosController.clear();
    _pesoController.clear();
    _saborController.clear();
    _mlTamanhoController.clear();
  }

  void _saveProduto() async {
    if (!_formKey.currentState!.validate()) return;

    Produto? produtoParaSalvar;
    switch (_tipoProdutoSelecionado) {
      case 'BOLO':
        produtoParaSalvar = Bolo(
          id: _editingProductId,
          nome: _nomeController.text,
          descricao: _descricaoController.text,
          preco: double.tryParse(_precoController.text) ?? 0.0,
          categoria: _categoriaController.text,
          pedacos: int.tryParse(_pedacosController.text) ?? 0,
        );
        break;
      case 'TORTA':
        produtoParaSalvar = Torta(
          id: _editingProductId,
          nome: _nomeController.text,
          descricao: _descricaoController.text,
          preco: double.tryParse(_precoController.text) ?? 0.0,
          categoria: _categoriaController.text,
          peso: double.tryParse(_pesoController.text) ?? 0.0,
        );
        break;
      case 'SORVETE':
        produtoParaSalvar = Sorvete(
          id: _editingProductId,
          nome: _nomeController.text,
          descricao: _descricaoController.text,
          preco: double.tryParse(_precoController.text) ?? 0.0,
          sabor: _saborController.text,
          mlTamanho: _mlTamanhoController.text,
        );
        break;
    }

    if (produtoParaSalvar != null) {
      await _produtoDAO.saveProduto(produtoParaSalvar);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produto ${_editingProductId == null ? "criado" : "atualizado"} com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      _hideForm();
      _reloadData();
    }
  }

  void _deleteProduto(Produto produto) async {
    if (produto.id == null) return;
    
    await _produtoDAO.deleteProduto(produto.id!);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Produto "${produto.nome}" excluído com sucesso!'),
        backgroundColor: Colors.red,
      ),
    );
    _reloadData();
  }

  void _showDeleteConfirmationDialog(Produto produto) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Confirmar Exclusão',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Você tem certeza de que deseja excluir o produto "${produto.nome}"? Esta ação não pode ser desfeita.',
            style: const TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir', style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteProduto(produto);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.admin_panel_settings_outlined),
          onPressed: () => GoRouter.of(context).push('/user_config'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        tooltip: 'Adicionar Produto',
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Painel do Administrador',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<Pedido>>(
              future: _pedidosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(heightFactor: 5, child: CircularProgressIndicator());
                }
                final pedidos = snapshot.data ?? [];
                final totalVendas = pedidos.length;
                final valorTotal = pedidos.fold(0.0, (sum, item) => sum + item.valor_total);
                return Row(
                  children: [
                    _buildDashboardCard('Vendas Totais', totalVendas.toString()),
                    const SizedBox(width: 16),
                    _buildDashboardCard('Valor Total', 'R\$ ${valorTotal.toStringAsFixed(2)}'),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            if (_isFormVisible) _buildProdutoForm(),
            const SizedBox(height: 30),
            const Text('Todos os Produtos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            FutureBuilder<List<Produto>>(
              future: _produtosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('Nenhum produto cadastrado.')));
                }
                final produtos = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: produtos.length,
                  itemBuilder: (context, index) {
                    final produto = produtos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(produto.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(produto.descricao, style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(
                              'R\$ ${produto.preco.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                color: Colors.blue.shade700,
                                tooltip: 'Editar',
                                onPressed: () => _showForm(produto: produto),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red.shade700,
                                tooltip: 'Excluir',
                                onPressed: () => _showDeleteConfirmationDialog(produto),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildDashboardCard(String title, String value) {
    
    Color valueColor;
    if (title.contains('Vendas')) {
      valueColor = Colors.orange.shade800;
    } else if (title.contains('Valor')) {
      valueColor = Colors.green.shade800;
    } else {
      valueColor = Colors.black;
    }

    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, color: valueColor), 
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: valueColor), 
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProdutoForm() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_editingProductId == null ? 'Criar Novo Produto' : 'Editando Produto', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: _hideForm)
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipoProdutoSelecionado,
                decoration: const InputDecoration(labelText: 'Tipo de Produto', border: OutlineInputBorder()),
                items: ['BOLO', 'TORTA', 'SORVETE'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _tipoProdutoSelecionado = newValue!;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _descricaoController, decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _precoController, decoration: const InputDecoration(labelText: 'Preço', border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              const SizedBox(height: 12),
              if (_tipoProdutoSelecionado == 'BOLO' || _tipoProdutoSelecionado == 'TORTA')
                TextFormField(controller: _categoriaController, decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              if (_tipoProdutoSelecionado == 'BOLO') ...[
                const SizedBox(height: 12),
                TextFormField(controller: _pedacosController, decoration: const InputDecoration(labelText: 'Pedaços', border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              ],
              if (_tipoProdutoSelecionado == 'TORTA') ...[
                const SizedBox(height: 12),
                TextFormField(controller: _pesoController, decoration: const InputDecoration(labelText: 'Peso (kg)', border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              ],
              if (_tipoProdutoSelecionado == 'SORVETE') ...[
                const SizedBox(height: 12),
                TextFormField(controller: _saborController, decoration: const InputDecoration(labelText: 'Sabor', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _mlTamanhoController, decoration: const InputDecoration(labelText: 'Tamanho (ml)', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduto,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}