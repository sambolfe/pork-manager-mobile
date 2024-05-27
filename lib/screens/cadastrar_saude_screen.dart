import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'saude_screen.dart';

class CadastrarSaudeScreen extends StatefulWidget {
  final String token;
  CadastrarSaudeScreen({required this.token});

  @override
  _CadastrarSaudeScreenState createState() => _CadastrarSaudeScreenState();
}

class _CadastrarSaudeScreenState extends State<CadastrarSaudeScreen> {
  // Controladores para os campos de texto
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _tipoTratamentoController = TextEditingController();
  final TextEditingController _dataInicioTratamentoController = TextEditingController();
  final TextEditingController _dataEntradaCioController = TextEditingController();
  final TextEditingController _observacoesController = TextEditingController();
  final TextEditingController _fotoController = TextEditingController(); // Controlador para a foto

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Saúde'),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Text('Menu'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(token: widget.token), // Passando o token para HomeScreen
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Gerenciar Saúde'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SaudeScreen(token: widget.token),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _pesoController,
              decoration: InputDecoration(labelText: 'Peso'),
            ),
            TextFormField(
              controller: _tipoTratamentoController,
              decoration: InputDecoration(labelText: 'Tipo de Tratamento'),
            ),
            TextFormField(
              controller: _dataInicioTratamentoController,
              decoration: InputDecoration(labelText: 'Data de Início do Tratamento'),
            ),
            TextFormField(
              controller: _dataEntradaCioController,
              decoration: InputDecoration(labelText: 'Data de Entrada em Cio'),
            ),
            TextFormField(
              controller: _observacoesController,
              decoration: InputDecoration(labelText: 'Observações'),
            ),
            TextFormField(
              controller: _fotoController,
              decoration: InputDecoration(labelText: 'Foto'),
            ),
            ElevatedButton(
              onPressed: () {
                // Adicione o código para enviar os dados ao servidor
              },
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
