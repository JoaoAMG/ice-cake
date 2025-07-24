import 'package:doceria_app/model/bolo.dart';
import 'package:doceria_app/model/sorvete.dart';
import 'package:doceria_app/model/torta.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'ice_cake.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  
  Future<void> _onCreate(Database db, int version) async {
    
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        cpf TEXT NOT NULL UNIQUE,
        telefone TEXT NOT NULL,
        senha TEXT NOT NULL,
        tipo_usuario TEXT NOT NULL DEFAULT 'CLIENTE'
      )
    ''');
    await db.execute('''
      CREATE TABLE enderecos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rua TEXT NOT NULL,
        numero TEXT NOT NULL,
        bairro TEXT NOT NULL,
        cidade TEXT NOT NULL,
        cep TEXT NOT NULL,
        estado TEXT NOT NULL,
        complemento TEXT,
        usuario_id INTEGER NOT NULL,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE produtos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        descricao TEXT NOT NULL,
        preco REAL NOT NULL,
        tipo_produto TEXT NOT NULL,
        categoria_bolo TEXT,
        pedacos_bolo INTEGER,
        categoria_torta TEXT,
        peso_torta REAL,
        sabor_sorvete TEXT,
        ml_tamanho_sorvete TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE pedidos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data_pedido TEXT NOT NULL,
        valor_total REAL NOT NULL,
        usuario_id INTEGER NOT NULL,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE itens_pedido (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quantidade INTEGER NOT NULL,
        preco_unitario REAL NOT NULL,
        pedido_id INTEGER NOT NULL,
        produto_id INTEGER NOT NULL,
        FOREIGN KEY (pedido_id) REFERENCES pedidos (id) ON DELETE CASCADE,
        FOREIGN KEY (produto_id) REFERENCES produtos (id)
      )
    ''');

    
    await _seedDatabase(db);
  }

  
  Future<void> _seedDatabase(Database db) async {
    
    await db.insert('produtos', Bolo(nome: 'Bolo de Chocolate com Brigadeiro', descricao: 'Massa fofinha de chocolate com cobertura gourmet.', preco: 68, categoria: 'Comum', pedacos: 12).toMap());
    await db.insert('produtos', Bolo(nome: 'Bolo de Leite Ninho com Morango', descricao: 'Camadas de creme de leite Ninho com morangos frescos.', preco: 75, categoria: 'Comum', pedacos: 12).toMap());
    await db.insert('produtos', Bolo(nome: 'Bolo de Cenoura com Chocolate', descricao: 'Clássico brasileiro com cobertura de brigadeiro caseiro.', preco: 60, categoria: 'Comum', pedacos: 12).toMap());

    
    await db.insert('produtos', Torta(nome: 'Torta de Morango com Chantilly', descricao: 'Recheio cremoso e cobertura generosa de morangos.', preco: 68, categoria: 'Doce', peso: 1.2).toMap());
    await db.insert('produtos', Torta(nome: 'Torta de Chocolate Belga', descricao: '70% cacau com recheio trufado e ganache.', preco: 72, categoria: 'Doce', peso: 1.3).toMap());
    await db.insert('produtos', Torta(nome: 'Torta Holandesa', descricao: 'Base crocante com creme branco e cobertura de chocolate meio amargo.', preco: 75, categoria: 'Doce', peso: 1.5).toMap());

    
    await db.insert('produtos', Sorvete(nome: 'Sorvete de Pistache Premium', descricao: 'Com pasta natural de pistache. Sabor sofisticado.', preco: 9, sabor: 'Pistache', mlTamanho: '100').toMap());
    await db.insert('produtos', Sorvete(nome: 'Sorvete de Doce de Leite com Nozes', descricao: 'Pedaços crocantes de nozes e doce de leite argentino.', preco: 7, sabor: 'Doce de Leite', mlTamanho: '100').toMap());
    await db.insert('produtos', Sorvete(nome: 'Sorvete de Chocolate Intenso', descricao: 'Feito com chocolate nobre, textura cremosa e sabor marcante.', preco: 7, sabor: 'Chocolate', mlTamanho: '100').toMap());
  }
}