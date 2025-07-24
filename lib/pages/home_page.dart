import 'package:carousel_slider/carousel_slider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:doceria_app/database/dao/dao_produto.dart';
import 'package:doceria_app/model/bolo.dart';
import 'package:doceria_app/model/item_carrinho.dart';
import 'package:doceria_app/model/produto.dart';
import 'package:doceria_app/model/sorvete.dart';
import 'package:doceria_app/model/torta.dart';
import 'package:doceria_app/providers/user_provider.dart';
import 'package:doceria_app/widgets/carrossel_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final List<ItemCarrinho> _carrinho = [];

  final ProdutoDAO _produtoDAO = ProdutoDAO();
  late Future<List<Produto>> _produtosFuture;

  final CarouselSliderController _carouselController = CarouselSliderController();
  final ScrollController _scrollController = ScrollController();
  late Map<int, GlobalKey> _productKeys;

  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  int? _flashingProductIndex;

  @override
  void initState() {
    super.initState();
    _productKeys = {};
    _produtosFuture = _produtoDAO.getAllProdutos();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: const Color(0xFFF68CDF).withAlpha(77),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  void _onCarouselItemTapped(int carouselIndex, List<Produto> allProdutos) {
    Produto tappedProduto = allProdutos[carouselIndex];
    int categoryIndex = 0;
    if (tappedProduto is Bolo) categoryIndex = 0;
    if (tappedProduto is Torta) categoryIndex = 1;
    if (tappedProduto is Sorvete) categoryIndex = 2;

    List<Produto> categoryProducts = allProdutos.where((p) => p.runtimeType == tappedProduto.runtimeType).toList();
    int productListIndex = categoryProducts.indexWhere((p) => p.id == tappedProduto.id);

    if (_currentIndex != categoryIndex) {
      setState(() {
        _currentIndex = categoryIndex;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _piscar(productListIndex);
      });
    } else {
      _piscar(productListIndex);
    }
  }

  void _piscar(int productIndex) {
    final key = _productKeys[productIndex];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      ).then((_) async {
        setState(() { _flashingProductIndex = productIndex; });
        for (int i = 0; i < 3; i++) {
          await _animationController.forward();
          await _animationController.reverse();
        }
        setState(() { _flashingProductIndex = null; });
      });
    }
  }

  int _mapProductIndexToCarouselIndex(int productListIndex, List<Produto> allProdutos) {
    Type productType;
    switch (_currentIndex) {
      case 1: productType = Torta; break;
      case 2: productType = Sorvete; break;
      default: productType = Bolo;
    }
    List<Produto> categoryProducts = allProdutos.where((p) => p.runtimeType == productType).toList();
    Produto selectedProduct = categoryProducts[productListIndex];
    return allProdutos.indexWhere((p) => p.id == selectedProduct.id);
  }

  void _adicionarAoCarrinho(Produto produto) {
    final usuario = context.read<UserProvider>().currentUser;
    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se cadastre para comprar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      GoRouter.of(context).push('/autenticacao');
      return;
    }
    setState(() {
      final index = _carrinho.indexWhere((item) => item.produto.nome == produto.nome);
      if (index >= 0) {
        _carrinho[index].quantidade++;
      } else {
        _carrinho.add(ItemCarrinho(produto: produto, quantidade: 1));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${produto.nome} adicionado ao carrinho!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<UserProvider>().currentUser;

    return Scaffold(
      body: FutureBuilder<List<Produto>>(
        future: _produtosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar produtos: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum produto encontrado.'));
          }

          final todosOsProdutos = snapshot.data!;
          List<Produto> produtosFiltrados;
          String titulo, emoji;
          switch (_currentIndex) {
            case 0:
              produtosFiltrados = todosOsProdutos.whereType<Bolo>().toList();
              titulo = 'BOLOS ARTESANAIS';
              emoji = '🎂';
              break;
            case 1:
              produtosFiltrados = todosOsProdutos.whereType<Torta>().toList();
              titulo = 'TORTAS ARTESANAIS';
              emoji = '🍰';
              break;
            case 2:
              produtosFiltrados = todosOsProdutos.whereType<Sorvete>().toList();
              titulo = 'SORVETES GOURMET (100g)';
              emoji = '🍦';
              break;
            default:
              produtosFiltrados = [];
              titulo = '';
              emoji = '';
          }
          
          _productKeys.clear();
          for (var i = 0; i < produtosFiltrados.length; i++) {
            _productKeys[i] = GlobalKey();
          }

          return Container(
            color: Colors.white,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (usuario != null) {
                              GoRouter.of(context).push('/user_config');
                            } else {
                              GoRouter.of(context).push('/autenticacao');
                            }
                          },
                          icon: Icon(usuario != null ? Icons.person : Icons.login, size: 32, color: const Color(0xFF4B2753)),
                        ),
                        
                        // <<< CÓDIGO DO CARRINHO RESTAURADO AQUI >>>
                        Stack(
                          children: [
                            IconButton.filled(
                              onPressed: () {
                                GoRouter.of(context).push('/home/carrinho', extra: _carrinho);
                              },
                              icon: const Icon(Icons.shopping_cart),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFF68CDF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                            if (_carrinho.isNotEmpty)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Text(
                                    '${_carrinho.length}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF4B2753),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // <<< FIM DO CÓDIGO DO CARRINHO >>>

                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  CarrosselWidget(
                    carouselController: _carouselController,
                    onItemTapped: (index) => _onCarouselItemTapped(index, todosOsProdutos),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(children: [
                      Text(emoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 8),
                      Text(titulo, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
                    ]),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: produtosFiltrados.length,
                      itemBuilder: (context, index) {
                        final produto = produtosFiltrados[index];
                        final key = _productKeys[index];
                        return AnimatedBuilder(
                            animation: _colorAnimation,
                            builder: (context, child) {
                              return Container(
                                key: key,
                                color: _flashingProductIndex == index ? _colorAnimation.value : Colors.transparent,
                                child: child,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFF4B2753), size: 28),
                                    onPressed: () => _adicionarAoCarrinho(produto),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextButton(
                                          style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                                          onPressed: () {
                                            final carouselIndex = _mapProductIndexToCarouselIndex(index, todosOsProdutos);
                                            _carouselController.animateToPage(carouselIndex);
                                          },
                                          child: Text(produto.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black)),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(produto.descricao, style: const TextStyle(fontSize: 26, color: Color(0xFF4B4B4B))),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('R\$ ${produto.preco.toStringAsFixed(2)}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black)),
                                ],
                              ),
                            ));
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        items: const <Widget>[
          Icon(Icons.cake_outlined, size: 30, color: Colors.white),
          Icon(Icons.pie_chart_outline, size: 30, color: Colors.white),
          Icon(Icons.icecream_outlined, size: 30, color: Colors.white),
        ],
        backgroundColor: Colors.transparent,
        color: const Color(0xFFFAD6FA),
        buttonBackgroundColor: const Color(0xFFF68CDF),
        height: 70,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}