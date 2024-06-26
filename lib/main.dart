import 'package:flutter/material.dart';
import 'package:pork_manager_mobile/screens/login_screen.dart';
import 'package:pork_manager_mobile/screens/home_screen.dart';
import 'package:pork_manager_mobile/screens/editar_saude_screen.dart';
import 'package:pork_manager_mobile/screens/cadastrar_saude_screen.dart';
import 'package:pork_manager_mobile/screens/saude_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pork Manager Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/cadastrar_saude': (context) => CadastrarSaudeScreen(),
        '/saude': (context) => const SaudeScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/editar_saude':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (context) => EditarSaudeScreen(
                saudeId: args['saudeId'],
                tipoTratamento: args['tipoTratamento'],
                observacoes: args['observacoes'],
                dataInicioTratamento: args['dataInicioTratamento'],
                peso: args['peso'],
                dataEntradaCio: args['dataEntradaCio'],
                identificadorOrelha: args['identificadorOrelha'],
                foto: args['foto'],
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}
