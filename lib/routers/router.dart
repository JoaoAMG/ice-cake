import 'package:doceria_app/model/item_carrinho.dart';
import 'package:doceria_app/pages/apresentacao.dart';
import 'package:doceria_app/pages/autenticacao_page.dart';
import 'package:doceria_app/pages/carrinho_page.dart';
import 'package:doceria_app/pages/home_page.dart';
import 'package:doceria_app/pages/onboarding/onboarding_home.dart';
import 'package:doceria_app/pages/profileItems/profile_dados.dart';
import 'package:doceria_app/pages/profileItems/profile_enderecos.dart';
import 'package:doceria_app/pages/profileItems/profile_historico.dart';
import 'package:doceria_app/pages/user_config_page.dart';
import 'package:doceria_app/pages/home_page_administrador.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  
  
  initialLocation: '/apresentacao',

  
  routes: [
    GoRoute(
      path: '/apresentacao',
      builder: (context, state) => const Apresentacao(), 
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => OnboardingHome(),
    ),
    GoRoute(
      path: '/autenticacao',
      builder: (context, state) => const AutenticacaoPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'carrinho', 
          builder: (context, state) {
            
            final carrinho = (state.extra as List<ItemCarrinho>?) ?? [];
            return CarrinhoPage(carrinho: carrinho);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/user_config',
      builder: (context, state) => const UserConfigPage(),
      
      routes: [
        GoRoute(
          path: 'meus_dados', 
          builder: (context, state) => const ProfileDadosPage(),
        ),
        GoRoute(
          path: 'meus_enderecos', 
          builder: (context, state) => const ProfileEnderecosPage(),
        ),
        GoRoute(
          path: 'minhas_compras', 
          builder: (context, state) => const ProfileHistoricoPage(),
        ),
      ],
    ),
    
    GoRoute(
      path: '/admin/home',
      builder: (context, state) => const HomePageAdministrador(),
    ),
  ],
);