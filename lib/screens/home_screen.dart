import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'saude_screen.dart'; // Importar a tela de saúde

class HomeScreen extends StatelessWidget {
  final String token;

  HomeScreen({required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white, // Definido fundo branco
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
              leading: Icon(Icons.health_and_safety),
              title: Text(
                'Gerenciar Saúde',
                style: TextStyle(color: Colors.black), // Fonte preta
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SaudeScreen(token: token),
                  ),
                );
              },
            ),
            Spacer(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(
                'Logout',
                style: TextStyle(color: Colors.black), // Fonte preta
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Somos uma equipe dedicada ao desenvolvimento de soluções inovadoras para o gerenciamento da criação de suínos.\n\n'
                    'Combinamos nossa experiência em tecnologia com um profundo conhecimento do setor para oferecer um sistema completo e intuitivo que atenda às necessidades dos criadores.\n\n'
                    'Junte-se a nós e descubra como podemos ajudar a impulsionar sua produção de suínos para o próximo nível!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Fonte preta
                ),
              ),
              SizedBox(height: 20),
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
