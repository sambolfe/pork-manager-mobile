import 'package:flutter/material.dart';
import 'package:pork_manager_mobile/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String? _token;

  @override
  void initState() {
    super.initState();
    _fetchToken();
  }

  Future<void> _fetchToken() async {
    final token = await _authService.getToken();
    setState(() {
      _token = token;
    });
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página Inicial'),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/imagens/logo.png',
                    height: 80,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.health_and_safety),
              title: const Text(
                'Gerenciar Saúde',
                style: TextStyle(color: Colors.black),
              ),
              onTap: _token != null
                  ? () {
                Navigator.pushNamed(
                  context,
                  '/saude',
                  arguments: {'token': _token},
                );
              }
                  : null,
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () async {
                await _authService.logout();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Somos uma equipe dedicada ao desenvolvimento de soluções inovadoras para o gerenciamento da criação de suínos.\n\n'
                    'Combinamos nossa experiência em tecnologia com um profundo conhecimento do setor para oferecer um sistema completo e intuitivo que atenda às necessidades dos criadores.\n\n'
                    'Junte-se a nós e descubra como podemos ajudar a impulsionar sua produção de suínos para o próximo nível!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Image.asset(
                  'assets/imagens/home.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
