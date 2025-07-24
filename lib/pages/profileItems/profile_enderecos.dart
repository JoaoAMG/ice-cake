import 'package:doceria_app/database/dao/dao_endereco.dart';
import 'package:doceria_app/model/endereco.dart';
import 'package:doceria_app/providers/user_provider.dart';
import 'package:doceria_app/widgets/input_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ProfileEnderecosPage extends StatefulWidget {
  const ProfileEnderecosPage({super.key});

  @override
  State<ProfileEnderecosPage> createState() => _ProfileEnderecosPageState();
}

class _ProfileEnderecosPageState extends State<ProfileEnderecosPage> {
  final _formKey = GlobalKey<FormState>();
  final _cepController = TextEditingController();
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _complementoController = TextEditingController();

  final EnderecoDAO enderecoDAO = EnderecoDAO();
  bool _isEditing = false;
  int? _editingEnderecoId;
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _loadAddressData();
  }

  @override
  void dispose() {
    _cepController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _complementoController.dispose();
    super.dispose();
  }

  Future<void> _loadAddressData() async {
    final usuario = context.read<UserProvider>().currentUser;
    if (usuario != null && usuario.id != null) {
      final endereco = await enderecoDAO.getEnderecoByUsuarioId(usuario.id!);
      if (mounted && endereco != null) {
        _preencherCampos(endereco);
        _isEditing = false;
      } else {
        _isEditing = true; 
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _preencherCampos(EnderecoModel endereco) {
    _cepController.text = endereco.cep;
    _ruaController.text = endereco.rua;
    _numeroController.text = endereco.numero;
    _bairroController.text = endereco.bairro;
    _cidadeController.text = endereco.cidade;
    _estadoController.text = endereco.estado;
    _complementoController.text = endereco.complemento ?? '';
    _editingEnderecoId = endereco.id;
  }

  void _salvarEndereco() async {
    
    if (_formKey.currentState!.validate()) {
      final usuario = context.read<UserProvider>().currentUser;
      if (usuario == null || usuario.id == null) return;

      final endereco = EnderecoModel(
        id: _editingEnderecoId,
        usuario_id: usuario.id!,
        cep: _cepController.text,
        rua: _ruaController.text,
        numero: _numeroController.text,
        bairro: _bairroController.text,
        cidade: _cidadeController.text,
        estado: _estadoController.text,
        complemento: _complementoController.text,
      );

      
      await enderecoDAO.saveEndereco(endereco);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Endereço salvo com sucesso!'),
        ),
      );
      
      
      setState(() {
        _isEditing = false;
        
        _loadAddressData(); 
      });
    }
  }
  
  void _toggleEditMode() {
      setState(() {
          if (_isEditing) {
              
              _salvarEndereco();
          } else {
              
              _isEditing = true;
          }
      });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu endereço'),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF963484)),
        titleTextStyle: const TextStyle(
          color: Color(0xFF963484),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              style: const TextStyle(fontSize: 20),
                              controller: _cepController,
                              decoration: inputEndereco('CEP', Icons.location_on_outlined),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(8),
                              ],
                              readOnly: !_isEditing,
                              validator: (String? value) {
                                if (value == null || value.isEmpty || value.length != 8) {
                                  return 'O CEP deve conter 8 dígitos';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              style: const TextStyle(fontSize: 20),
                              controller: _ruaController,
                              decoration: inputEndereco('Rua', Icons.home),
                              readOnly: !_isEditing,
                              validator: (String? value) => (value == null || value.isEmpty) ? 'A rua não pode ser vazia' : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              style: const TextStyle(fontSize: 20),
                              controller: _numeroController,
                              decoration: inputEndereco('Número', Icons.format_list_numbered),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              readOnly: !_isEditing,
                              validator: (String? value) => (value == null || value.isEmpty) ? 'O número não pode ser vazio' : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              style: const TextStyle(fontSize: 20),
                              controller: _bairroController,
                              decoration: inputEndereco('Bairro', Icons.location_city),
                              readOnly: !_isEditing,
                              validator: (String? value) => (value == null || value.isEmpty) ? 'O bairro não pode ser vazio' : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              style: const TextStyle(fontSize: 20),
                              controller: _cidadeController,
                              decoration: inputEndereco('Cidade', Icons.business),
                              readOnly: !_isEditing,
                              validator: (String? value) => (value == null || value.isEmpty) ? 'A cidade não pode ser vazia' : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              style: const TextStyle(fontSize: 20),
                              controller: _estadoController,
                              decoration: inputEndereco('Estado (UF)', Icons.map),
                              readOnly: !_isEditing,
                              validator: (String? value) {
                                if (value == null || value.isEmpty || value.length != 2) {
                                  return 'O estado deve conter 2 letras (UF)';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              style: const TextStyle(fontSize: 20),
                              controller: _complementoController,
                              decoration: inputEndereco('Complemento (Opcional)', Icons.add_location_alt),
                              readOnly: !_isEditing,
                            ),
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleEditMode,
        child: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 214, 3, 158),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}