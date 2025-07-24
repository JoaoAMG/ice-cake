import 'package:doceria_app/providers/user_provider.dart'; 
import 'package:doceria_app/routers/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp.router(
        title: 'ice&cake',
        theme: ThemeData(
          fontFamily: 'Dongle',
          appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
              color: Color(0xFF963484),
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}